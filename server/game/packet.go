package main

import "encoding/json"

type Packet []byte

func (packet Packet) Parse(out interface{}) error {
    return json.Unmarshal(packet, out)
}

func NewPacket(key string, in interface{}) Packet {
    b, err := json.Marshal(struct {
        Key string
        Value interface{}
    }{
        Key: key,
        Value: in,
    })
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
    SessionId string `json:"sid"`
    UserIds []string `json:"uids"`
}
