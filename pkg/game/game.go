package game

import "fmt"
import "log"
import "time"
import "strings"

import "github.com/humblers/spaceknights/pkg/fixed"
import "github.com/humblers/spaceknights/pkg/physics"
import "github.com/humblers/spaceknights/pkg/nav"

const playTime = time.Second * 30
const stepInterval = time.Millisecond * 100
const stepPerSec = 10

var params = map[string]fixed.Scalar{
	"scale":       fixed.One.Div(fixed.FromInt(10)),
	"dt":          fixed.One.Div(fixed.FromInt(stepPerSec)),
	"gravity_y":   0,
	"restitution": fixed.One.Div(fixed.FromInt(10)),
}

type Game interface {
	World() physics.World
	Map() nav.Map
	FindUnit(id int) Unit
	AddUnit(name string, t Team, level, posX, posY int)
	AddBullet(b Bullet)
	UnitIds() []int

	Apply(i Input) error
	Join(c *client) error
	Leave(c *client) error
}

type game struct {
	step        int
	world       physics.World
	map_        nav.Map
	units       map[int]Unit
	unitIds     []int
	unitCounter int
	bullets     []Bullet

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

func newGame(cfg Config, l *log.Logger) *game {
	g := &game{
		world: physics.NewWorld(params),
		map_:  nav.NewMap(cfg.MapName, params["scale"]),

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
	for _, p := range cfg.Players {
		g.players[p.Id] = newPlayer(p, g)
	}
	g.createMap()
	return g
}

func (g *game) createMap() {
	for _, o := range g.map_.GetObstacles() {
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

func (g *game) String() string {
	var ids []string
	for id, _ := range g.players {
		ids = append(ids, id)
	}
	return fmt.Sprintf("game (%v)", strings.Join(ids, " VS "))
}

func (g *game) Join(c *client) error {
	select {
	case <-g.quit:
		return fmt.Errorf("%v already ended", g)
	case g.joinc <- c:
	}
	return <-g.joined
}

func (g *game) Leave(c *client) error {
	select {
	case <-g.quit:
		return nil
	case g.leavec <- c:
	}
	return <-g.left
}

func (g *game) Apply(i Input) error {
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
	return g.step >= int(playTime/stepInterval)
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
			//g.logger.Print(string(packet))
		}
	}
}

func (g *game) update() {
	if g.actions[g.step] != nil {
		actions := g.actions[g.step]
		filtered := actions[:0]
		for _, action := range actions {
			err := g.players[action.Id].do(&action)
			if err != nil {
				g.logger.Print(err)
			} else {
				filtered = append(filtered, action)
			}
		}
		g.actions[g.step] = filtered
	}
	for _, id := range g.unitIds {
		g.units[id].Update()
	}
	for _, b := range g.bullets {
		b.Update(g)
	}
	g.removeDeadUnits()
	g.removeExpiredBullets()
	g.world.Step()
}

func (g *game) removeDeadUnits() {
	filtered := g.unitIds[:0]
	for _, id := range g.unitIds {
		if !g.units[id].IsDead() {
			delete(g.units, id)
			filtered = append(filtered, id)
		}
	}
	g.unitIds = filtered
}

func (g *game) removeExpiredBullets() {
	filtered := g.bullets[:0]
	for _, b := range g.bullets {
		if !b.IsExpired() {
			filtered = append(filtered, b)
		}
	}
	g.bullets = filtered
}

func (g *game) AddUnit(name string, t Team, level, posX, posY int) {
	g.unitCounter++
	id := g.unitCounter
	var u Unit
	switch name {
	case "archer":
		u = newArcher(id, t, level, posX, posY, g)
	}
	g.units[id] = u
	g.unitIds = append(g.unitIds, id)
}

func (g *game) FindUnit(id int) Unit {
	return g.units[id]
}

func (g *game) AddBullet(b Bullet) {
	g.bullets = append(g.bullets, b)
}

func (g *game) World() physics.World {
	return g.world
}

func (g *game) Map() nav.Map {
	return g.map_
}

func (g *game) UnitIds() []int {
	return g.unitIds
}
