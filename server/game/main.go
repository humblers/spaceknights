package main

import (
    "flag"
    "math/rand"
    "time"

    "github.com/golang/glog"
    kcp "git.humbler.life/spaceknights/kcp-go"
)

type User struct{
    id string
    knightName string
    deck Cards
}

func main() {
    // for glog flag parsing
    flag.Parse()

    server := NewServer()
    go server.Run()
    // set default Source for math/rand
    rand.Seed(time.Now().UnixNano())

    NewAdmin(server)

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
        conn.SetWindowSize(128, 128)
        conn.SetStreamMode(true)
        conn.SetNoDelay(1, 20, 2, 0)
        client := NewClient(conn, server)
        go client.Run()
    }

    glog.Flush()
}
