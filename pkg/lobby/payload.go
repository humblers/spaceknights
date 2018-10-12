package lobby

import (
	"github.com/humblers/spaceknights/pkg/game"
)

type CommonResponse struct {
	ErrMessage string
}

type LoginRequest struct {
	PType  string
	PID    string
	PToken string
}

type LoginResponse struct {
	ErrMessage string
	User       *user
	UID        string
	Token      string
}

type CardResponse struct {
	ErrMessage string
	Cards      map[string]card
}

type UnitResponse struct {
	ErrMessage string
	Units      map[string]map[string]interface{}
}

type KnightData struct {
	Name  string
	Level int
}

type Deck struct {
	Cards   []game.Card
	Knights []game.KnightData
}

type MatchResponse struct {
	ErrMessage string
	Address    string
	Config     game.Config
}
