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
    Id string
    Move int
}
