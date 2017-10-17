package main

import (
    "fmt"
    "time"
    "strings"

    "github.com/golang/glog"
)

const (
    PlayTime = time.Minute * 5
    FrameInterval = time.Millisecond * 100
)

const (
    MapWidth = 400
    MapHeight = 560
    TileHeight = 20
)

type Area struct {
    T float64  // Top
    B float64  // Bottom
    L float64  // Left
    R float64  // Right
}
var (
    Top = &Area{0, 260, 0, 400}
    Bottom = &Area{300, 560, 0, 400}
    LeftHole = &Area{260, 300, 60, 80}
    RightHole = &Area{260, 300, 320, 340}
)
var (
    LeftHoleTL = Vector2{LeftHole.L, LeftHole.T}
    LeftHoleTR = Vector2{LeftHole.R, LeftHole.T}
    LeftHoleBL = Vector2{LeftHole.L, LeftHole.B}
    LeftHoleBR = Vector2{LeftHole.R, LeftHole.B}
    RightHoleTL = Vector2{RightHole.L, RightHole.T}
    RightHoleTR = Vector2{RightHole.R, RightHole.T}
    RightHoleBL = Vector2{RightHole.L, RightHole.B}
    RightHoleBR = Vector2{RightHole.R, RightHole.B}
)

func (a *Area) Contains(v Vector2) bool {
    return v.X >= a.L && v.X <= a.R && v.Y >= a.T && v.Y <= a.B
}

type Portal struct {
    Left Vector2
    Right Vector2
}
var (
    TopToLeftHole = &Portal{LeftHoleTR, LeftHoleTL}
    TopToRightHole = &Portal{RightHoleTR, RightHoleTL}
    BottomToLeftHole = &Portal{LeftHoleBL, LeftHoleBR}
    BottomToRightHole = &Portal{RightHoleBL, RightHoleBR}
    LeftHoleToTop = &Portal{LeftHoleTL, LeftHoleTR}
    RightHoleToTop = &Portal{RightHoleTL, RightHoleTR}
    LeftHoleToBottom = &Portal{LeftHoleBR, LeftHoleBL}
    RightHoleToBottom = &Portal{RightHoleBR, RightHoleBL}
)

type Team string
const (
    Home Team = "Home"
    Visitor Team = "Visitor"
    Draw Team = "Draw"  // for game result
)

type Game struct {
    Winner       Team                   `json:",omitempty"`
    Frame        int                    `json:"-"`          // valid only if > 0
    Home         map[string]*Player     `json:",omitempty"`
    Visitor      map[string]*Player     `json:",omitempty"`
    Units        map[int]*Unit
    WaitingCards map[int][]*WaitingCard `json:"-"`          // activate in key frame
    UnitCounter  int                    `json:"-"`
    Motherships  map[Team][]*Unit       `json:"-"`
    Broadcasting chan *Packet           `json:"-"`
}

func NewGame() *Game {
    g := Game{
        Frame:        1,
        Home:         make(map[string]*Player),
        Visitor:      make(map[string]*Player),
        Units:        make(map[int]*Unit),
        WaitingCards: make(map[int][]*WaitingCard),
        UnitCounter:  1,
        Motherships:  make(map[Team][]*Unit),
        Broadcasting: make(chan *Packet),
    }
    g.Motherships[Home] = NewMothership(Home)
    g.Motherships[Visitor] = NewMothership(Visitor)
    for _, u := range g.Motherships[Home] {
        g.AddUnit(u)
    }
    for _, u := range g.Motherships[Visitor] {
        g.AddUnit(u)
    }
    return &g
}

func (game *Game) Score(team Team) int {
    score := 0
    for _, unit := range game.Motherships[team] {
        if unit.IsDead() {
            continue
        }
        switch unit.Name {
        case "maincore":
            score += MaincoreScore
        case "subcore":
            score += SubcoreScore
        }
    }
    return score
}

func (game *Game) Over() bool {
    switch {
    case game.Frame > int(PlayTime/FrameInterval):
        break
    case game.Score(Home) < MaincoreScore:
        break
    case game.Score(Visitor) < MaincoreScore:
        break
    default:
        return false
    }
    return true
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

func (g *Game) Player(id string) *Player {
    if p := g.Home[id]; p != nil {
        return p
    }
    if p:= g.Visitor[id]; p != nil {
        return p
    }
    return nil
}

func (g *Game) Join(team Team, user User) {
    knight := NewKnight(team, user.knightName)
    player := NewPlayer(team, user.deck, knight)
    switch team {
    case Home:
        g.Home[user.id] = player
    case Visitor:
        g.Visitor[user.id] = player
    }
    g.AddUnit(knight)
}

func (g *Game) AddUnit(unit *Unit) {
    if unit.Team == Home {
        unit.FlipY()
        unit.Heading = Vector2{0, -1}
    } else {
        unit.Heading = Vector2{0, 1}
    }
    if unit.Id <= 0 {
        unit.Id = g.UnitCounter
        g.UnitCounter++
    }
    unit.Game = g
    unit.State = Idle
    g.Units[unit.Id] = unit
}

func (g *Game) AddToWaitingCards(card Card, team Team, pos Vector2) {
    frame := g.Frame + ActivateAfter
    waiting := &WaitingCard{
        Name:       card,
        Team:       team,
        Position:   pos,
        IdStarting: g.UnitCounter,
    }
    g.UnitCounter += waiting.GetUnitCount()
    g.WaitingCards[frame] = append(g.WaitingCards[frame], waiting)
    go func() {
        packet := NewPacket("Card", waiting); g.Broadcasting <- &packet
    }()
}

func (g *Game) ActivateCard(card *WaitingCard) {
    switch card.Name {
    case "archers":
        g.AddUnit(NewArcher(card.IdStarting, card.Team, card.Position, Vector2{1, 0}))
        g.AddUnit(NewArcher(card.IdStarting + 1, card.Team, card.Position, Vector2{-1, 0}))
    case "barbarians":
        g.AddUnit(NewBarbarian(card.IdStarting, card.Team, card.Position, Vector2{1, 1}))
        g.AddUnit(NewBarbarian(card.IdStarting + 1, card.Team, card.Position, Vector2{1, -1}))
        g.AddUnit(NewBarbarian(card.IdStarting + 2, card.Team, card.Position, Vector2{-1, 1}))
        g.AddUnit(NewBarbarian(card.IdStarting + 3, card.Team, card.Position, Vector2{-1, -1}))
    case "bomber":
        g.AddUnit(NewBomber(card.IdStarting, card.Team, card.Position))
    case "cannon":
        g.AddUnit(NewCannon(card.IdStarting, card.Team, card.Position))
    case "giant":
        g.AddUnit(NewGiant(card.IdStarting, card.Team, card.Position))
    case "megaminion":
        g.AddUnit(NewMegaminion(card.IdStarting, card.Team, card.Position))
    case "minipekka":
        g.AddUnit(NewMinipekka(card.IdStarting, card.Team, card.Position))
    case "musketeer":
        g.AddUnit(NewMusketeer(card.IdStarting, card.Team, card.Position))
    case "pekka":
        g.AddUnit(NewPekka(card.IdStarting, card.Team, card.Position))
    case "skeletons":
        g.AddUnit(NewSkeleton(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
        g.AddUnit(NewSkeleton(card.IdStarting + 1, card.Team, card.Position, Vector2{1, -1}))
        g.AddUnit(NewSkeleton(card.IdStarting + 2, card.Team, card.Position, Vector2{-1, -1}))
    case "speargoblins":
        g.AddUnit(NewSpeargoblin(card.IdStarting, card.Team, card.Position, Vector2{0, 1}))
        g.AddUnit(NewSpeargoblin(card.IdStarting + 1, card.Team, card.Position, Vector2{1, -1}))
        g.AddUnit(NewSpeargoblin(card.IdStarting + 2, card.Team, card.Position, Vector2{-1, -1}))
    case "valkyrie":
        g.AddUnit(NewValkyrie(card.IdStarting, card.Team, card.Position))
    default:
        glog.Warningf("invalid card name: %v", card.Name)
    }
}

func (g *Game) String() string {
    var h, v []string
    for id, _ := range g.Home {
        h = append(h, id)
    }
    for id, _ := range g.Visitor {
        v = append(v, id)
    }
    return fmt.Sprintf("(%v) VS (%v)", strings.Join(h, " + "), strings.Join(v, " + "))
}

func (game *Game) Run(session *Session) {
    glog.V(0).Infof("game %v starting", game)
    defer glog.V(0).Infof("game %v stopped", game)
    ticker := time.NewTicker(FrameInterval)
    defer ticker.Stop()
    gameover := false
    for ;!gameover; {
        select {
        case <-ticker.C:
            gameover = game.update()
            session.BroadcastGame(game)
        case packet := <-game.Broadcasting:
            session.Broadcast(packet)
        case client := <-session.join:
            if p := game.Player(client.id); p == nil {
                session.joinResult <- fmt.Errorf("player %v not exists", client.id)
                continue
            }
            session.joinResult <- nil
            session.BroadcastGame(game)
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
    for _, player := range game.Home {
        player.IncreaseEnergy(1)
    }
    for _, player := range game.Visitor {
        player.IncreaseEnergy(1)
    }
    for _, card := range game.WaitingCards[game.Frame] {
        game.ActivateCard(card)
    }
    delete(game.WaitingCards, game.Frame)
    for _, unit := range game.Units {
        unit.Update()
    }
    gameover = game.Over()
    if gameover {
        game.Winner = game.GetWinner()
    }
    return
}

func (game *Game) apply(input Input) {
    player := game.Player(input.id)
    if input.Move != 0 {
        player.Move(input.Move)
    } else if input.Use.Index != 0 {
        player.UseCard(input.Use.Index - 1, input.Use.Point, game)
    }
}
