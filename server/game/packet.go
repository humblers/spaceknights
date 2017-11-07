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
    Move      float64
    Use       struct {
        Index int
        Point float64
    }
}

type CreateGame struct {
    SessionId string
    Home struct {
        UserId  string
        Knight  string
        Deck    Cards
    }
    Visitor struct {
        UserId  string
        Knight  string
        Deck    Cards
    }
}
