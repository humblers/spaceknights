package lobby

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gomodule/redigo/redis"
)

type matchRouter struct {
	*Router
}

type MatchParams struct {
	Rank int
	Time int64
}

func NewMatchRouter(path string, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	m := &matchRouter{
		Router: &Router{
			path:      path,
			redisPool: p,
			logger:    l,
		},
	}
	m.Post("request", m.request)
	m.Post("cancel", m.cancel)
	return path, http.TimeoutHandler(m, TimeoutDefault, TimeoutMessage)
}

func (m *matchRouter) request(b *bases, w http.ResponseWriter, r *http.Request) {
	// should not check 'id:game' key.
	// if game server crashes before key deletion, client cannot request match forever

	// push to queue
	rank, err := redis.Int(b.redisConn.Do("GET", fmt.Sprintf("%v:rank", b.uid)))
	if err != nil {
		m.logger.Print(err)
		b.response = &CommonResponse{err.Error()}
		return
	}
	params := MatchParams{rank, time.Now().Unix()}
	bytes, err := json.Marshal(params)
	if err != nil {
		panic(err)
	}
	n, err := redis.Int(b.redisConn.Do("HSETNX", "match-queue", b.uid, string(bytes)))
	if err != nil {
		m.logger.Print(err)
		b.response = &CommonResponse{err.Error()}
		return
	}
	if n <= 0 {
		b.response = &CommonResponse{"already queued"}
		return
	}
}

func (m *matchRouter) cancel(b *bases, w http.ResponseWriter, r *http.Request) {
	n, err := redis.Int(b.redisConn.Do("HDEL", "match-queue", b.uid))
	if err != nil {
		m.logger.Print(err)
		b.response = &CommonResponse{err.Error()}
		return
	}
	if n <= 0 {
		b.response = &CommonResponse{"cannot cancel either not requested or already game started"}
		return
	}
}
