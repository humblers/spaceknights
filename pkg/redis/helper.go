package redis

import (
	"bytes"
	"encoding/json"
	"errors"
	"time"

	"github.com/gomodule/redigo/redis"
)

func parseJSON(in string, out interface{}) error {
	if in == "" {
		return nil
	}
	return json.Unmarshal([]byte(in), out)
}

// lock for redis single instance. if U want lock for multiple redis masters, see below link
// https://redis.io/topics/distlock
func Lock(c redis.Conn, key string, val []byte, expire time.Duration) (func() error, error) {
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
