package lobby

import (
	"context"
	"errors"
	"fmt"
	"log"
	"net/http"
	"strconv"
	"time"

	firebase "firebase.google.com/go"
	"firebase.google.com/go/auth"
	"github.com/gomodule/redigo/redis"
)

var errEmptyToken = errors.New("token string empty")

type authRouter struct {
	*Router

	firebaseClient *auth.Client
	logger         *log.Logger
}

func NewAuthRouter(path string, f *firebase.App, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	client, err := f.Auth(context.Background())
	if err != nil {
		panic(err)
	}
	a := &authRouter{
		Router: &Router{
			path:      path,
			redisPool: p,
			logger:    l,
		},
		firebaseClient: client,
		logger:         l,
	}
	a.PostAuthUnnecessary("login", a.login)
	return path, http.TimeoutHandler(a, TimeoutDefault, TimeoutMessage)
}

func (a *authRouter) login(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp LoginResponse
	var user *user
	var uid, customToken, errMessage string
	var err error
	b.response = &resp

	defer func() {
		if err != nil {
			a.logger.Printf("error occured while login: %v", err)
		}
		if errMessage != "" {
			resp.ErrMessage = errMessage
			return
		}
		resp.User = user
		resp.UID = uid
		resp.HumblerToken = uid
		resp.IssuedAt = int(time.Now().Unix())
		resp.FirebaseToken = customToken
		w.Header().Set("Set-Cookie", uid)
	}()

	var req LoginRequest
	if err = parseJSON(r.Body, &req); err != nil {
		errMessage = "invalid request"
		return
	}

	uid, user, err = a.userFromHumblerToken(&req, b.redisConn)
	if err == nil {
		return
	}
	uid, user, err = a.userFromFirebaseToken(&req, b.redisConn, r.Context())
	if err == nil {
		return
	} else if err != errEmptyToken {
		errMessage = "login fail"
		return
	}
	uid, customToken, user, err = a.newUserWithFirebaseCustomToken(b.redisConn, r.Context())
	if err == nil {
		return
	}
	errMessage = "login fail"
}

func (a *authRouter) userFromHumblerToken(req *LoginRequest, rc redis.Conn) (string, *user, error) {
	//TODO: verify from humbler token or intergrate to firebase token auth
	return "", nil, fmt.Errorf("unimplemented")
}

func (a *authRouter) userFromFirebaseToken(req *LoginRequest, rc redis.Conn, ctx context.Context) (string, *user, error) {
	if req.FirebaseToken == "" {
		return "", nil, errEmptyToken
	}
	token, err := a.firebaseClient.VerifyIDToken(ctx, req.FirebaseToken)
	if err != nil {
		return "", nil, err
	}
	uid := token.UID
	user, err := loadUser(rc, uid)
	return uid, user, err
}

func (a *authRouter) newUserWithFirebaseCustomToken(rc redis.Conn, ctx context.Context) (string, string, *user, error) {
	uidRaw, err := redis.Int(rc.Do("INCR", "gen:uid"))
	if err != nil {
		return "", "", nil, err
	}
	uid := strconv.Itoa(uidRaw)
	user := newUser()
	rc.Send("MULTI")
	storeStructToMultipleKeys(rc, *user, uid)
	if _, err := rc.Do("EXEC"); err != nil {
		return "", "", nil, err
	}
	token, err := a.firebaseClient.CustomToken(ctx, uid)
	if err != nil {
		return "", "", nil, err
	}
	return uid, token, user, nil
}
