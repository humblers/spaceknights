package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"sync"
	"time"

	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/game"
)

var matchMakeScript = redis.NewScript(1, `
	-- arguments
	local key = KEYS[1]
	local now = ARGV[1]
	local t1 = ARGV[2]
	local t2 = ARGV[3]
	local d1 = ARGV[4]
	local d2 = ARGV[5]

	-- functions
	local getusers = function ()
		local arr = redis.call('HGETALL', key)
		local users = {}
		local id
		for i, v in ipairs(arr) do
			if i % 2 == 1 then
				id = v
			else
				local data = cjson.decode(v)
				users[#users + 1] = { id = id, rank = data.rank, time = data.time }
			end
		end
		return users
	end
	local matchable = function (a, b, rankdiff)
		local wait_a = now - a.time
		local wait_b = now - b.time
		if rankdiff < d1 then
			return true
		elseif rankdiff < d2 then
			if wait_a > t1 and wait_b > t1 then
				return true
			else
				return false
			end
		else
			if wait_a > t2 and wait_b > t2 then
				return true
			else
				return false
			end
		end
	end

	-- main
	local users = getusers()
	local n = #users
	local matched = {}
	table.sort(users, function(a, b) return a.time < b.time end)
	for i = 1, n do
		local user = users[i]
		if user then
			local picked
			local index
			local mindiff
			for j = i + 1, n do
				local candidate = users[j]
				if candidate then
					local rankdiff = math.abs(user.rank - candidate.rank)
					if matchable(user, candidate, rankdiff) then
						if not picked or rankdiff < mindiff then
							picked = candidate
							index = j
							mindiff = rankdiff
						end
					end
				end
			end
			if picked then
				users[index] = nil
				matched[#matched + 1] = user.id
				matched[#matched + 1] = picked.id
			end
		end
	end
	if #matched > 0 then
		redis.call('HDEL', key, unpack(matched))
	end
	return matched
`)

var logger *log.Logger
var pool *redis.Pool
var gameServerAddr string
var wg sync.WaitGroup

func main() {
	var rhost, rport string
	var ghost, gport string
	flag.StringVar(&rhost, "rhost", "127.0.0.1", "redis server host")
	flag.StringVar(&rport, "rport", "6379", "redis server port")
	flag.StringVar(&ghost, "ghost", "127.0.0.1", "game server host")
	flag.StringVar(&gport, "gport", "9989", "game server port")
	flag.Parse()

	c := make(chan os.Signal)
	signal.Notify(c, os.Interrupt)

	logger = log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)
	pool = &redis.Pool{
		Dial:        func() (redis.Conn, error) { return redis.Dial("tcp", net.JoinHostPort(rhost, rport)) },
		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
	}
	defer pool.Close()
	gameServerAddr = net.JoinHostPort(ghost, gport)

	logger.Print("matchmaker starting")
	ticker := time.NewTicker(1 * time.Second)
	defer ticker.Stop()
	for {
		select {
		case sig := <-c:
			fmt.Fprintln(os.Stderr, "")
			logger.Printf("Got %v signal. Aborting...", sig)
			wg.Wait()
			logger.Print("matchmaker stopped")
		case <-ticker.C:
			matchMake()
		}
	}
}

func matchMake() {
	conn := pool.Get()
	defer conn.Close()
	matched, err := redis.Strings(matchMakeScript.Do(
		conn,
		"match-queue",
		time.Now().Unix(),
		10,
		30,
		1,
		5,
	))
	if err != nil {
		panic(err)
	}
	for i := 0; i < len(matched); i += 2 {
		wg.Add(1)
		go func() {
			defer wg.Done()
			createMatch(matched[i], matched[i+1])
		}()
	}
}

func createMatch(id1, id2 string) {
	conn := pool.Get()
	defer conn.Close()
	config := game.Config{
		MapName: "Thanatos",
	}
	p1 := getPlayerData(id1, "Blue")
	p2 := getPlayerData(id2, "Red")
	config.Players = append(config.Players, p1, p2)
	gameid, err := redis.String(conn.Do("INCR", "nextgameid"))
	if err != nil {
		panic(err)
	}
	config.Id = gameid
	requestToGameServer(config)
}

func getPlayerData(id, team string) game.PlayerData {
	conn := pool.Get()
	defer conn.Close()
	d := game.PlayerData{
		Id:   id,
		Team: game.Team(team),
	}
	index, err := redis.Int(conn.Do("GET", fmt.Sprintf("%v:decknum", id)))
	if err != nil {
		panic(err)
	}
	deck, err := redis.Bytes(conn.Do("LINDEX", fmt.Sprintf("%v:decks", id), index))
	if err != nil {
		panic(err)
	}
	if err := json.Unmarshal(deck, &d.Deck); err != nil {
		panic(err)
	}
	args := []interface{}{fmt.Sprintf("%v:cards", id)}
	for _, c := range d.Deck {
		args = append(args, c.Name)
	}
	reply, err := redis.Values(conn.Do("HMGET", args...))
	if err != nil {
		panic(err)
	}
	for i, c := range d.Deck {
		var card data.Card
		if err := json.Unmarshal(reply[i].([]byte), &card); err != nil {
			panic(err)
		}
		c.Level = card.Level
	}
	return d
}

func requestToGameServer(cfg game.Config) {
	conn, err := net.Dial("tcp", gameServerAddr)
	if err != nil {
		panic(err)
	}
	defer conn.Close()
	packet, err := json.Marshal(cfg)
	if err != nil {
		panic(err)
	}
	if _, err := conn.Write(append(packet, '\n')); err != nil {
		panic(err)
	}
}
