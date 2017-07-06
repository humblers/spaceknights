package main

import (
    "os"
    "bufio"
    kcp "github.com/xtaci/kcp-go"
)

func main() {
    server := NewServer()
    go server.Run()

    go func() {
        reader := bufio.NewReader(os.Stdin)
        for {
            cmd, _ := reader.ReadString('\n')
            if cmd == "start game\n" {
                game := NewGame("alice", "bob")
                session := NewSession("test", game, server)
                go session.Run()
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
