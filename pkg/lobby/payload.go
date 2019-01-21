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
	PID        string
	Token      string
}

type DataResponse struct {
	ErrMessage string
	Data       string
}

type MatchResponse struct {
	ErrMessage string
	Config     game.Config
}

type DeckSelectRequest struct {
	Num int
}

type DeckSetRequest struct {
	Num  int
	Deck deck
}

type CardUpgradeRequest struct {
	Name string
}

type CardUpradeResponse struct {
	ErrMessage  string
	Card        card
	Galacticoin int
}

type ChestOpenRequest struct {
	Name    string
	Slot    int
	UseCash bool
}

type ChestOpenResponse struct {
	ErrMessage string
	Gold       int
	Cash       int
	Cards      map[string]int
	OpenedAt   int64
	UsedCash   int
}
