package main

import (
    "os"
    "bufio"
    "math/rand"
    "time"
    kcp "github.com/xtaci/kcp-go"
)

type User struct{
    id string
    knightName string
    deck Cards
}

func main() {
    alice := User{
        id: "alice",
        knightName: "shuriken",
        deck: Cards{
            "archer",
            "babydragon",
            "barbarian",
            "bomber",
            "cannon",
            "giant",
        },
    }
    bob:= User{
        id: "bob",
        knightName: "space_z",
        deck: Cards{
            "archer",
            "babydragon",
            "barbarian",
            "bomber",
            "cannon",
            "giant",
        },
    }
    server := NewServer()
    go server.Run()
    // set default Source for math/rand
    rand.Seed(time.Now().UnixNano())

    go func() {
        reader := bufio.NewReader(os.Stdin)
        for {
            cmd, _ := reader.ReadString('\n')
            if len(cmd) >= 10 && cmd[:10] == "start game" {
                game := NewGame()
                game.Join(Home, alice)
                game.Join(Visitor, bob)
                session := NewSession("test", server)
                go session.Run(game)
                go game.Run(session)
            }
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
        conn.SetNoDelay(1, 20, 2, 1)
        conn.SetStreamMode(false)
        client := NewClient(conn, server)
        go client.Run()
    }
}
