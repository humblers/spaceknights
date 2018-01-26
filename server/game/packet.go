package main

import "encoding/json"

type Packet []byte

func (packet Packet) Parse(out interface{}) error {
    return json.Unmarshal(packet, out)
}

func NewPacket(in interface{}) Packet {
    b, err := json.Marshal(in)
    if err != nil {
        panic(err)
    }
    b = append(b, '\n')
    return Packet(b)
}

type Auth struct {
    Id string
    Token string
}

type Join struct {
    SessionId string
}

type Input struct {
    id        string
    Move      int
    Use       int
    Position  Vector2
}

type LobbyRequest struct {
    SessionId   string
    Home struct {
        UserId  string
        Knights []string
        Deck    Cards
    }
    Visitor struct {
        UserId  string
        Knights []string
        Deck    Cards
    }
    DoNotCreate bool
}

type LobbyResponse struct {
    Created bool
    Exists  bool
}
