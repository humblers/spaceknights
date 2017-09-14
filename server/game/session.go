package main

import (
    "fmt"

    "github.com/golang/glog"
)

type Session struct {
    id string
    server *Server
    clients map[string]*Client
    join chan *Client
    joinResult chan error
    incoming chan Input
    outgoing chan *Game
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
        outgoing: make(chan *Game),
        outgoingResult: make(chan error),
        closing: make(chan struct {}),
    }
    return &session
}

func (session *Session) String() string {
    return session.id
}

func (session *Session) Join(client *Client) error {
    select {
    case <-session.closing:
        return fmt.Errorf("session %v already stopped")
    case session.join <- client:
    }
    return <-session.joinResult
}

func (session *Session) Stop() error {
    if err := session.server.Remove(session); err != nil {
        return err
    }
    close(session.closing)
    return nil
}

func (session *Session) Broadcast(game *Game) error {
    session.outgoing <- game
    return <-session.outgoingResult
}

func (session *Session) Run(game *Game) {
    glog.V(0).Infof("session %v starting", session)
    defer glog.V(0).Infof("session %v stopped", session)

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
        case client := <-session.join:
            if p := game.Player(client.id); p == nil {
                session.joinResult <- fmt.Errorf("player %v not exists", client.id)
            }
            if existing, ok := session.clients[client.id]; ok {
                existing.StopAsync()
            }
            session.clients[client.id] = client
            session.joinResult <- nil
        case game := <-session.outgoing:
            for _, client := range session.clients {
                home := game.Home
                visitor := game.Visitor
                player := game.Player(client.id)
                // filter enemy info
                switch player.Team {
                case Home:
                    game.Visitor = nil
                case Visitor:
                    game.Home = nil;
                }
                client.WriteAsync(NewPacket(game))
                game.Home = home; game.Visitor = visitor
            }
            session.outgoingResult <- nil
        }
    }
}
