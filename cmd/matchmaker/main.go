package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"log"
	"math/rand"
	"net"
	"os"
	"os/signal"
	"runtime"
	"runtime/pprof"
	"strconv"
	"sync"
	"time"

	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/game"
)

var matchMakeScript = redis.NewScript(1, `
	-- arguments
	local key = KEYS[1]
	local now = tonumber(ARGV[1])
	local t1 = tonumber(ARGV[2])
	local t2 = tonumber(ARGV[3])
	local t3 = tonumber(ARGV[4])
	local d1 = tonumber(ARGV[5])
	local d2 = tonumber(ARGV[6])

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
				users[#users + 1] = { id = id, rank = data.Rank, time = data.Time }
			end
		end
		return users
	end
	local matchable = function (wait_a, wait_b, rankdiff)
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
			local wait_a = now - user.time
			for j = i + 1, n do
				local candidate = users[j]
				if candidate then
					local wait_b = now - candidate.time
					local rankdiff = math.abs(user.rank - candidate.rank)
					if matchable(wait_a, wait_b, rankdiff) then
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
			elseif wait_a > t3 then
				-- match with AI
				matched[#matched + 1] = user.id
				matched[#matched + 1] = 'bot'
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
var numGR int // # of goroutines for leak detection

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

	logger.Print("server starting")
	numGR = runtime.NumGoroutine()
	ticker := time.NewTicker(1 * time.Second)
	rand.Seed(time.Now().UnixNano())
	defer ticker.Stop()
	for {
		select {
		case sig := <-c:
			fmt.Fprintln(os.Stderr, "")
			logger.Printf("Got %v signal. Aborting...", sig)
			wg.Wait()
			curr := runtime.NumGoroutine()
			if curr != numGR {
				logger.Printf("go routine leak detected: %v -> %v", numGR, curr)
				pprof.Lookup("goroutine").WriteTo(os.Stderr, 2)
			}
			logger.Print("server stopped")
			return
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
		60,
		1,
		5,
	))
	if err != nil {
		panic(err)
	}
	for i := 0; i < len(matched); i += 2 {
		p1 := matched[i]
		p2 := matched[i+1]
		wg.Add(1)
		go func() {
			defer wg.Done()
			createMatch(p1, p2)
		}()
	}
}

func createMatch(id1, id2 string) {
	logger.Printf("creating match: %v vs %v", id1, id2)
	conn := pool.Get()
	defer conn.Close()
	config := game.Config{
		MapName: "Thanatos",
	}
	p1 := getPlayerData(id1, "Blue")
	p2 := getPlayerData(id2, "Red")
	config.Players = append(config.Players, p1, p2)
	gameid, err := redis.Int(conn.Do("INCR", "nextgameid"))
	if err != nil {
		panic(err)
	}
	config.Id = strconv.Itoa(gameid)
	requestToGameServer(config)
}

func getPlayerData(id, team string) game.PlayerData {
	d := game.PlayerData{
		Id:   id,
		Team: game.Team(team),
	}
	if id == "bot" {
		var squirePool []string
		var knightPool []string
		for k, v := range data.Cards {
			switch v.Type {
			case data.SquireCard:
				squirePool = append(squirePool, k)
			case data.KnightCard:
				knightPool = append(knightPool, k)
			default:
				panic("unknown card type")
			}
		}
		rand.Shuffle(len(squirePool), func(i, j int) { squirePool[i], squirePool[j] = squirePool[j], squirePool[i] })
		rand.Shuffle(len(knightPool), func(i, j int) { knightPool[i], knightPool[j] = knightPool[j], knightPool[i] })
		squirePool = squirePool[:data.SquireCountInInitialDeck]
		knightPool = knightPool[:data.KnightCountInInitialDeck]
		for _, name := range squirePool {
			d.Deck = append(d.Deck, data.Card{Name: name, Level: 0})
		}
		for i, name := range knightPool {
			var side data.KnightSide
			switch i {
			case 0:
				side = data.Left
			case 1:
				side = data.Center
			case 2:
				side = data.Right
			default:
				panic("invalid knight side")
			}
			d.Deck = append(d.Deck, data.Card{Name: name, Level: 0, Side: side})
		}
		rand.Shuffle(len(d.Deck), func(i, j int) { d.Deck[i], d.Deck[j] = d.Deck[j], d.Deck[i] })
	} else {
		conn := pool.Get()
		defer conn.Close()
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
