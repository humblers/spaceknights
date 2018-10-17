package lobby

import (
	"fmt"
	"log"
	"net/http"
	"strconv"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
)

type authRouter struct {
	*Router
	sessionStore *redistore.RediStore
	logger       *log.Logger
}

func NewAuthRouter(path string, ss *redistore.RediStore, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	a := &authRouter{
		Router: &Router{
			path:         path,
			sessionStore: ss,
			redisPool:    p,
			logger:       l,
		},
		sessionStore: ss,
		logger:       l,
	}
	a.Post("login", a.login)
	a.Post("logout", a.logout)
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

	resp.UID, resp.User, err = userFromPlatformInfo(b.redisConn, req.PType, req.PID, enableEmpty)
	if err != nil {
		a.logger.Printf("query user fail(%v)", err)
		resp.ErrMessage = "login fail"
		return
	}
	resp.Token = resp.UID
	session, err := a.sessionStore.Get(r, AuthSession)
	if err != nil {
		resp.ErrMessage = "login fail"
		return
	}
	session.Values["uid"] = resp.UID
	if err = session.Save(r, w); err != nil {
		resp.ErrMessage = "login fail"
		return
	}
}

func (a *authRouter) logout(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp CommonResponse
	b.response = &resp
	session, err := a.sessionStore.Get(r, AuthSession)
	if err != nil {
		resp.ErrMessage = "logout fail"
		return
	}
	// delete session
	session.Options.MaxAge = -1
	if err := session.Save(r, w); err != nil {
		resp.ErrMessage = "logout fail"
		return
	}
}

func userFromPlatformInfo(rc redis.Conn, ptype string, pid string, enableEmpty bool) (string, *user, error) {
	if enableEmpty && pid == "" {
		ret, err := redis.Int(rc.Do("INCR", fmt.Sprintf("gen:%v", ptype)))
		if err != nil {
			return "", nil, err
		}
		pid = strconv.Itoa(ret)
	}

	pkey := fmt.Sprintf("%v:%v", ptype, pid)
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
		Cards: make(map[string]userCard),
	}
	if err := loadStructFromMultipleKeys(rc, user, uid); err != nil {
		return nil, err
	}
	return user, nil
}
