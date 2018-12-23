package lobby

import (
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/gomodule/redigo/redis"
)

type authRouter struct {
	*Router
	logger *log.Logger
}

func NewAuthRouter(path string, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	a := &authRouter{
		Router: &Router{
			path:      path,
			redisPool: p,
			logger:    l,
		},
		logger: l,
	}
	a.Post("login", a.login)
	return path, http.TimeoutHandler(a, TimeoutDefault, TimeoutMessage)
}

func (a *authRouter) login(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp LoginResponse
	b.response = &resp

	var req LoginRequest
	var err error
	if err = parseJSON(r.Body, &req); err != nil {
		resp.ErrMessage = "invalid request"
		return
	}

	var enableEmpty bool
	switch req.PType {
	case "dev":
		enableEmpty = true
	default:
		resp.ErrMessage = "invalid login data"
		return
	}

	// TODO: Check PToken other than "dev" platform

	resp.UID, resp.User, err = userFromPlatformInfo(b.redisConn, req.PType, &req.PID, enableEmpty)
	if err != nil {
		a.logger.Printf("query user fail(%v)", err)
		resp.ErrMessage = "login fail"
		return
	}
	resp.PID = req.PID
	resp.Token = resp.UID
	w.Header().Set("Set-Cookie", resp.UID)
}

func userFromPlatformInfo(rc redis.Conn, ptype string, pid *string, enableEmpty bool) (string, *user, error) {
	if enableEmpty && *pid == "" {
		ret, err := redis.Int(rc.Do("INCR", fmt.Sprintf("gen:%v", ptype)))
		if err != nil {
			return "", nil, err
		}
		*pid = strconv.Itoa(ret)
	}

	pkey := fmt.Sprintf("%v:%v", ptype, *pid)
	if _, err := rc.Do("WATCH", pkey); err != nil {
		return "", nil, err
	}
	uid, err := redis.String(rc.Do("GET", pkey))
	if err == nil {
		user, err := userFromUID(rc, uid)
		return uid, user, err
	}
	if err != redis.ErrNil {
		return "", nil, err
	}

	uidRaw, err := redis.Int(rc.Do("INCR", "gen:uid"))
	if err != nil {
		return "", nil, err
	}
	uid = strconv.Itoa(uidRaw)
	user := newUser()
	rc.Send("MULTI")
	rc.Send("SET", pkey, uid)
	storeStructToMultipleKeys(rc, *user, uid)
	if _, err := rc.Do("EXEC"); err != nil {
		return "", nil, err
	}
	return uid, user, nil
}

func userFromUID(rc redis.Conn, uid string) (*user, error) {
	user := &user{
		Cards: make(map[string]card),
	}
	if err := loadStructFromMultipleKeys(rc, user, uid); err != nil {
		return nil, err
	}
	return user, nil
}
