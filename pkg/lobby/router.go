package lobby

import (
	"bytes"
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"time"

	"github.com/gomodule/redigo/redis"
)

type methodType int

const (
	mSTUB methodType = 1 << iota
	mCONNECT
	mDELETE
	mGET
	mHEAD
	mOPTIONS
	mPATCH
	mPOST
	mPUT
	mTRACE
)

const AuthSession = "auth"
const TimeoutDefault = 5 * time.Second
const TimeoutMessage = string(`{"ErrMessage":"503 Handler timeout"}`)

var methodMap = map[string]methodType{
	"CONNECT": mCONNECT,
	"DELETE":  mDELETE,
	"GET":     mGET,
	"HEAD":    mHEAD,
	"OPTIONS": mOPTIONS,
	"PATCH":   mPATCH,
	"POST":    mPOST,
	"PUT":     mPUT,
	"TRACE":   mTRACE,
}

type bases struct {
	redisConn redis.Conn
	uid       string
	response  interface{}
}

type handler func(b *bases, w http.ResponseWriter, r *http.Request)

type route struct {
	method          methodType
	handler         handler
	authUnnecessary bool
}

type Router struct {
	path  string
	route map[string]route

	redisPool *redis.Pool
	logger    *log.Logger
}

func (rt *Router) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	status := http.StatusOK
	b := &bases{
		redisConn: rt.redisPool.Get(),
	}
	defer b.redisConn.Close()
	defer func() {
		rt.responseJSON(w, r, status, b.response)
	}()

	subPath := r.URL.Path[len(rt.path):]
	route, exist := rt.route[subPath]
	if !exist {
		status = http.StatusNotFound
		b.response = &CommonResponse{"404 page not found"}
		return
	}
	if route.method != methodMap[r.Method] {
		status = http.StatusMethodNotAllowed
		b.response = &CommonResponse{"405 method not allowed"}
		return
	}

	if !route.authUnnecessary {
		//TODO: verify auth and get uid by token from header/payload whatever. then branching succ/fail case
		b.uid = r.Header.Get("Cookie")
	}
	route.handler(b, w, r)
}

func (rt *Router) registerHandler(method methodType, path string, h handler) {
	if _, exist := rt.route[path]; exist {
		panic(errors.New("path already exist"))
	}
	if rt.route == nil {
		rt.route = make(map[string]route)
	}
	rt.route[path] = route{
		method:  method,
		handler: h,
	}
}

func (rt *Router) Get(path string, h handler) {
	rt.registerHandler(mGET, path, h)
}

func (rt *Router) Post(path string, h handler) {
	rt.registerHandler(mPOST, path, h)
}

func (rt *Router) PostAuthUnnecessary(path string, h handler) {
	rt.registerHandler(mPOST, path, h)
	route := rt.route[path]
	route.authUnnecessary = true
}

func parseJSON(in io.ReadCloser, out interface{}) error {
	return json.NewDecoder(in).Decode(out)
}

func writeHeader(w http.ResponseWriter, code int) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(code)
}

func (rt *Router) responseJSON(w http.ResponseWriter, r *http.Request, code int, in interface{}) {
	if in == nil {
		in = &CommonResponse{}
	}
	buf := &bytes.Buffer{}
	enc := json.NewEncoder(buf)
	enc.SetEscapeHTML(true)
	if err := enc.Encode(in); err != nil {
		code = http.StatusInternalServerError
		if err := enc.Encode(&CommonResponse{"500 json encode error"}); err != nil {
			panic(err)
		}
	}
	writeHeader(w, code)
	w.Write(buf.Bytes())
	rt.logger.Printf("[%v]code:%v", r.URL.Path, code)
}
