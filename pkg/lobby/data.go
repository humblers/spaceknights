package lobby

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"

	"github.com/boj/redistore"
	"github.com/gomodule/redigo/redis"
)

type card struct {
	Cost   int
	Unit   string
	Count  int
	Rarity string
}

type UType string
type UTypes []UType

type Layer string
type Layers []Layer

const (
	Troop    UType = "troop"
	Building UType = "building"
	Knight   UType = "knight"

	Normal  Layer = "normal"
	Ether   Layer = "ether"
	Casting Layer = "casting"
)

var cards_raw = map[string]string{}
var cards = map[string]card{
/* //sample card
"archers": card{
	Cost:   3000,
	Unit:   "archer",
	Count:  2,
	Rarity: "common",
}, */
}

var actives_raw = map[string]string{}
var actives = map[string]map[string]interface{}{
/* //sample knight active skill
"barrack": map[string]interface{}{
	"unit":         "barrack",
	"castduration": 50,
	"precastdelay": 20,
}, */
}

var passives_raw = map[string]string{}
var passives = map[string]map[string]interface{}{
/* //sample knight passive skill
"gatherfootman": map[string]interface{}{
	"unit":    "footman",
	"count":   4,
	"offsetX": []int{-30, 30, -30, 30},
	"offsetY": []int{-30, -30, 30, 30},
	"perstep": 300,
}, */
}

var units_raw = map[string]string{}
var units = map[string]map[string]interface{}{
/* //sample unit
"archer": map[string]interface{}{
	"type":           Troop,
	"layer":          Normal,
	"mass":           6,
	"radius":         20,
	"hp":             []int{125},
	"sight":          350,
	"speed":          100,
	"targettypes":    UTypes{Troop, Building, Knight},
	"targetlayers":   Layers{Normal},
	"attackdamage":   []int{40, 60, 90},
	"attackrange":    300,
	"attackinterval": 12,
	"preattackdelay": 0,
	"bulletlifetime": 4,
}, */
}

type dataRouter struct {
	*Router
	logger *log.Logger
}

func NewDataRouter(path string, ss *redistore.RediStore, p *redis.Pool, l *log.Logger) (string, http.Handler) {
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

func LoadDataFromDB(rp *redis.Pool, overwrite bool) {
	rc := rp.Get()
	defer rc.Close()

	var src []interface{}
	var err error

	src, err = redis.Values(rc.Do("HGETALL", "data:cards"))
	if err != nil {
		panic(fmt.Errorf("load fail: %v", err))
	}
	for i := 0; i < len(src); i += 2 {
		k, v := string(src[i].([]byte)), src[i+1].([]byte)
		cards_raw[k] = string(v)
		var card card
		if err := json.Unmarshal(v, &card); err != nil {
			panic(fmt.Errorf("json parsing err while load data from db: %v", err))
		}
		if _, ok := cards[k]; !overwrite && ok {
			continue
		}
		cards[k] = card
	}
	//fmt.Printf("[DATA:CARDS] %v\n", cards)

	src, err = redis.Values(rc.Do("HGETALL", "data:units"))
	if err != nil {
		panic(fmt.Errorf("load fail: %v", err))
	}
	for i := 0; i < len(src); i += 2 {
		k, v := string(src[i].([]byte)), src[i+1].([]byte)
		units_raw[k] = string(v)
		var m map[string]interface{}
		if err := json.Unmarshal(v, &m); err != nil {
			panic(fmt.Errorf("json parsing err while load data from db: %v", err))
		}
		if _, ok := units[k]; !overwrite && ok {
			continue
		}
		units[k] = m
	}
	//fmt.Printf("[DATA:UNITS] %v\n", units)
}
