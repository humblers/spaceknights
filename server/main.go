package main

import (
    "bufio"
    "math/rand"
    "net"
    "time"

    kcp "github.com/xtaci/kcp-go"
)

type User struct{
    id string
    knightName string
    deck Cards
}

func main() {
    server := NewServer()
    go server.Run()
    // set default Source for math/rand
    rand.Seed(time.Now().UnixNano())

    adminListener, err := net.Listen("tcp", ":9989")
    if err != nil {
        panic(err)
    }
    go func() {
        for {
            conn, err := adminListener.Accept()
            if err != nil {
                continue
            }
            go func() {
                defer conn.Close()
                if err := conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
                    return
                }
                reader := bufio.NewReader(conn)
                for {
                    var packet Packet
                    if b, _, err := reader.ReadLine(); err != nil {
                        continue
                    } else {
                        packet = Packet(b)
                    }
                    var create CreateGame
                    if err := packet.Parse(&create); err != nil {
                        continue
                    }
                    game := NewGame()
                    game.Join(Home, User{
                        id: create.UserIds[0],
                        knightName: "shuriken",
                        deck: Cards{
                            "archer",
                            "babydragon",
                            "barbarian",
                            "bomber",
                            "cannon",
                            "giant",
                        },
                    })
                    game.Join(Visitor, User{
                        id: create.UserIds[0],
                        knightName: "space_z",
                        deck: Cards{
                            "archer",
                            "babydragon",
                            "barbarian",
                            "bomber",
                            "cannon",
                            "giant",
                        },
                    })
                    session := NewSession(create.SessionId, server)
                    go session.Run(game)
                    go game.Run(session)
                    conn.Write([]byte("ok\n"))
                }
            }()
        }
    }()


    listener, err := kcp.ListenWithOptions(":9999", nil, 2, 2)
    if err != nil {
        panic(err)
    }
    listener.SetDSCP(46)
    for {
        conn, err := listener.AcceptKCP()
        if err != nil {
            panic(err)
        }
        conn.SetWindowSize(1024, 1024)
        conn.SetStreamMode(false)
        conn.SetNoDelay(1, 20, 2, 1)
        client := NewClient(conn, server)
        go client.Run()
    }
}
