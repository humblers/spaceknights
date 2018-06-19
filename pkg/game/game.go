package game

import "fmt"
import "log"
import "time"
import "strings"

//const playTime = time.Minute * 3
const playTime = time.Second * 30
const stepInterval = time.Millisecond * 100

type game struct {
	step    int
	players map[string]*player
	actions map[int][]Action
	sent    packet

	joinc   chan *client
	leavec  chan *client
	applyc  chan Input
	joined  chan error
	left    chan error
	applied chan error
	quit    chan struct{}
	logger  *log.Logger
}

func newGame(players []Player, l *log.Logger) *game {
	g := &game{
		players: make(map[string]*player),
		actions: make(map[int][]Action),

		joinc:   make(chan *client),
		leavec:  make(chan *client),
		applyc:  make(chan Input),
		joined:  make(chan error),
		left:    make(chan error),
		applied: make(chan error),
		quit:    make(chan struct{}),
		logger:  l,
	}
	for _, p := range players {
		g.players[p.Id] = &player{}
	}
	return g
}

func (g *game) String() string {
	var ids []string
	for id, _ := range g.players {
		ids = append(ids, id)
	}
	return fmt.Sprintf("game (%v)", strings.Join(ids, " VS "))
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
		return nil
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
		panic("this should not happen")
	}
	if existing != nil {
		existing.stop()
	}
	p.client = c
	c.write(g.sent) // send previous game states
	g.logger.Print(string(g.sent))
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
	var step int
	if g.step > i.Step {
		step = g.step
	} else {
		step = i.Step
	}
	g.actions[step] = append(g.actions[step], i.Action)
	return nil
}

func (g *game) over() bool {
	return g.step > int(playTime/stepInterval)
}

func (g *game) run() {
	ticker := time.NewTicker(stepInterval)
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
	state := State{
		Step:    g.step,
		Actions: g.actions[g.step],
	}
	packet := newPacket(state)
	g.sent = append(g.sent, packet...)
	for _, p := range g.players {
		if p.client != nil {
			p.client.write(packet)
			g.logger.Print(string(packet))
		}
	}
}

func (g *game) update() {
	g.step++
}
