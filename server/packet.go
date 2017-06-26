package main

import "encoding/json"

type Packet []byte

func (packet Packet) Parse(out interface{})  {
    err := json.Unmarshal(packet, out)
    if err != nil {
        panic(err)
    }
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

type Input struct {
    id string
    Move int
}
