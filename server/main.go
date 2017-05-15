package main

import (
    "fmt"
    kcp "github.com/xtaci/kcp-go"
)

func main() {
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
        go handleClient(conn)
    }
}

func handleClient(conn *kcp.UDPSession) {
	conn.SetWindowSize(1024, 1024)
	conn.SetNoDelay(1, 20, 2, 1)
	conn.SetStreamMode(false)
	fmt.Println("new client", conn.RemoteAddr())
	buf := make([]byte, 65536)
	count := 0
	for {
		n, err := conn.Read(buf)
		if err != nil {
			panic(err)
		}
		count++
		fmt.Println("received:", string(buf[:n]))
		conn.Write(buf[:n])
	}
}
