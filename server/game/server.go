package main

import (
    "fmt"

    "github.com/golang/glog"
)

type GetResult struct {
    session *Session
    err error
}

type Server struct {
    get chan string
    add chan *Session
    rem chan *Session
    getResult chan GetResult
    addResult chan error
    remResult chan error
    sessions map[string]*Session
}

func NewServer() *Server {
    server := Server{
        get: make(chan string),
        add: make(chan *Session),
        rem: make(chan *Session),
        getResult: make(chan GetResult),
        addResult: make(chan error),
        remResult: make(chan error),
        sessions: make(map[string]*Session),
    }
    return &server
}

func (server *Server) Get(id string) (*Session, error) {
    server.get <- id
    result := <-server.getResult
    return result.session, result.err
}

func (server *Server) Add(session *Session) error {
    defer glog.Infof("session %v added to server", session)
    server.add <- session
    return <-server.addResult
}

func (server *Server) Remove(session *Session) error {
    defer glog.Infof("session %v removed from server", session)
    server.rem <- session
    return <-server.remResult
}

func (server *Server) Run() {
    glog.Infof("server starting")
    defer glog.Infof("server stopped")

    for {
        select {
        case id := <-server.get:
            res := GetResult{}
            if session, ok := server.sessions[id]; !ok {
                res.err = fmt.Errorf("session %v not found", id)
            } else {
                res.session = session
            }
            server.getResult <- res
        case session := <-server.add:
            var err error
            if server.sessions[session.id] != nil {
                err = fmt.Errorf("session %v already exists", session.id)
            } else {
                server.sessions[session.id] = session
            }
            server.addResult <- err
        case session := <-server.rem:
            var err error
            if server.sessions[session.id] == nil {
                err = fmt.Errorf("session %v not found", session.id)
            } else {
                delete(server.sessions, session.id)
            }
            server.remResult <- err
        }
    }
}
