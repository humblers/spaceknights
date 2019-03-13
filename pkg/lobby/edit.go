package lobby

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"time"

	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/data"
)

type editRouter struct {
	*Router
}

func NewEditRouter(path string, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	e := &editRouter{
		Router: &Router{
			path:      path,
			redisPool: p,
			logger:    l,
		},
	}
	e.Post("deck/select", e.deckSelect)
	e.Post("deck/set", e.deckSet)
	e.Post("card/upgrade", e.cardUpgrade)

	// for test
	e.Post("chest/fill", e.fillChest)
	e.Post("rank/set", e.setRank)
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
	if data.Upgrade.IsLevelMax(card.Rarity, card.Level) {
		resp.ErrMessage = "card level is max"
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

// for test. below code must remove before production level
type ChestFillRequest struct {
	Rank int
}

type ChestFillResponse struct {
	ErrMessage   string
	MedalChest   int
	BattleChests []*data.Chest
}

func (e *editRouter) fillChest(b *bases, w http.ResponseWriter, r *http.Request) {
	rc := b.redisConn
	var resp ChestFillResponse
	b.response = &resp

	var req ChestFillRequest
	var err error
	if err := parseJSON(r.Body, &req); err != nil {
		resp.ErrMessage = err.Error()
		return
	}

	key_slots := fmt.Sprintf("%v:battle-chest-slots", b.uid)
	v, _ := rc.Do("LRANGE", key_slots, 0, -1)
	slice := v.([]interface{})
	for i, v := range slice {
		var chest *data.Chest
		json.Unmarshal(v.([]byte), &chest)
		if chest != nil {
			resp.BattleChests = append(resp.BattleChests, chest)
			continue
		}

		// empty slot
		key_order := fmt.Sprintf("%v:battle-chest-order", b.uid)
		order, _ := redis.Int(rc.Do("GET", key_order))
		order = order % len(data.ChestOrder)
		name := data.ChestOrder[order]
		if _, err := rc.Do("INCR", key_order); err != nil {
			e.logger.Print(err)
		}
		time := time.Now().Unix()
		chest = &data.Chest{
			Name:         name,
			AcquiredRank: req.Rank,
			AcquiredAt:   time,
		}
		json, _ := json.Marshal(chest)
		if _, err := rc.Do("LSET", key_slots, i, json); err != nil {
			panic(err)
		}
		resp.BattleChests = append(resp.BattleChests, chest)
	}

	key_medal_chest := fmt.Sprintf("%v:medal-chest", b.uid)
	resp.MedalChest, err = redis.Int(rc.Do("INCRBY", key_medal_chest, 10))
	if err != nil {
		panic(err)
	}
}

type SetRankRequestResponse struct {
	ErrMessage string
	Rank       int
	Medal      int
}

func (e *editRouter) setRank(b *bases, w http.ResponseWriter, r *http.Request) {
	rc := b.redisConn
	var payload SetRankRequestResponse
	b.response = &payload

	if err := parseJSON(r.Body, &payload); err != nil {
		payload.ErrMessage = err.Error()
		return
	}

	if _, err := rc.Do("SET", fmt.Sprintf("%v:rank", b.uid), payload.Rank); err != nil {
		payload.ErrMessage = err.Error()
		return
	}
	if _, err := rc.Do("SET", fmt.Sprintf("%v:medal", b.uid), payload.Medal); err != nil {
		payload.ErrMessage = err.Error()
		return
	}
}
