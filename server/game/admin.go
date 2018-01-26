package main

import (
    "net"
    "time"
    "bufio"
    "github.com/golang/glog"
)

type User struct{
    id string
    knights []string
    deck Cards
}

type Admin struct {
    Listener    net.Listener
    Server      *Server
}

func NewAdmin(server *Server) {
    adminListener, err := net.Listen("tcp", ":9989")
    if err != nil {
        panic(err)
    }
    admin := &Admin {
        Listener:   adminListener,
        Server:     server,
    }
    go admin.Run()
}

func (a *Admin) Run() {
    for {
        conn, err := a.Listener.Accept()
        if err != nil {
            continue
        }
        go a.HandleClient(conn)
    }
}

func (a *Admin) HandleClient(conn net.Conn) {
    defer conn.Close()
    if err := conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
        glog.Errorf("read time out : %v", err)
        return
    }
    reader := bufio.NewReader(conn)
    b, _, err := reader.ReadLine()
    if err != nil {
        glog.Errorf("read packet err : %v", err)
        return
    }
    packet := Packet(b)
    var req LobbyRequest
    if err := packet.Parse(&req); err != nil {
        glog.Errorf("parse packet err : %v", err)
        return
    }
    _, exist := a.Server.sessions[req.SessionId]
    resp := LobbyResponse{
        Exists: exist,
    }
    if exist || req.DoNotCreate {
        conn.Write(NewPacket(resp))
        return
    }

    game := NewGame()
    game.Join(Home, User{
        id:         req.Home.UserId,
        knights:    req.Home.Knights,
        deck:       req.Home.Deck,
        //custom deck
        //deck: Cards{ "goblinhut", "skeletons", "speargoblins", "minipekka", "giant", "minipekka", "giant", },
    })
    game.Join(Visitor, User{
        id:         req.Visitor.UserId,
        knights:    req.Visitor.Knights,
        deck:       req.Visitor.Deck,

    })
    session := NewSession(req.SessionId, a.Server)
    go session.Run(game)
    go game.Run(session)
    resp.Created = true
    conn.Write(NewPacket(resp))
}
