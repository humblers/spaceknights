package lobby

import (
	"fmt"
	"log"
	"net/http"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
)

type editRouter struct {
	*Router
}

func NewEditRouter(path string, ss *redistore.RediStore, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	e := &editRouter{
		Router: &Router{
			path:         path,
			sessionStore: ss,
			redisPool:    p,
			logger:       l,
		},
	}
	e.Post("deck/change", e.deckChange)
	return path, http.TimeoutHandler(e, TimeoutDefault, TimeoutMessage)
}

func (e *editRouter) deckChange(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp CommonResponse
	b.response = &resp

	var req DeckChangeRequest
	if err := parseJSON(r.Body, &req); err != nil {
		resp.ErrMessage = "invalid request"
		return
	}

	if _, err := b.redisConn.Do("SET", fmt.Sprintf("%v:deckNum", b.uid), req.Num); err != nil {
		resp.ErrMessage = "change fail"
		return
	}
}
