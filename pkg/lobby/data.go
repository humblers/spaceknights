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

var cards_raw string
var units_raw string

type dataRouter struct {
	*Router
	logger *log.Logger
}

func NewDataRouter(path string, ss *redistore.RediStore, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	var b []byte
	var err error
	b, err = json.Marshal(data.Cards)
	if err != nil {
		panic(fmt.Errorf("Data initialize fail: %v", err))
	}
	cards_raw = string(b)
	b, err = json.Marshal(data.Units)
	if err != nil {
		panic(fmt.Errorf("Data initialize fail: %v", err))
	}
	units_raw = string(b)

	d := &dataRouter{
		Router: &Router{
			path:         path,
			sessionStore: ss,
			redisPool:    p,
			logger:       l,
		},
		logger: l,
	}
	d.Post("cards", d.cards)
	d.Post("units", d.units)
	return path, http.TimeoutHandler(d, TimeoutDefault, TimeoutMessage)
}

func (d *dataRouter) cards(b *bases, w http.ResponseWriter, r *http.Request) {
	b.response = &DataResponse{Data: cards_raw}
}

func (d *dataRouter) units(b *bases, w http.ResponseWriter, r *http.Request) {
	b.response = &DataResponse{Data: units_raw}
}
