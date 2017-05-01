package main

import (
    "net"
    "log"
    "fmt"
)

func main() {
    pc, err := net.ListenPacket("udp", "127.0.0.1:3824")
    if err != nil {
        log.Fatal(err)
    }
    defer pc.Close()

    buffer := make([]byte, 1024)
    _, addr, err := pc.ReadFrom(buffer)
    fmt.Println(string(buffer))

    pc.WriteTo([]byte("Hi"), addr)
}
