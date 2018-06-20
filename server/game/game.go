package main

import (
	"fmt"
	"strings"
	"time"

	"github.com/golang/glog"
)

const (
	PlayTime      = time.Minute * 3
	DoubleAfter   = time.Minute * 2
	OverTime      = time.Minute * 3
	FrameInterval = time.Millisecond * 100
)

const (
	MapWidth   = 320
	MapHeight  = 544
	TileHeight = 16
	CenterX    = MapWidth / 2
	CenterY    = MapHeight / 2
)

type Area struct {
	T float64 // Top
	B float64 // Bottom
	L float64 // Left
	R float64 // Right
}

var (
	Top       = &Area{0, 240, 0, 320}
	Bottom    = &Area{272, 544, 0, 320}
	LeftHole  = &Area{240, 272, 48, 64}
	RightHole = &Area{240, 272, 256, 272}
)
var (
	LeftHoleTL  = Vector2{LeftHole.L, LeftHole.T}
	LeftHoleTR  = Vector2{LeftHole.R, LeftHole.T}
	LeftHoleBL  = Vector2{LeftHole.L, LeftHole.B}
	LeftHoleBR  = Vector2{LeftHole.R, LeftHole.B}
	RightHoleTL = Vector2{RightHole.L, RightHole.T}
	RightHoleTR = Vector2{RightHole.R, RightHole.T}
	RightHoleBL = Vector2{RightHole.L, RightHole.B}
	RightHoleBR = Vector2{RightHole.R, RightHole.B}
)

func (a *Area) Contains(v Vector2) bool {
	return v.X >= a.L && v.X <= a.R && v.Y >= a.T && v.Y <= a.B
}

type Portal struct {
	Left  Vector2
	Right Vector2
}

func (p *Portal) String() string {
	return fmt.Sprintf("(%v, %v)", p.Left, p.Right)
}

var (
	TopToLeftHole     = &Portal{LeftHoleTR, LeftHoleTL}
	TopToRightHole    = &Portal{RightHoleTR, RightHoleTL}
	BottomToLeftHole  = &Portal{LeftHoleBL, LeftHoleBR}
	BottomToRightHole = &Portal{RightHoleBL, RightHoleBR}
	LeftHoleToTop     = &Portal{LeftHoleTL, LeftHoleTR}
	RightHoleToTop    = &Portal{RightHoleTL, RightHoleTR}
	LeftHoleToBottom  = &Portal{LeftHoleBR, LeftHoleBL}
	RightHoleToBottom = &Portal{RightHoleBR, RightHoleBL}
)

type Team string

const (
	Home    Team = "Home"
	Visitor Team = "Visitor"
	Draw    Team = "Draw" // for game result
)

type Game struct {
	Frame         int     // valid only if > 0
	Players       Players `json:",omitempty"`
	Units         map[int]*Unit
	Spells        map[int]*Spell
	WaitingCards  []*WaitingCard `json:",omitempty"`
	ObjectCounter int            `json:"-"`
	Result        *Result        `json:",omitempty"`
	Winner        Team           `json:"-"`
	Stats         map[Team]*Stat `json:"-"`
}

type Result struct {
	Winner Team
	Stats  map[Team]*Stat
}

type Stat struct {
	KnightDeadCount        int
	EnergyUsed             int
	TroopDamageDealt       int
	CoreDamageDealt        int
	KnightDamageDealt      int
	KnightBulletTotalCount int
	KnightBulletHitCount   int
}

func (game *Game) RemoveDeadUnits() {
	for _, unit := range game.Units {
		if unit.IsDead() {
			unit.SelfRemove()
		}
	}
}

func NewGame() *Game {
	g := Game{
		Frame:         1,
		Units:         make(map[int]*Unit),
		Spells:        make(map[int]*Spell),
		Players:       make(map[string]*Player),
		ObjectCounter: 1,
		Stats:         make(map[Team]*Stat),
	}

	for _, u := range NewMothership(Home) {
		g.AddUnit(u)
	}
	for _, u := range NewMothership(Visitor) {
		g.AddUnit(u)
	}
	g.Stats[Home] = &Stat{}
	g.Stats[Visitor] = &Stat{}
	return &g
}

func (game *Game) Score(team Team) int {
	score := 0
	for _, player := range game.Players {
		if player.Team != team {
			continue
		}
		for _, knight := range player.Knights {
			if knight.IsDead() {
				continue
			}
			switch knight.Name {
			case "astra":
				score += MaincoreScore
			default:
				score += SubcoreScore
			}
		}
	}
	return score
}

func (game *Game) Over() bool {
	//	if len(game.Players) > 2 {
	//		return false
	//	}

	home := game.Score(Home)
	visitor := game.Score(Visitor)
	switch {
	case home < MaincoreScore:
		return true
	case visitor < MaincoreScore:
		return true
	case home != visitor && game.Frame > int(PlayTime/FrameInterval):
		return true
	}
	if game.Frame > int((PlayTime+OverTime)/FrameInterval) {
		return true
	}
	return false
}

func (game *Game) GetWinner() Team {
	home := game.Score(Home)
	visitor := game.Score(Visitor)
	switch {
	case home > visitor:
		return Home
	case visitor > home:
		return Visitor
	}
	return Draw
}

func (g *Game) Join(team Team, user User) {
	deck := user.deck
	if len(deck) < HandSize {
		deck = CreateRandomDeck()
	}
	knightNames := user.knights
	if len(knightNames) < 3 {
		knightNames = []string{"legion", "astra", "frost"}
	}
	knights := NewKnights(team, knightNames)
	player := NewPlayer(team, deck, knights, g.Frame)
	if user.id == "" {
		player.InstructManager = NewInstructManager(player)
	}
	g.Players[user.id] = player
	for _, knight := range knights {
		g.AddUnit(knight)
	}
}

func (g *Game) AddUnit(unit *Unit) {
	if unit.Team == Home {
		unit.Heading = Vector2{0, -1}
	} else {
		unit.Heading = Vector2{0, 1}
	}
	if unit.Id <= 0 {
		unit.Id = g.ObjectCounter
		g.ObjectCounter++
	}
	unit.Game = g
	unit.State = Idle
	g.Units[unit.Id] = unit
}

func (g *Game) AddSpell(spell *Spell) {
	if spell.Id <= 0 {
		spell.Id = g.ObjectCounter
		g.ObjectCounter++
	}
	spell.Game = g
	g.Spells[spell.Id] = spell
}

func (g *Game) AddToWaitingCards(card Card, pos Vector2, player *Player, knight *Unit) {
	waiting := NewWaitingCard(g.ObjectCounter, player.Team, card, pos, g.Frame, knight)
	count := waiting.GetUnitCount()
	g.ObjectCounter += count
	g.WaitingCards = append(g.WaitingCards, waiting)
}

func (g *Game) ActivateCard(card *WaitingCard) {
	switch card.Name {
	case "archers":
		g.AddUnit(NewArcher(card.IdStarting, card.Team, card.Position, Vector2{1, 0}))
		g.AddUnit(NewArcher(card.IdStarting+1, card.Team, card.Position, Vector2{-1, 0}))
	case "barrack":
		g.AddUnit(NewBarrack(card.IdStarting, card.Team, card.Position))
	case "footman":
		g.AddUnit(NewFootman(card.IdStarting, card.Team, card.Position, Vector2{1, 1}))
		g.AddUnit(NewFootman(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewFootman(card.IdStarting+2, card.Team, card.Position, Vector2{-1, 1}))
		g.AddUnit(NewFootman(card.IdStarting+3, card.Team, card.Position, Vector2{-1, -1}))
	case "blaster":
		g.AddUnit(NewBlaster(card.IdStarting, card.Team, card.Position))
	case "blastturret":
		g.AddUnit(NewBlastturret(card.IdStarting, card.Team, card.Position))
	case "cannon":
		g.AddUnit(NewCannon(card.IdStarting, card.Team, card.Position))
	case "jouster":
		g.AddUnit(NewJouster(card.IdStarting, card.Team, card.Position))
	case "giant":
		g.AddUnit(NewGiant(card.IdStarting, card.Team, card.Position))
	case "sentryshelter":
		g.AddUnit(NewSentryshelter(card.IdStarting, card.Team, card.Position))
	case "drillram":
		g.AddUnit(NewDrillram(card.IdStarting, card.Team, card.Position))
	case "gargoyleking":
		g.AddUnit(NewGargoyleking(card.IdStarting, card.Team, card.Position))
	case "gargoylehorde":
		g.AddUnit(NewGargoyle(card.IdStarting, card.Team, card.Position, Vector2{0, -2}))
		g.AddUnit(NewGargoyle(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewGargoyle(card.IdStarting+2, card.Team, card.Position, Vector2{-1, -1}))
		g.AddUnit(NewGargoyle(card.IdStarting+3, card.Team, card.Position, Vector2{0, 2}))
		g.AddUnit(NewGargoyle(card.IdStarting+4, card.Team, card.Position, Vector2{1, 1}))
		g.AddUnit(NewGargoyle(card.IdStarting+5, card.Team, card.Position, Vector2{-1, 1}))
	case "gargoyles":
		g.AddUnit(NewGargoyle(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
		g.AddUnit(NewGargoyle(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewGargoyle(card.IdStarting+2, card.Team, card.Position, Vector2{-1, -1}))
	case "berserker":
		g.AddUnit(NewBerserker(card.IdStarting, card.Team, card.Position))
	case "starfire":
		g.AddUnit(NewStarfire(card.IdStarting, card.Team, card.Position, Vector2{0, 0}))
	case "ogre":
		g.AddUnit(NewOgre(card.IdStarting, card.Team, card.Position))
	case "champion":
		g.AddUnit(NewChampion(card.IdStarting, card.Team, card.Position))
	case "pixie":
		g.AddUnit(NewPixie(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
		g.AddUnit(NewPixie(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewPixie(card.IdStarting+2, card.Team, card.Position, Vector2{-1, -1}))
	case "sentry":
		g.AddUnit(NewSentry(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
		g.AddUnit(NewSentry(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewSentry(card.IdStarting+2, card.Team, card.Position, Vector2{-1, -1}))
	case "threestarfire":
		g.AddUnit(NewStarfire(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
		g.AddUnit(NewStarfire(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewStarfire(card.IdStarting+2, card.Team, card.Position, Vector2{-1, -1}))
	case "pixiegeode":
		g.AddUnit(NewPixiegeode(card.IdStarting, card.Team, card.Position))
	case "enforcer":
		g.AddUnit(NewEnforcer(card.IdStarting, card.Team, card.Position))
	case "felhound":
		g.AddUnit(NewFelhound(card.IdStarting, card.Team, card.Position, Vector2{0, 0}))
		g.AddUnit(NewFelhound(card.IdStarting, card.Team, card.Position, Vector2{1, 1}))
		g.AddUnit(NewFelhound(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewFelhound(card.IdStarting+2, card.Team, card.Position, Vector2{-1, 1}))
		g.AddUnit(NewFelhound(card.IdStarting+3, card.Team, card.Position, Vector2{-1, -1}))	
	case "panzerkunstler":
		g.AddUnit(NewPanzerkunstler(card.IdStarting, card.Team, card.Position))
	case "psabu":
		g.AddUnit(NewPsabu(card.IdStarting, card.Team, card.Position))
	case "shadowvision":
		g.AddUnit(NewShadowvision(card.IdStarting, card.Team, card.Position))
	case "trainee":
		g.AddUnit(NewTrainee(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
		g.AddUnit(NewTrainee(card.IdStarting+1, card.Team, card.Position, Vector2{1, -1}))
		g.AddUnit(NewTrainee(card.IdStarting+2, card.Team, card.Position, Vector2{-1, -1}))
	case "wasp":
		g.AddUnit(NewWasp(card.IdStarting, card.Team, card.Position))	
	case "fireball":
		g.AddSpell(NewFireball(card.IdStarting, card.Team, card.Position))
	case "laser":
		g.AddSpell(NewLaser(card.IdStarting, card.Team, card.Position, card.Knight))
	case "freeze":
		g.AddSpell(NewFreeze(card.IdStarting, card.Team, card.Position))
	case "moveknight", "shoot":
		glog.Errorf("unexpected card name : %v", card.Name)
	default:
		glog.Warningf("invalid card name: %v", card.Name)
	}
}

func (g *Game) String() string {
	var home, visitor []string
	for id, player := range g.Players {
		switch player.Team {
		case Home:
			home = append(home, id)
		case Visitor:
			visitor = append(visitor, id)
		}
	}
	return fmt.Sprintf("(%v) VS (%v)", strings.Join(home, " + "), strings.Join(visitor, " + "))
}

func (game *Game) Run(session *Session) {
	glog.Infof("game %v starting", game)
	defer glog.Infof("game %v stopped", game)
	ticker := time.NewTicker(FrameInterval)
	defer ticker.Stop()
	gameover := false
	// send first frame
	session.Broadcast(game)
	for !gameover {
		select {
		case <-ticker.C:
			gameover = game.update()
			session.Broadcast(game)
		case input := <-session.incoming:
			game.apply(input)
		}
	}
	if err := session.Stop(); err != nil {
		panic(err)
	}
}

func (game *Game) update() (gameover bool) {
	game.Frame++
	game.ActivateWaitingCards()
	for _, player := range game.Players {
		player.Update(game)
	}
	game.ActivateWaitingCards()
	for _, unit := range game.Units {
		unit.Update()
	}
	game.RemoveDeadUnits()
	for _, unit := range game.Units {
		unit.ResolveCollision()
	}
	for _, unit := range game.Units {
		unit.Move()
	}
	for _, spell := range game.Spells {
		spell.Update()
	}
	gameover = game.Over()
	if gameover {
		game.Winner = game.GetWinner()
		game.Result = &Result{
			Winner: game.Winner,
			Stats:  game.Stats,
		}
	}
	return
}

func (game *Game) apply(input Input) {
	player := game.Players[input.id]
	if input.Use != 0 {
		player.UseCard(input, game)
	} else {
		player.Move(input)
	}
}

func (game *Game) ActivateWaitingCards() {
	// Filtering without allocating
	// https://github.com/golang/go/wiki/SliceTricks#filtering-without-allocating
	var filtered []*WaitingCard
	for _, card := range game.WaitingCards {
		if card.ActivateFrame == game.Frame {
			game.ActivateCard(card)
			continue
		}
		filtered = append(filtered, card)
	}
	game.WaitingCards = filtered
}
