package lobby

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/data"
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
	e.Post("card/upgrade", e.cardUpgrade)
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

func (e *editRouter) cardUpgrade(b *bases, w http.ResponseWriter, r *http.Request) {
	var resp CardUpradeResponse
	b.response = &resp

	var req CardUpgradeRequest
	if err := parseJSON(r.Body, &req); err != nil {
		resp.ErrMessage = "invalid data"
		return
	}

	rc := b.redisConn
	rc.Send("GET", fmt.Sprintf("%v:galacticoin", b.uid))
	rc.Send("HGET", fmt.Sprintf("%v:cards", b.uid), req.Name)
	rc.Flush()
	coin, err := redis.Int(rc.Receive())
	if err != nil {
		resp.ErrMessage = "upgrade fail"
		return
	}
	var card card
	bytes, err := redis.Bytes(rc.Receive())
	if err != nil {
		resp.ErrMessage = "upgrade fail"
		return
	}
	if err := json.Unmarshal(bytes, &card); err != nil {
		resp.ErrMessage = "upgrade fail"
		return
	}
	card.Holding -= data.Upgrade.CardCostNextLevel(card.Level)
	if card.Holding < 0 {
		resp.ErrMessage = "not enough card"
		return
	}
	coin_cost := data.Upgrade.CoinCostNextLevel(data.Cards[req.Name].Rarity, card.Level)
	if coin_cost > coin {
		resp.ErrMessage = "not enough galacticoin"
		return
	}
	card.Level++

	rc.Send("MULTI")
	rc.Send("DECRBY", fmt.Sprintf("%v:galacticoin", b.uid), coin_cost)
	rc.Send("HSET", fmt.Sprintf("%v:cards", b.uid), req.Name, card)
	rep, err := redis.Values(rc.Do("EXEC"))
	resp.Galacticoin, err = redis.Int(rep[0], err)
	if err != nil {
		e.logger.Printf("card upgrade fail: %v", err)
		resp.ErrMessage = "upgrade fail"
		return
	}
	resp.Card = card
}
