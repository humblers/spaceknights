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

type DataResponse struct {
	ErrMessage string
	Data       map[string]string
}

type MatchResponse struct {
	ErrMessage string
	Address    string
	Config     game.Config
}

type DeckChangeRequest struct {
	Num int
}
