package game

import "encoding/json"

type packet []byte

func (p packet) parse(out interface{}) error {
	return json.Unmarshal(p, out)
}

func newPacket(in interface{}) packet {
	b, err := json.Marshal(in)
	if err != nil {
		panic(err)
	}
	b = append(b, '\n')
	return packet(b)
}

type Auth struct {
	Id    string
	Token string
}

type Join struct {
	GameId string
}

type Player struct {
	Id   string
	Team Team
	Deck []Card
}

type Input struct {
	Step   int
	Action Action
}

type Action struct {
	Id      string
	Card    Card
	PosX    int
	PosY    int
	Message string // for emoticon
}

type Card struct {
	Name  string
	Level int
}

type State struct {
	Step    int
	Actions []Action
	Hash    uint32
}

type Config struct {
	Id      string
	MapName string
	Players []Player
}

//// temporary
type LobbyRequest struct {
	SessionId string
	Home      struct {
		UserId  string
		Knights []string
		Deck    []Card
	}
	Visitor struct {
		UserId  string
		Knights []string
		Deck    []Card
	}
	DoNotCreate bool
}
type LobbyResponse struct {
	Created bool
	Exists  bool
}
