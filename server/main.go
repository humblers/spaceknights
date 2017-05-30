package main

import (
    "time"
    "net"
    "log"
    "bufio"
    kcp "github.com/xtaci/kcp-go"
)

type Packet struct {
    client *Client
    data string
}

type Client struct {
    incoming chan string
    outgoing chan string
    reader *bufio.Reader
    writer *bufio.Writer
    conn net.Conn
}

func (client *Client) Read() {
    for {
        client.conn.SetReadDeadline(time.Now().Add(1 * time.Second))
        line, err := client.reader.ReadString('\n')
        if err != nil {
            switch err.(type) {
            case net.Error:
                log.Println("client disconnected")
                // TODO: stop related goroutines and free memories 
                return
            default:
                panic(err)
            }
        }
        client.incoming <- line
    }
}

func (client *Client) Write() {
    for data := range client.outgoing {
        _, err := client.writer.WriteString(data)
        if err != nil {
            panic(err)
        }
        client.writer.Flush()
    }
}

func (client *Client) Listen() {
    go client.Read()
    go client.Write()
}

func NewClient(conn net.Conn) *Client {
    r := bufio.NewReader(conn)
    w := bufio.NewWriter(conn)

    c := &Client{
        incoming: make(chan string),
        outgoing: make(chan string),
        reader: r,
        writer: w,
        conn: conn,
    }

    c.Listen()

    return c
}

type Session struct {
    clients []*Client
    joins chan net.Conn
    incoming chan Packet
    outgoing chan Packet
}

func (session *Session) Broadcast(packet Packet) {
    for _, client := range session.clients {
        if packet.client != client {
            client.outgoing <- packet.data
        }
    }
}

func (session *Session) Join(conn net.Conn) {
    client := NewClient(conn)
    session.clients = append(session.clients, client)
    go func() { for { session.incoming <- Packet{client: client, data: <-client.incoming} } }()
}

func (session *Session) Listen() {
    go func() {
        for {
            select {
            case packet := <-session.incoming:
                session.Broadcast(packet)
            case conn := <-session.joins:
                session.Join(conn)
            }
        }
    }()
}

func NewSession() *Session {
    session := &Session{
        clients: make([]*Client, 0),
        joins: make(chan net.Conn),
        incoming: make(chan Packet),
        outgoing: make(chan Packet),
    }

    session.Listen()

    return session
}

func main() {
    session := NewSession()

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

        session.joins <- conn
    }
}
