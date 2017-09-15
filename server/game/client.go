package main

import (
    "fmt"
    "net"
    "bufio"
    "time"
    "sync"

    "github.com/golang/glog"
)

type Client struct {
    id string
    session *Session
    conn net.Conn
    server *Server
    reader *bufio.Reader
    writer *bufio.Writer
    outgoing chan Packet
    closing chan struct{}
    loop sync.WaitGroup
}

func NewClient(conn net.Conn, server *Server) *Client {
    client := Client{
        conn: conn,
        server: server,
        reader: bufio.NewReader(conn),
        writer: bufio.NewWriter(conn),
        outgoing: make(chan Packet),
        closing: make(chan struct{}),
    }
    return &client
}

func (client *Client) String() string {
    return fmt.Sprintf("%v(%v)", client.id, client.conn.RemoteAddr())
}

func (client *Client) Run() {
    glog.V(0).Infof("client %v starting", client)
    defer client.closeConn()

    if err := client.auth(); err != nil {
        glog.Errorf(err.Error())
        return
    }

    if err:= client.join(); err != nil {
        panic(err)
    }

    client.loop.Add(2)
    go client.readLoop()
    go client.writeLoop()
    client.loop.Wait()

    glog.V(0).Infof("client %v stopped", client)
}

func (client *Client) WriteAsync(packet Packet) {
    select {
    case client.outgoing <- packet:
    default:
        glog.Warningf("WARNING: client %v outgoing channel blocked", client)
    }
}

func (client *Client) StopAsync() {
    close(client.closing)
}

func (client *Client) readLoop() {
    defer client.loop.Done()
    for {
        packet, err := client.read(1 * time.Second)
        if err != nil {
            if e, ok := err.(net.Error); ok && e.Timeout() {
                select {
                case <-client.closing:
                    return
                default:
                    continue    // normal timeout
                }
            }
            panic(err)
        }

        var input Input
        if err := packet.Parse(&input); err != nil {
            panic(err)
        }
        input.id = client.id

        select {
        case <-client.closing:
            return
        case client.session.incoming <- input:
        }
    }
}

func (client *Client) writeLoop() {
    defer client.loop.Done()
    for {
        select {
        case <-client.closing:
            return
        case packet := <-client.outgoing:
            if err := client.write(packet, 1 * time.Second); err != nil {
                panic(err)
            }
        }
    }
}

func (client *Client) read(timeout time.Duration) (Packet, error) {
    if err := client.conn.SetReadDeadline(time.Now().Add(timeout)); err != nil {
        return nil, err
    }
    if b, err := client.reader.ReadBytes('\n'); err != nil {
        return nil, err
    } else {
        return Packet(b), nil
    }
}

func (client *Client) write(packet Packet, timeout time.Duration) error {
    if err := client.conn.SetWriteDeadline(time.Now().Add(timeout)); err != nil {
        return err
    }
    if _, err := client.writer.Write(packet); err != nil {
        return err
    }
    if err := client.writer.Flush(); err != nil {
        return err
    }
    return nil
}

func (client *Client) auth() error {
    packet, err := client.read(1 * time.Second)
    if err != nil {
        return err
    }
    var auth Auth
    if err := packet.Parse(&auth); err != nil {
        return err
    }
    if auth.Id != auth.Token {  // TODO: implement real auth
        return fmt.Errorf("client %v auth failed", client)
    }
    client.id = auth.Id
    glog.V(0).Infof("client %v authenticated", client)
    return nil
}

func (client *Client) join() error {
    packet, err := client.read(1 * time.Second)
    if err != nil {
        return err
    }
    var join Join
    if err := packet.Parse(&join); err != nil {
        return err
    }
    session, err := client.server.Get(join.SessionId)
    if err != nil {
        return err
    }
    if err := session.Join(client); err != nil {
        return err
    }
    client.session = session
    glog.V(0).Infof("client %v joined to session %v", client, session)
    return nil
}

func (client *Client) closeConn() {
    if err := client.conn.Close(); err != nil {
        panic(err)
    }
}
