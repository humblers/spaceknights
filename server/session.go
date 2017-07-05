package main

import (
    "fmt"
)

type Session struct {
    id string
    game *Game
    server *Server
    clients map[string]*Client
    join chan *Client
    joinResult chan error
    incoming chan Input
    outgoing chan Packet
    closing chan struct{}
}

func NewSession(id string, game *Game, server *Server) *Session {
    session := Session{
        id: id,
        game: game,
        server: server,
        clients: make(map[string]*Client),
        join: make(chan *Client),
        joinResult: make(chan error),
        incoming: make(chan Input),
        outgoing: make(chan Packet),
        closing: make(chan struct {}),
    }
    return &session
}

func (session *Session) Join(client *Client) error {
    select {
    case <-session.closing:
        return fmt.Errorf("session %v already stopped", session.id)
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

func (session *Session) Run() {
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
            if _, ok := session.game.Players[client.id]; !ok {
                session.joinResult <- fmt.Errorf("player %v not exists", client.id)
            }
            if existing, ok := session.clients[client.id]; ok {
                existing.StopAsync()
            }
            session.clients[client.id] = client
            session.joinResult <- nil
        case packet := <-session.outgoing:
            for _, client := range session.clients {
                client.WriteAsync(packet)
            }
        }
    }
}
