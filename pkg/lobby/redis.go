package lobby

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"math/rand"
	"reflect"
	"strings"
	"time"

	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/data"
)

type user struct {
	Name             string          `db:"string,name"`
	Level            int             `db:"string,lv"`
	Exp              int             `db:"string,exp"`
	Galacticoin      int             `db:"string,galacticoin"`
	Dimensium        int             `db:"string,dimensium"`
	Cards            map[string]card `db:"hashes,cards"`
	DeckSlots        []deck          `db:"lists,decks"`
	DeckSelected     int             `db:"string,decknum"`
	Rank             int             `db:"string,rank"`
	Medal            int             `db:"string,medal"`
	FreeChest        int             `db:"string,free-chest"`  // timestamp at acquired time
	MedalChest       int             `db:"string,medal-chest"` // medals earned after last chest open
	BattleChestSlots []*data.Chest   `db:"lists,battle-chest-slots"`
	BattleChestOrder int             `db:"string,battle-chest-order"`
}

type card data.Card

func (c card) String() string {
	b, err := json.Marshal(c)
	if err != nil {
		panic(err)
	}
	return string(b)
}

type deck []data.Card

func (d deck) String() string {
	b, err := json.Marshal(d)
	if err != nil {
		panic(err)
	}
	return string(b)
}

var initialCards map[string]card
var initialDeckSlots = [data.DeckSlotSize]deck{
	data.InitialDeck,
	data.InitialDeck,
	data.InitialDeck,
	data.InitialDeck,
	data.InitialDeck,
}

func newUser() *user {
	if initialCards == nil {
		initialCards = make(map[string]card, len(data.Cards))
		for k, _ := range data.Cards {
			initialCards[k] = card{Holding: data.Upgrade.CardCostToLevel(0, 4)}
		}
	}
	coin := data.Upgrade.CoinCostToLevel(data.Legendary, 0, 4) * 9

	return &user{
		//		Galacticoin: data.InitialGalacticoin,
		Galacticoin:      coin,
		Dimensium:        data.InitialDimensium,
		Cards:            initialCards,
		DeckSlots:        initialDeckSlots[0:],
		Rank:             data.InitialRank,
		BattleChestSlots: []*data.Chest{nil, nil, nil, nil, nil, nil, nil, nil},
	}
}

func convertMap(v reflect.Value, src []interface{}, err error) error {
	if err != nil {
		return err
	}
	if len(src)%2 != 0 {
		return errors.New("number of values not a multiple of 2")
	}
	if v.Kind() != reflect.Map {
		return errors.New("dest not map")
	}
	var key string
	var val interface{}
	var setter func() error
	switch v.Type().Elem().Kind() {
	case reflect.String:
		setter = func() error {
			val, err = redis.String(val, nil)
			if err != nil {
				return err
			}
			v.SetMapIndex(reflect.ValueOf(key), reflect.ValueOf(val))
			return nil
		}
	case reflect.Int, reflect.Int64:
		setter = func() error {
			val, err = redis.Int(val, nil)
			if err != nil {
				return err
			}
			v.SetMapIndex(reflect.ValueOf(key), reflect.ValueOf(val))
			return nil
		}
	case reflect.Struct, reflect.Slice:
		setter = func() error {
			vNested := reflect.New(v.Type().Elem())
			if err := json.Unmarshal(val.([]byte), vNested.Interface()); err != nil {
				return err
			}
			v.SetMapIndex(reflect.ValueOf(key), vNested.Elem())
			return nil
		}
	default:
		panic(fmt.Errorf("nested type(%v) not supported", v.Type().Elem().Kind()))
	}
	for i := 0; i < len(src); i += 2 {
		key = string(src[i].([]byte))
		val = src[i+1]
		if err := setter(); err != nil {
			return err
		}
	}
	return nil
}

func convertSlice(v reflect.Value, src []interface{}, err error) error {
	if err != nil {
		return err
	}
	if v.Kind() != reflect.Slice {
		return errors.New("dest not slice")
	}
	var val interface{}
	var setter func() error
	switch v.Type().Elem().Kind() {
	case reflect.String:
		setter = func() error {
			val, err = redis.String(val, nil)
			if err != nil {
				return err
			}
			v.Set(reflect.Append(v, reflect.ValueOf(val)))
			return nil
		}
	case reflect.Int, reflect.Int64:
		setter = func() error {
			val, err = redis.Int(val, nil)
			if err != nil {
				return err
			}
			v.Set(reflect.Append(v, reflect.ValueOf(val)))
			return nil
		}
	case reflect.Struct, reflect.Slice:
		setter = func() error {
			vNested := reflect.New(v.Type().Elem())
			if err := json.Unmarshal(val.([]byte), vNested.Interface()); err != nil {
				return err
			}
			v.Set(reflect.Append(v, vNested.Elem()))
			return nil
		}
	default:
		panic(fmt.Errorf("nested type(%v) not supported", v.Type().Elem().Kind()))
	}
	for i := 0; i < len(src); i++ {
		val = src[i]
		if err := setter(); err != nil {
			return err
		}
	}
	return nil
}

func parseTag(sf reflect.StructField) (string, string, error) {
	if sf.PkgPath != "" && !sf.Anonymous {
		return "", "", errors.New("unexported filed")
	}
	tags := strings.Split(sf.Tag.Get("db"), ",")
	if tags[0] == "" || tags[0] == "-" {
		return "", "", errors.New("no tag or set ingnore")
	}
	if len(tags) != 2 {
		return "", "", errors.New("tag length must be 2 now")
	}
	return tags[0], tags[1], nil
}

func storeStructToMultipleKeys(rc redis.Conn, src interface{}, prefix string) error {
	s := reflect.ValueOf(src)
	t := s.Type()
	for i := 0; i < t.NumField(); i++ {
		sf := t.Field(i)
		dataType, key, err := parseTag(sf)
		if err != nil {
			continue
		}
		if prefix != "" {
			key = fmt.Sprintf("%v:%v", prefix, key)
		}
		f := s.FieldByName(sf.Name)
		switch dataType {
		case "string":
			rc.Send("SET", key, f.Interface())
		case "hashes":
			rc.Send("HMSET", redis.Args{key}.AddFlat(f.Interface())...)
		case "lists":
			rc.Send("RPUSH", redis.Args{key}.AddFlat(f.Interface())...)
		default:
			return fmt.Errorf("unknown or unimplemented data type %v", dataType)
		}
	}
	return nil
}

func loadStructFromMultipleKeys(rc redis.Conn, dest interface{}, prefix string) error {
	d := reflect.ValueOf(dest)
	if d.Kind() != reflect.Ptr || d.IsNil() {
		return errors.New("dest must be non-nil pointer to a struct")
	}
	d = d.Elem()
	if d.Kind() != reflect.Struct {
		return errors.New("dest not struct")
	}
	t := d.Type()
	for i := 0; i < t.NumField(); i++ {
		sf := t.Field(i)
		dataType, key, err := parseTag(sf)
		if err != nil {
			continue
		}
		if prefix != "" {
			key = fmt.Sprintf("%v:%v", prefix, key)
		}
		f := d.FieldByName(sf.Name)
		switch dataType {
		case "string":
			switch f.Kind() {
			case reflect.Int, reflect.Int64:
				rep, err := redis.Int64(rc.Do("GET", key))
				if err != nil {
					return err
				}
				f.SetInt(rep)
			case reflect.String:
				rep, err := redis.String(rc.Do("GET", key))
				if err != nil && err != redis.ErrNil {
					return err
				}
				f.SetString(rep)
			}
		case "hashes":
			rep, err := redis.Values(rc.Do("HGETALL", key))
			if err := convertMap(f, rep, err); err != nil {
				return err
			}
		case "lists":
			rep, err := redis.Values(rc.Do("LRANGE", key, 0, -1))
			if err := convertSlice(f, rep, err); err != nil {
				return err
			}
		default:
			return fmt.Errorf("unknown or unimplemented data type %v", dataType)
		}
	}
	return nil
}

// lock for redis single instance. if U want lock for multiple redis masters, see below link
// https://redis.io/topics/distlock
func lockKey(c redis.Conn, key string, expire time.Duration) (func() error, error) {
	val := make([]byte, 20)
	if _, err := rand.Read(val); err != nil {
		return nil, err
	}

	inMilli := expire.Nanoseconds() / 1000 / 1000
	ret, err := c.Do("SET", key, val, "PX", inMilli, "NX")
	if err != nil {
		return nil, err
	}
	if ret == nil {
		return nil, errors.New("already locked")
	}
	return func() error {
		if _, err := c.Do("WATCH", key); err != nil {
			return err
		}
		ret, err := redis.Bytes(c.Do("GET", key))
		if err != nil {
			return err
		}
		if bytes.Compare(ret, val) != 0 {
			return errors.New("lock value miss match")
		}
		c.Send("MULTI")
		c.Send("DEL", key)
		if _, err := c.Do("EXEC"); err != nil {
			return err
		}
		return nil
	}, nil
}
