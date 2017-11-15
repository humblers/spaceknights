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

type Game struct {
    Host        string  `json:"host"`
    SessionID   string  `json:"sid"`
}

type SessionRequest struct {
    SessionId   string
    Home        Candidate
    Visitor     Candidate
    DoNotCreate bool
}

type SessionResponse struct {
    Created bool
    Exists  bool
}