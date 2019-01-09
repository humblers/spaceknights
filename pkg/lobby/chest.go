package lobby

import "fmt"
import "log"
import "time"
import "sort"
import "math/rand"
import "net/http"
import "encoding/json"
import "github.com/gomodule/redigo/redis"
import "github.com/humblers/spaceknights/pkg/data"

type chestRouter struct {
	*Router
}

func NewChestRouter(path string, p *redis.Pool, l *log.Logger) (string, http.Handler) {
	c := &chestRouter{
		Router: &Router{
			path:      path,
			redisPool: p,
			logger:    l,
		},
	}
	c.Post("open", c.openChest)
	return path, http.TimeoutHandler(c, TimeoutDefault, TimeoutMessage)
}

func (c *chestRouter) openChest(b *bases, w http.ResponseWriter, r *http.Request) {
	rc := b.redisConn
	var resp ChestOpenResponse
	b.response = &resp

	var req ChestOpenRequest
	if err := parseJSON(r.Body, &req); err != nil {
		c.logger.Print(err)
		resp.ErrMessage = err.Error()
		return
	}

	// validate
	var chest data.Chest
	switch req.Name {
	case "Free":
		lastAcquiredTime, err := redis.Int64(rc.Do("GET", fmt.Sprintf("%v:free-chest", b.uid)))
		if err != nil {
			c.logger.Print(err)
			resp.ErrMessage = err.Error()
			return
		}
		if time.Now().Unix() < lastAcquiredTime+data.ChestMap[req.Name].Duration {
			resp.ErrMessage = "free chest not available now"
			return
		}
	case "Medal":
		medalChest, err := redis.Int(rc.Do("GET", fmt.Sprintf("%v:medal-chest", b.uid)))
		if err != nil {
			c.logger.Print(err)
			resp.ErrMessage = err.Error()
			return
		}
		if medalChest < data.RequiredMedalsForMedalChest {
			resp.ErrMessage = "not enough medals for medal chest"
			return
		}
	default:
		if bytes, err := redis.Bytes(rc.Do("LINDEX", fmt.Sprintf("%v:battle-chest-slots", b.uid), req.Slot)); err != nil {
			if err == redis.ErrNil {
				resp.ErrMessage = "invalid slot index"
			} else {
				c.logger.Print(err)
				resp.ErrMessage = err.Error()
			}
			return
		} else {
			if err := json.Unmarshal(bytes, &chest); err != nil {
				c.logger.Print(err)
				resp.ErrMessage = err.Error()
				return
			}
		}
		if chest.Name == "" {
			resp.ErrMessage = "empty slot"
			return
		}
		if req.Name != chest.Name {
			resp.ErrMessage = "chest name does not match"
			return
		}
		if time.Now().Unix() < chest.AcquiredAt+data.ChestMap[chest.Name].Duration {
			resp.ErrMessage = "cannot open battle chest yet"
			return
		}
	}

	// get rank
	var rank int
	switch req.Name {
	case "Free", "Medal":
		if rank_, err := redis.Int(rc.Do("GET", fmt.Sprintf("%v:rank", b.uid))); err != nil {
			c.logger.Print(err)
			resp.ErrMessage = err.Error()
			return
		} else {
			rank = rank_
		}
	default:
		rank = chest.AcquiredRank
	}

	// open chest and apply reward
	arena := data.ArenaFromRank(rank)
	rand := rand.New(rand.NewSource(time.Now().UnixNano()))
	gold, cash, cards := OpenChest(rand, req.Name, arena)

	for name, count := range cards {
		var card card
		key := fmt.Sprintf("%v:cards", b.uid)
		if bytes, err := redis.Bytes(rc.Do("HGET", key, name)); err != nil {
			if err == redis.ErrNil {
				// no op, new card found
			} else {
				c.logger.Print(err)
				resp.ErrMessage = err.Error()
				return
			}
		} else {
			if err := json.Unmarshal(bytes, &card); err != nil {
				c.logger.Print(err)
				resp.ErrMessage = err.Error()
				return
			}
		}
		card.Holding += count
		if _, err := rc.Do("HSET", key, name, card); err != nil {
			c.logger.Print(err)
			resp.ErrMessage = err.Error()
			return
		}
	}
	rc.Send("MULTI")
	rc.Send("INCRBY", fmt.Sprintf("%v:galacticoin", b.uid), gold)
	rc.Send("INCRBY", fmt.Sprintf("%v:dimensium", b.uid), cash)
	if _, err := rc.Do("EXEC"); err != nil {
		c.logger.Print(err)
		resp.ErrMessage = err.Error()
		return
	}

	// remove chest
	now := time.Now().Unix()
	switch req.Name {
	case "Free":
		rc.Do("SET", fmt.Sprintf("%v:free-chest", b.uid), now)
	case "Medal":
		rc.Do("SET", fmt.Sprintf("%v:medal-chest", b.uid), 0)
	default:
		rc.Do("LSET", fmt.Sprintf("%v:battle-chest-slots", b.uid), req.Slot, "null")
	}

	// reply to client
	resp.Gold = gold
	resp.Cash = cash
	resp.Cards = cards
	resp.OpenedAt = now
}

func OpenChest(r *rand.Rand, name string, arena data.Arena) (int, int, map[string]int) {
	chestInfo := data.ChestMap[name]
	numCard := chestInfo.NumCards[arena]

	// gold
	minGold := chestInfo.MinGoldPerCard * numCard
	maxGold := chestInfo.MaxGoldPerCard * numCard
	gold := r.Intn(maxGold-minGold+1) + minGold

	// cash
	minCash := chestInfo.MinCash
	maxCash := chestInfo.MaxCash
	cash := r.Intn(maxCash-minCash+1) + minCash

	// card count
	cardCount := map[data.CardRarity]int{}
	cardLeft := numCard
	for _, rarity := range []data.CardRarity{data.Rare, data.Epic, data.Legendary} {
		cardCount[rarity] = chestInfo.Guaranteed[rarity][arena]
		if r.Float64() < chestInfo.ExtraCards[rarity][arena]/100 {
			cardCount[rarity]++
		}
		cardLeft -= cardCount[rarity]
	}
	cardCount[data.Common] = cardLeft

	// bundle count
	bundleCount := map[data.CardRarity]int{}
	for rarity, count := range cardCount {
		if count > 0 {
			bundleCount[rarity] = 1
		}
	}
	diff := chestInfo.BundleMin - len(bundleCount)
	for diff > 0 {
		var candidate []data.CardRarity
		for rarity, bcount := range bundleCount {
			if cardCount[rarity] > bcount {
				candidate = append(candidate, rarity)
			}
		}
		rarity := candidate[r.Intn(len(candidate))]
		bundleCount[rarity]++
		diff--
	}

	// pick cards
	cards := map[string]int{}
	for rarity, bcount := range bundleCount {
		ccount := cardCount[rarity]
		indexes := r.Perm(ccount - 1)[0 : bcount-1]
		for i, v := range indexes {
			indexes[i] = v + 1
		}
		indexes = append(indexes, 0, ccount)
		sort.Ints(indexes)
		names := r.Perm(len(data.CardPool[arena][rarity]))
		for i := 0; i < bcount; i++ {
			name := data.CardPool[arena][rarity][names[i]]
			count := indexes[i+1] - indexes[i]
			cards[name] = count
		}
	}
	return gold, cash, cards
}
