package main

import (
	"fmt"

	"github.com/golang/glog"
)

type Session struct {
	id             string
	server         *Server
	clients        map[string]*Client
	join           chan *Client
	joinResult     chan error
	leave          chan *Client
	incoming       chan Input
	outgoing       chan *Game
	outgoingResult chan error
	closing        chan struct{}
}

func NewSession(id string, server *Server) *Session {
	session := Session{
		id:             id,
		server:         server,
		clients:        make(map[string]*Client),
		join:           make(chan *Client),
		joinResult:     make(chan error),
		leave:          make(chan *Client),
		incoming:       make(chan Input),
		outgoing:       make(chan *Game),
		outgoingResult: make(chan error),
		closing:        make(chan struct{}),
	}
	return &session
}

func (session *Session) String() string {
	return session.id
}

func (session *Session) Join(client *Client) error {
	select {
	case <-session.closing:
		return fmt.Errorf("session %v already stopped", session)
	case session.join <- client:
	}
	return <-session.joinResult
}

func (session *Session) Leave(client *Client) {
	select {
	case <-session.closing:
	case session.leave <- client:
	}
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

func (session *Session) Send(input Input) {
	select {
	case <-session.closing:
	case session.incoming <- input:
	}
}

func (session *Session) Run(game *Game) {
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
		case client := <-session.join:
			if _, ok := game.Players[client.id]; !ok {
				session.joinResult <- fmt.Errorf("player %v not exists", client.id)
			}
			if existing, ok := session.clients[client.id]; ok {
				existing.StopAsync()
			}
			session.clients[client.id] = client
			session.joinResult <- nil
		case client := <-session.leave:
			delete(session.clients, client.id)
			client.StopAsync()
		case game := <-session.outgoing:
			for _, client := range session.clients {
				players := game.Players
				me := game.Players[client.id]
				game.Players = game.Players.Filter(
					func(p *Player) bool {
						return p.Team == me.Team
					})
				client.WriteAsync(NewPacket(game))
				game.Players = players
			}
			session.outgoingResult <- nil
		}
	}
}
