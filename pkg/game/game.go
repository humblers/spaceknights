package game

import (
	"fmt"
	"log"
	"strings"
	"time"

	"github.com/humblers/spaceknights/pkg/data"
	"github.com/humblers/spaceknights/pkg/fixed"
	"github.com/humblers/spaceknights/pkg/nav"
	"github.com/humblers/spaceknights/pkg/physics"
)

const stepInterval = time.Second / data.StepPerSec
const wingScore = 1
const leaderScore = 3

type Team string

const (
	Blue Team = "Blue"
	Red  Team = "Red"
)

var params = map[string]fixed.Scalar{
	"scale":       fixed.One.Div(fixed.FromInt(10)),
	"dt":          fixed.One.Div(fixed.FromInt(data.StepPerSec)),
	"gravity_y":   0,
	"restitution": 0,
}

type Game interface {
	Id() string
	Step() int
	World() physics.World
	Map() nav.Map
	UnitIds() []int
	Logger() *log.Logger
	DeathToll(team Team) int
	LastDeadPosX(team Team) fixed.Scalar
	FindPlayer(team Team) Player

	FlipX(x int) int
	FlipY(y int) int
	TileFromPos(x, y int) (int, int)
	PosFromTile(x, y int) (int, int)
	FindUnit(id int) Unit
	AddUnit(name string, level, posX, posY int, p Player) Unit
	AddBullet(b Bullet)
	AddSkill(s ISkill)

	Occupied(tr *tileRect) bool
	Occupy(tr *tileRect, ownerId int)
	Release(tr *tileRect, ownerId int)

	Apply(i Input) error
	Join(c Client) error
	Leave(c Client) error
	Run()
	Replay() *Replay
	Update()
	Over() bool
	PrintGameState()
}

type game struct {
	config       Config
	step         int
	world        physics.World
	map_         nav.Map
	units        map[int]Unit
	unitIds      []int
	unitCounter  int
	bullets      []Bullet
	skills       []ISkill
	deathToll    map[Team]int
	lastDeadPosX map[Team]fixed.Scalar
	occupied     [][]int
	winner       Team

	players   map[string]Player
	playerIds []string
	actions   map[int][]Action
	sent      packet

	joinc   chan Client
	leavec  chan Client
	applyc  chan Input
	joined  chan error
	left    chan error
	applied chan error
	quit    chan struct{}
	logger  *log.Logger
}

func (g *game) FindPlayer(team Team) Player {
	for _, player := range g.players {
		if team == player.Team() {
			return player
		}
	}
	panic("should not be here")
}

func (g *game) Occupied(tr *tileRect) bool {
	for i := tr.minX(); i <= tr.maxX(); i++ {
		for j := tr.minY(); j <= tr.maxY(); j++ {
			if g.occupied[i][j] != 0 {
				return true
			}
		}
	}
	return false
}

func (g *game) Occupy(tr *tileRect, ownerId int) {
	for i := tr.minX(); i <= tr.maxX(); i++ {
		for j := tr.minY(); j <= tr.maxY(); j++ {
			if g.occupied[i][j] != 0 {
				panic("already occupied")
			}
			g.occupied[i][j] = ownerId
		}
	}
}

func (g *game) Release(tr *tileRect, ownerId int) {
	if tr == nil {
		return
	}
	for i := tr.minX(); i <= tr.maxX(); i++ {
		for j := tr.minY(); j <= tr.maxY(); j++ {
			if g.occupied[i][j] != ownerId {
				panic("owner not match")
			}
			g.occupied[i][j] = 0
		}
	}
}

func (g *game) Id() string {
	return g.config.Id
}

func (g *game) Step() int {
	return g.step
}

func (g *game) Replay() *Replay {
	return &Replay{
		Config:  g.config,
		Actions: g.actions,
		Winner:  g.winner,
	}
}

func NewGame(cfg Config, actions map[int][]Action, l *log.Logger) Game {
	g := &game{
		config:       cfg,
		world:        physics.NewWorld(params),
		map_:         nav.NewMap(cfg.MapName, params["scale"]),
		units:        make(map[int]Unit),
		deathToll:    make(map[Team]int),
		lastDeadPosX: make(map[Team]fixed.Scalar),

		players: make(map[string]Player),
		actions: actions,

		joinc:   make(chan Client),
		leavec:  make(chan Client),
		applyc:  make(chan Input),
		joined:  make(chan error),
		left:    make(chan error),
		applied: make(chan error),
		quit:    make(chan struct{}),
		logger:  l,
	}
	if g.actions == nil {
		g.actions = make(map[int][]Action)
	}
	g.initTiles()
	g.createMapObstacles()
	for _, p := range cfg.Players {
		g.players[p.Id] = newPlayer(p, g)
		g.playerIds = append(g.playerIds, p.Id)
	}
	return g
}

func (g *game) initTiles() {
	for i := 0; i < g.map_.TileNumX(); i++ {
		g.occupied = append(g.occupied, nil)
		for j := 0; j < g.map_.TileNumY(); j++ {
			g.occupied[i] = append(g.occupied[i], 0)
		}
	}
}

func (g *game) createMapObstacles() {
	for _, o := range g.map_.GetObstacles() {
		x := o.PosX()
		y := o.PosY()
		w := o.Width()
		h := o.Height()
		tw := g.map_.TileWidth()
		th := g.map_.TileHeight()

		b := g.world.AddBox(0, w, h, fixed.Vector{x, y})
		b.SetLayer(string(data.Normal))

		w = w.Mul(fixed.Two)
		h = h.Mul(fixed.Two)
		tx := x.Div(tw).ToInt()
		ty := y.Div(th).ToInt()
		nx := w.Div(tw).ToInt()
		ny := h.Div(th).ToInt()
		g.Occupy(&tileRect{tx, ty, nx, ny}, -1)
	}
}

func (g *game) String() string {
	return fmt.Sprintf("game (%v)", strings.Join(g.playerIds, " VS "))
}

func (g *game) Join(c Client) error {
	select {
	case <-g.quit:
		return fmt.Errorf("%v already ended", g)
	case g.joinc <- c:
	}
	return <-g.joined
}

func (g *game) Leave(c Client) error {
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

func (g *game) handleJoin(c Client) error {
	p := g.players[c.Id()]
	if p == nil {
		return fmt.Errorf("player %v not exists", c.Id())
	}
	existing := p.Client()
	if existing == c {
		panic("this should not happen")
	}
	if existing != nil {
		existing.Stop()
	}
	p.SetClient(c)
	c.Write(g.sent) // send previous game states
	//g.logger.Print(string(g.sent))
	return nil
}

func (g *game) handleLeave(c Client) error {
	p := g.players[c.Id()]
	if p == nil {
		return fmt.Errorf("player %v not exists", c.Id())
	}
	existing := p.Client()
	if existing != c {
		return nil
	}
	p.SetClient(nil)
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

func (g *game) Over() bool {
	switch {
	case g.step < data.PlayTime:
		if g.score(Blue) < leaderScore || g.score(Red) < leaderScore {
			return true
		} else {
			return false
		}
	case g.step < data.PlayTime+data.OverTime:
		if g.score(Blue) != g.score(Red) {
			return true
		} else {
			return false
		}
	default:
		return true
	}
}

func (g *game) setWinner() {
	if g.score(Blue) > g.score(Red) {
		g.winner = Blue
	} else if g.score(Red) > g.score(Blue) {
		g.winner = Red
	}
}

func (g *game) score(t Team) int {
	score := 0
	for _, id := range g.playerIds {
		p := g.players[id]
		if p.Team() == t {
			score += p.Score()
		}
	}
	return score
}

func (g *game) Run() {
	ticker := time.NewTicker(stepInterval)
	defer ticker.Stop()
	for !g.Over() {
		select {
		case <-ticker.C:
			g.Update()
			g.broadcast()
		case c := <-g.joinc:
			g.joined <- g.handleJoin(c)
		case c := <-g.leavec:
			g.left <- g.handleLeave(c)
		case i := <-g.applyc:
			g.applied <- g.handleApply(i)
		}
	}
	g.setWinner()
	for _, p := range g.players {
		if p.Client() != nil {
			p.Client().Stop()
		}
	}
	close(g.quit)
}

func (g *game) broadcast() {
	step := g.step - 1
	state := State{
		Step:    step,
		Actions: g.actions[step],
		Hash:    g.world.Digest(),
	}
	packet := newPacket(state)
	g.sent = append(g.sent, packet...)
	for _, p := range g.players {
		if p.Client() != nil {
			p.Client().Write(packet)
			//g.logger.Print(string(packet))
		}
	}
}

func (g *game) Update() {
	if g.actions[g.step] != nil {
		actions := g.actions[g.step]
		filtered := actions[:0]
		for _, action := range actions {
			err := g.players[action.Id].Do(&action)
			if err != nil {
				g.logger.Print(err)
			} else {
				filtered = append(filtered, action)
			}
		}
		g.actions[g.step] = filtered
	}
	for _, id := range g.playerIds {
		g.players[id].Update()
	}
	for _, id := range g.unitIds {
		g.units[id].Update()
	}
	for _, b := range g.bullets {
		b.Update()
	}
	for _, s := range g.skills {
		s.Update()
	}
	g.removeDeadUnits()
	g.removeExpiredBullets()
	g.removeExpiredSkills()
	g.world.Step()
	g.step++
}

func (g *game) PrintGameState() {
	for _, id := range g.unitIds {
		u := g.units[id]
		g.logger.Printf("%v %v\n", u.Id(), u.Name())
		g.logger.Printf("\tpos_x: %v\n", u.Position().X)
		g.logger.Printf("\tpos_y: %v\n", u.Position().Y)
	}
}

func (g *game) removeDeadUnits() {
	filtered := g.unitIds[:0]
	for _, id := range g.unitIds {
		u := g.units[id]
		if u.IsDead() {
			delete(g.units, id)
			if u.Type() != data.Knight {
				g.deathToll[u.Team()]++
				g.lastDeadPosX[u.Team()] = u.Position().X
			}
			u.Destroy()
		} else {
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

func (g *game) removeExpiredSkills() {
	filtered := g.skills[:0]
	for _, s := range g.skills {
		if !s.IsExpired() {
			filtered = append(filtered, s)
		}
	}
	g.skills = filtered
}

func (g *game) AddUnit(name string, level, posX, posY int, p Player) Unit {
	g.unitCounter++
	id := g.unitCounter
	var u Unit
	switch name {
	case "absorber":
		u = newAbsorber(id, level, posX, posY, g, p)
	case "archengineer":
		u = newArchengineer(id, level, posX, posY, g, p)
	case "archer":
		u = newArcher(id, level, posX, posY, g, p)
	case "archmage":
		u = newArchmage(id, level, posX, posY, g, p)
	case "archsapper":
		u = newArchsapper(id, level, posX, posY, g, p)
	case "astra":
		u = newAstra(id, level, posX, posY, g, p)
	case "azero":
		u = newAzero(id, level, posX, posY, g, p)
	case "barrack":
		u = newBarrack(id, level, posX, posY, g, p)
	case "beholder":
		u = newBeholder(id, level, posX, posY, g, p)
	case "berserker":
		u = newBerserker(id, level, posX, posY, g, p)
	case "blaster":
		u = newBlaster(id, level, posX, posY, g, p)
	case "blastturret":
		u = newBlastturret(id, level, posX, posY, g, p)
	case "buran":
		u = newBuran(id, level, posX, posY, g, p)
	case "cannon":
		u = newCannon(id, level, posX, posY, g, p)
	case "champion":
		u = newChampion(id, level, posX, posY, g, p)
	case "drillram":
		u = newDrillram(id, level, posX, posY, g, p)
	case "enforcer":
		u = newEnforcer(id, level, posX, posY, g, p)
	case "felhound":
		u = newFelhound(id, level, posX, posY, g, p)
	case "footman":
		u = newFootman(id, level, posX, posY, g, p)
	case "frost":
		u = newFrost(id, level, posX, posY, g, p)
	case "gargoyle":
		u = newGargoyle(id, level, posX, posY, g, p)
	case "gargoyleking":
		u = newGargoyleking(id, level, posX, posY, g, p)
	case "giant":
		u = newGiant(id, level, posX, posY, g, p)
	case "heavymissile":
		u = newHeavymissile(id, level, posX, posY, g, p)
	case "ironcoffin":
		u = newIroncoffin(id, level, posX, posY, g, p)
	case "jouster":
		u = newJouster(id, level, posX, posY, g, p)
	case "judge":
		u = newJudge(id, level, posX, posY, g, p)
	case "lancer":
		u = newLancer(id, level, posX, posY, g, p)
	case "legion":
		u = newLegion(id, level, posX, posY, g, p)
	case "micromissile":
		u = newMicromissile(id, level, posX, posY, g, p)
	case "nagmash":
		u = newNagmash(id, level, posX, posY, g, p)
	case "nukemissile":
		u = newNukemissile(id, level, posX, posY, g, p)
	case "ogre":
		u = newOgre(id, level, posX, posY, g, p)
	case "panzerkunstler":
		u = newPanzerkunstler(id, level, posX, posY, g, p)
	case "pixie":
		u = newPixie(id, level, posX, posY, g, p)
	case "pixiegeode":
		u = newPixiegeode(id, level, posX, posY, g, p)
	case "pixieking":
		u = newPixieking(id, level, posX, posY, g, p)
	case "psabu":
		u = newPsabu(id, level, posX, posY, g, p)
	case "sentry":
		u = newSentry(id, level, posX, posY, g, p)
	case "sentryshelter":
		u = newSentryshelter(id, level, posX, posY, g, p)
	case "shadowvision":
		u = newShadowvision(id, level, posX, posY, g, p)
	case "starfire":
		u = newStarfire(id, level, posX, posY, g, p)
	case "tombstone":
		u = newTombstone(id, level, posX, posY, g, p)
	case "trainee":
		u = newTrainee(id, level, posX, posY, g, p)
	case "valkyrie":
		u = newValkyrie(id, level, posX, posY, g, p)
	case "voidcreeper":
		u = newVoidcreeper(id, level, posX, posY, g, p)
	case "wasp":
		u = newWasp(id, level, posX, posY, g, p)
	default:
		g.logger.Panicf("unknown unit name: %v", name)
	}
	g.units[id] = u
	g.unitIds = append(g.unitIds, id)
	return u
}

func (g *game) FindUnit(id int) Unit {
	return g.units[id]
}

func (g *game) AddBullet(b Bullet) {
	g.bullets = append(g.bullets, b)
}

func (g *game) AddSkill(s ISkill) {
	g.skills = append(g.skills, s)
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

func (g *game) Logger() *log.Logger {
	return g.logger
}

func (g *game) DeathToll(team Team) int {
	return g.deathToll[team]
}

func (g *game) LastDeadPosX(team Team) fixed.Scalar {
	return g.lastDeadPosX[team]
}

func (g *game) FlipX(x int) int {
	return g.world.ToPixel(g.map_.Width()) - x
}

func (g *game) FlipY(y int) int {
	return g.world.ToPixel(g.map_.Height()) - y
}

func (g *game) TileFromPos(x, y int) (int, int) {
	mx, my := g.map_.TileNumX()-1, g.map_.TileNumY()-1
	tx, ty := x/g.world.ToPixel(g.map_.TileWidth()), y/g.world.ToPixel(g.map_.TileHeight())
	if tx < 0 {
		tx = 0
	} else if tx > mx {
		tx = mx
	}
	if ty < 0 {
		ty = 0
	} else if ty > my {
		ty = my
	}
	return tx, ty
}

func (g *game) PosFromTile(x, y int) (int, int) {
	tw, th := g.world.ToPixel(g.map_.TileWidth()), g.world.ToPixel(g.map_.TileHeight())
	return x*tw + tw/2, y*th + th/2
}

func boxVSCircle(posA, posB fixed.Vector, width, height, radius fixed.Scalar) bool {
	relPos := posB.Sub(posA)
	closest := relPos
	xExtent := width
	yExtent := height
	closest.X = closest.X.Clamp(-xExtent, xExtent)
	closest.Y = closest.Y.Clamp(-yExtent, yExtent)
	if relPos == closest {
		return true
	}
	normal := relPos.Sub(closest)
	d := normal.LengthSquared()
	if d > radius.Mul(radius) {
		return false
	}
	return true
}
