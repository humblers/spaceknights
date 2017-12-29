package main

import (
    "flag"
    "time"
    "net"
    "math/rand"

    "github.com/golang/glog"
)

func main() {
    // for glog flag parsing
    flag.Parse()

    server := NewServer()
    go server.Run()
    // set default Source for math/rand
    rand.Seed(time.Now().UnixNano())

    NewAdmin(server)

    listener, err := net.Listen("tcp", ":9999")
    if err != nil {
        panic(err)
    }
    for {
        conn, err := listener.Accept()
        if err != nil {
            panic(err)
        }
        client := NewClient(conn, server)
        go client.Run()
    }

    glog.Flush()
}
