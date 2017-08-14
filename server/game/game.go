package main

import (
    "fmt"
    "log"
    "time"
    "strings"
)

const (
    PlayTime = 1 * time.Minute
    FrameInterval = time.Millisecond * 100
)

const (
    MapWidth = 400
    MapHeight = 560
    TileHeight = 20
)

type Team string
const (
    Home Team = "Home"
    Visitor Team = "Visitor"
)

type Layer string
const (
    Ground Layer = "Ground"
    Air Layer = "Air"
)

type Game struct {
    Frame int `json:"-"`
    Home map[string]*Player `json:",omitempty"`
    Visitor map[string]*Player `json:",omitempty"`
    Units map[int]*Unit
    UnitCounter int `json:"-"`
    Motherships map[Team][]*Unit `json:"-"`
}

func NewGame() *Game {
    g := Game{
        Frame: 0,
        Home: make(map[string]*Player),
        Visitor: make(map[string]*Player),
        Units: make(map[int]*Unit),
        UnitCounter: 0,
        Motherships: make(map[Team][]*Unit),
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

func (g *Game) IsOver() bool {
    if g.Frame > int(PlayTime/FrameInterval) {
        return true
    }
    for _, m := range g.Motherships {
        for _, u := range m {
            if u.Name == "maincore" && u.IsDead() {
                return true
            }
        }
    }
    return false
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
    }
    unit.Id = g.UnitCounter
    unit.Game = g
    g.Units[g.UnitCounter] = unit
    g.UnitCounter++
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
    log.Printf("game %v starting", game)
    defer log.Printf("game %v stopped", game)
    tick := time.Tick(FrameInterval)
    over := make(chan struct {})
    for {
        if game.IsOver() {
            if err := session.Stop(); err != nil {
                panic(err)
            }
            break
        }
        select {
        case <-tick:
            game.update(over)
            session.Broadcast(game)
        case input := <-session.incoming:
            game.apply(input)
        }
    }
}

func (game *Game) update(over chan<- struct{}) {
    game.Frame++
    for _, player := range game.Home {
        player.IncreaseEnergy(1)
    }
    for _, player := range game.Visitor {
        player.IncreaseEnergy(1)
    }
    for _, unit := range game.Units {
        unit.Update()
    }
}

func (game *Game) apply(input Input) {
    player := game.Player(input.id)
    if input.Move != 0 {
        player.Move(input.Move)
    } else if input.Use != 0 {
        player.UseCard(input.Use - 1, game)
    }
}
