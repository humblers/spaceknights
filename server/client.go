package main

import (
    "net"
    "bufio"
    "time"
)

type Client struct {
    id string
    conn net.Conn
    incoming chan Packet
    reader *bufio.Reader
    writer *bufio.Writer
}

func NewClient(conn net.Conn) *Client {
    client := &Client{
        id: "",
        conn: conn,
        incoming: make(chan Packet),
        reader: bufio.NewReader(conn),
        writer: bufio.NewWriter(conn),
    }

    go client.listen()
    go client.run()

    return client
}

func (client *Client) run() {
    if !client.auth() {
        client.stop()
        return
    }
    tick := time.Tick(FrameInterval)
    timeout := time.After(PlayTime)
    for {
        select {
        case <-timeout:
            client.stop()
            return
        case <-tick:
            game := games[client.id]
            if game == nil {
                client.stop()
                return
            }
            client.write(NewPacket(game))
        case packet := <-client.incoming:
            game := games[client.id]
            if game == nil {
                client.stop()
                return
            }
            var input Input
            packet.Parse(&input)
            input.id = client.id
            game.inputs <- input
        }
    }
}

func (client *Client) stop() {
    err := client.conn.Close()
    if err != nil {
        panic(err)
    }
}

func (client *Client) listen() {
    for {
        err := client.conn.SetReadDeadline(time.Now().Add(1 * time.Second))
        if err != nil {
            panic(err)
        }
        b, err := client.reader.ReadBytes('\n')
        if err != nil {
            if e, ok := err.(net.Error); ok && e.Timeout() {
                continue    // normal timeout
            }
            panic(err)
        } else {
            client.incoming <- Packet(b)
        }
    }
}

func (client *Client) write(packet Packet) {
    _, err := client.writer.Write([]byte(packet))
    if err != nil {
        panic(err)
    }
    client.writer.Flush()
}

func (client *Client) read(timeout time.Duration) Packet {
    select {
    case <-time.After(timeout):
        return nil
    case packet := <-client.incoming:
        return packet
    }
}

func (client *Client) auth() bool {
    packet := client.read(1 * time.Second)
    var auth Auth
    packet.Parse(&auth)

    // TODO : temporary impl. need to add token creation logic
    if auth.Id != auth.Token {
        client.id = auth.Id
        return true
    }
    return false
}
