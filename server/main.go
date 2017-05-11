package main

import (
    "io"
    "log"
    kcp "github.com/xtaci/kcp-go"
    "github.com/xtaci/smux"
)

func main() {
    listener, err := kcp.ListenWithOptions(":3824", nil, 10, 3)
    if err != nil {
        panic(err)
    }

    for {
        conn, err := listener.AcceptKCP()
        if err != nil {
            panic(err)
        }
        go handleMux(conn)
    }
}

func handleMux(conn io.ReadWriteCloser) {
    session, err := smux.Server(conn, nil)
    if err != nil {
        panic(err)
    }
    defer session.Close()

    stream, err := session.AcceptStream()
    if err != nil {
        panic(err)
    }

    buf := make([]byte, 1024)
    stream.Read(buf)
    stream.Write(buf)
    log.Print(string(buf))
}
