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
	Id string
	/*
		Team    string
		Knights []string
		Deck    []string
	*/
}

type Input struct {
	Id    string
	Frame int
	Card  string
	PosX  int
	PosY  int
}

type GameConfig struct {
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
		Deck    []string
	}
	Visitor struct {
		UserId  string
		Knights []string
		Deck    []string
	}
	DoNotCreate bool
}
type LobbyResponse struct {
	Created bool
	Exists  bool
}
