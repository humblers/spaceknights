package redis

import (
	"fmt"
	"math/rand"
	"testing"
	"time"

	"github.com/gomodule/redigo/redis"
)

func TestLock(t *testing.T) {
	p := &redis.Pool{
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", ":6379")
			if err != nil {
				return nil, err
			}
			return c, nil
		},
	}
	c := p.Get()
	defer c.Close()
	rand.Seed(time.Now().Unix())
	val := make([]byte, 20)
	rand.Read(val)
	closure, err := Lock(c, "test:lock", val, time.Second*60)
	if err != nil {
		fmt.Printf("error locking(%v)", err)
		return
	}
	if err := closure(); err != nil {
		fmt.Printf("error unlocking(%v)", err)
	}
}
