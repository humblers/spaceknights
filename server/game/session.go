package main

import (
    "fmt"

    "github.com/golang/glog"
)

type OutGoing struct {
    Client *Client
    Packet *Packet
}

type Session struct {
    id string
    server *Server
    clients map[string]*Client
    join chan *Client
    joinResult chan error
    incoming chan Input
    outgoing chan OutGoing
    outgoingResult chan error
    closing chan struct{}
}

func NewSession(id string, server *Server) *Session {
    session := Session{
        id: id,
        server: server,
        clients: make(map[string]*Client),
        join: make(chan *Client),
        joinResult: make(chan error),
        incoming: make(chan Input),
        outgoing: make(chan OutGoing),
        outgoingResult: make(chan error),
        closing: make(chan struct {}),
    }
    return &session
}

func (session *Session) String() string {
    return session.id
}

func (session *Session) Join(client *Client) (err error) {
    select {
    case <-session.closing:
        err = fmt.Errorf("session %v already stopped"); return
    case session.join <- client:
    }
    if err = <-session.joinResult; err != nil {
        return
    }
    if existing, ok := session.clients[client.id]; ok {
        existing.StopAsync()
    }
    session.clients[client.id] = client
    return
}

func (session *Session) Stop() error {
    if err := session.server.Remove(session); err != nil {
        return err
    }
    close(session.closing)
    return nil
}
func (session *Session) Broadcast(packet *Packet) (err error) {
    for _, client := range session.clients {
        session.outgoing <- OutGoing{client, packet}
        if err = <- session.outgoingResult; err != nil {
            return
        }
    }
    return
}

func (session *Session) BroadcastGame(game *Game) (err error) {
    for _, client := range session.clients {
        home := game.Home
        visitor := game.Visitor
        player := game.Player(client.id)
        // filter enemy info
        switch player.Team {
        case Home:
            game.Visitor = nil
        case Visitor:
            game.Home = nil
        }
        packet := NewPacket("Game", game)
        session.outgoing <- OutGoing{client, &packet}
        game.Home = home; game.Visitor = visitor
        if err = <-session.outgoingResult; err != nil {
            return
        }
    }
    return
}

func (session *Session) Run() {
    glog.Infof("session %v starting", session)
    defer glog.Infof("session %v stopped", session)

    if err := session.server.Add(session); err != nil {
        panic(err)
    }

    for {
        select {
        case <-session.closing:
            for _, client := range session.clients {
                client.StopAsync()
            }
            return
        case outgoing := <-session.outgoing:
            outgoing.Client.WriteAsync(*outgoing.Packet)
            session.outgoingResult <- nil
        }
    }
}
