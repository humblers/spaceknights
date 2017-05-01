package main

import (
    "net"
    "log"
    "fmt"
)

func main() {
    conn, err := net.Dial("udp", "127.0.0.1:3824")
    if err != nil {
        log.Fatal(err)
    }
    defer conn.Close()

    conn.Write([]byte("Hello"))

    buffer := make([]byte, 1024)
    conn.Read(buffer)
    fmt.Println(string(buffer))
}
