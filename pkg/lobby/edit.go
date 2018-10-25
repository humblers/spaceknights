package lobby

import (
	"encoding/json"
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
	e.Post("deck/select", e.deckSelect)
	e.Post("deck/set", e.deckSet)
	return path, http.TimeoutHandler(e, TimeoutDefault, TimeoutMessage)
}

func (e *editRouter) deckSelect(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp CommonResponse
	b.response = &resp

	var req DeckSelectRequest
	if err := parseJSON(r.Body, &req); err != nil {
		resp.ErrMessage = "invalid data"
		return
	}

	if _, err := b.redisConn.Do("SET", fmt.Sprintf("%v:decknum", b.uid), req.Num); err != nil {
		resp.ErrMessage = "change fail"
		return
	}
}

func (e *editRouter) deckSet(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp CommonResponse
	b.response = &resp

	var req DeckSetRequest
	if err := parseJSON(r.Body, &req); err != nil {
		resp.ErrMessage = "invalid data"
		return
	}

	deck_raw, err := json.Marshal(req.Deck)
	if err != nil {
		resp.ErrMessage = "invalid data"
		return
	}

	rc := b.redisConn
	rc.Send("MULTI")
	rc.Send("SET", fmt.Sprintf("%v:decknum", b.uid), req.Num)
	rc.Send("LSET", fmt.Sprintf("%v:decks", b.uid), req.Num, deck_raw)
	if _, err := rc.Do("EXEC"); err != nil {
		e.logger.Printf("deck change fail: %v", err)
		resp.ErrMessage = "change fail"
		return
	}
}
