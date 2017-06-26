package main

import (
    "os"
    "log"
    "bufio"
    kcp "github.com/xtaci/kcp-go"
)

var games map[string]*Game

func main() {
    go func() {
        reader := bufio.NewReader(os.Stdin)
        for {
            cmd, _ := reader.ReadString('\n')
            if cmd == "start game" {
                NewGame("alice", "bob")
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
        log.Println("new client", conn.RemoteAddr())
        NewClient(conn)
    }
}
