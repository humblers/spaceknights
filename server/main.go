package main

import (
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
}

func (client *Client) Read() {
    for {
        line, _ := client.reader.ReadString('\n')
        client.incoming <- line
    }
}

func (client *Client) Write() {
    for data := range client.outgoing {
        client.writer.WriteString(data)
        client.writer.Flush()
    }
}

func (client *Client) Listen() {
    go client.Read()
    go client.Write()
}

func NewClient(conn *kcp.UDPSession) *Client {
    r := bufio.NewReader(conn)
    w := bufio.NewWriter(conn)

    c := &Client{
        incoming: make(chan string),
        outgoing: make(chan string),
        reader: r,
        writer: w,
    }

    c.Listen()

    return c
}

type Session struct {
    clients []*Client
    joins chan *kcp.UDPSession
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

func (session *Session) Join(conn *kcp.UDPSession) {
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
        joins: make(chan *kcp.UDPSession),
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
