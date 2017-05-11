package main

import (
    "log"
    kcp "github.com/xtaci/kcp-go"
    "github.com/xtaci/smux"
)

func main() {
    conn, err := kcp.DialWithOptions("127.0.0.1:3824", nil, 10, 3)
    if err != nil {
        panic(err)
    }

    session, err := smux.Client(conn, nil)
    if err != nil {
        panic(err)
    }
    defer session.Close()

    stream, err := session.OpenStream()
    if err != nil {
        panic(err)
    }

    buf := make([]byte, 1024)
    stream.Write([]byte("Hello"))
    stream.Read(buf)
    log.Print(string(buf))
}
