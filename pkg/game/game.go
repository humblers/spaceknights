package game

import "fmt"
import "time"

const playTime = time.Minute * 3
const frameInterval = time.Millisecond * 100

type game struct {
	frame   int
	players map[string]*player
	inputs  map[int][]Input

	joinc   chan *client
	leavec  chan *client
	applyc  chan Input
	joined  chan error
	left    chan error
	applied chan error
	quit    chan struct{}
}

func newGame(players []Player) *game {
	g := &game{
		players: make(map[string]*player),
		inputs:  make(map[int][]Input),

		joinc:   make(chan *client),
		leavec:  make(chan *client),
		applyc:  make(chan Input),
		joined:  make(chan error),
		left:    make(chan error),
		applied: make(chan error),
		quit:    make(chan struct{}),
	}
	for _, p := range players {
		g.players[p.Id] = &player{}
	}
	return g
}

func (g *game) join(c *client) error {
	select {
	case <-g.quit:
		return fmt.Errorf("%v already ended", g)
	case g.joinc <- c:
	}
	return <-g.joined
}

func (g *game) leave(c *client) error {
	select {
	case <-g.quit:
		return fmt.Errorf("%v already ended", g)
	case g.leavec <- c:
	}
	return <-g.left
}

func (g *game) apply(i Input) error {
	select {
	case <-g.quit:
		return fmt.Errorf("%v already ended", g)
	case g.applyc <- i:
	}
	return <-g.applied
}

func (g *game) handleJoin(c *client) error {
	p := g.players[c.id]
	if p == nil {
		return fmt.Errorf("player %v not exists", c.id)
	}
	existing := p.client
	if existing == c {
		return nil
	}
	if existing != nil {
		existing.stop()
	}
	p.client = c
	return nil
}

func (g *game) handleLeave(c *client) error {
	p := g.players[c.id]
	if p == nil {
		return fmt.Errorf("player %v not exists", c.id)
	}
	existing := p.client
	if existing != c {
		return nil
	}
	p.client = nil
	return nil
}

func (g *game) handleApply(i Input) error {
	var frame int
	if g.frame > i.Frame {
		frame = g.frame
	} else {
		frame = i.Frame
	}
	g.inputs[frame] = append(g.inputs[frame], i)
	return nil
}

func (g *game) over() bool {
	return g.frame > int(playTime/frameInterval)
}

func (g *game) run() {
	ticker := time.NewTicker(frameInterval)
	defer ticker.Stop()
	for !g.over() {
		select {
		case <-ticker.C:
			g.broadcast()
			g.update()
		case c := <-g.joinc:
			g.joined <- g.handleJoin(c)
		case c := <-g.leavec:
			g.left <- g.handleLeave(c)
		case i := <-g.applyc:
			g.applied <- g.handleApply(i)
		}
	}
	for _, p := range g.players {
		if p.client != nil {
			p.client.stop()
		}
	}
	close(g.quit)
}

func (g *game) broadcast() {
	for _, p := range g.players {
		if p.client != nil {
			p.client.write(newPacket(g.inputs[g.frame]))
		}
	}
}

func (g *game) update() {
	g.frame++
}
