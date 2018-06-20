package game

import "fmt"
import "log"
import "time"
import "strings"

import "git.humbler.games/spaceknights/spaceknights/pkg/fixed"
import "git.humbler.games/spaceknights/spaceknights/pkg/physics"
import "git.humbler.games/spaceknights/spaceknights/pkg/nav"

const playTime = time.Second * 30
const stepInterval = time.Millisecond * 100
const stepPerSec = 10

var params = map[string]fixed.Scalar{
	"scale":       fixed.One.Div(fixed.FromInt(10)),
	"dt":          fixed.One.Div(fixed.FromInt(stepPerSec)),
	"gravity_y":   0,
	"restitution": fixed.One.Div(fixed.FromInt(10)),
}

type game struct {
	step  int
	world *physics.World
	_map  nav.Map
	units []*unit
	enemy *physics.Body

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

func newGame(m nav.Map, players []Player, l *log.Logger) *game {
	g := &game{
		world: physics.NewWorld(params),
		_map:  m,

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
	g.createMap()
	g.createEnemy()
	return g
}

func (g *game) createMap() {
	for _, o := range g._map.GetObstacles() {
		width := g.world.ToPixel(o.Width())
		height := g.world.ToPixel(o.Height())
		x := g.world.ToPixel(o.PosX())
		y := g.world.ToPixel(o.PosY())
		g.world.AddBox(
			0,
			g.world.FromPixel(width),
			g.world.FromPixel(height),
			fixed.Vector{g.world.FromPixel(x), g.world.FromPixel(y)},
		)
	}
}

func (g *game) createEnemy() {
	g.enemy = g.world.AddBox(
		0,
		g.world.FromPixel(25),
		g.world.FromPixel(25),
		fixed.Vector{g.world.FromPixel(500), g.world.FromPixel(100)},
	)
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
			g.update()
			g.broadcast()
			g.step++
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
		Hash:    g.world.Digest(),
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
	if g.actions[g.step] != nil {
		for _, action := range g.actions[g.step] {
			u := &unit{}
			u.init(g.world, g._map, action.PosX, action.PosY)
			g.units = append(g.units, u)
			g.logger.Print("unit added!!!!")
		}
	}
	for _, unit := range g.units {
		unit.update(g.step, g.enemy)
	}
	g.world.Step()
}
