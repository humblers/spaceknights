package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"net"
	"strconv"
	"sync"
)

type Packet []byte

func (packet Packet) Parse(out interface{}) error {
	return json.Unmarshal(packet, out)
}

func NewPacket(in interface{}) Packet {
	b, err := json.Marshal(in)
	if err != nil {
		panic(err)
	}
	b = append(b, '\n')
	return Packet(b)
}

type Candidate struct {
	UserId  string
	Deck    *[]string
	Knights *[]string
}

type SessionRequest struct {
	SessionId   string
	Home        Candidate
	Visitor     Candidate
	DoNotCreate bool
}

type SessionResponse struct {
	Created bool
	Exists  bool
}

func Request(sid int64, uid int64) {
	defer loop.Done()
	conn, err := net.Dial("tcp", "127.0.0.1:9989")
	if err != nil {
		fmt.Printf("game server connect fail:%v", err)
		return
	}
	defer conn.Close()
	deck := make([]string, 5)
	knight := []string{"shuriken", "space_z", "freezer"}
	conn.Write(NewPacket(SessionRequest{
		SessionId: strconv.FormatInt(sid, 10),
		Home:      Candidate{strconv.FormatInt(uid, 10), &deck, &knight},
		Visitor:   Candidate{strconv.FormatInt(uid+1, 10), &deck, &knight},
	}))
	var created bool
	if b, _, err := bufio.NewReader(conn).ReadLine(); err == nil {
		packet := Packet(b)
		var resp SessionResponse
		if err := packet.Parse(&resp); err != nil || !resp.Created {
			fmt.Printf("fail!! err(%v), created(%v)\n", err, created)
		}
	}
}

var loop sync.WaitGroup

const N = 100

func main() {
	sid := int64(1)
	uid := int64(1)
	loop.Add(N)
	for i := 0; i < N; i++ {
		go Request(sid, uid)
		sid += 1
		uid += 2
	}
	loop.Wait()
}
