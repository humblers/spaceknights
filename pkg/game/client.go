package game

import "io"
import "fmt"
import "net"
import "log"
import "sync"
import "time"
import "bufio"

type client struct {
	id     string
	game   *game
	conn   net.Conn
	server *server
	reader *bufio.Reader
	wg     sync.WaitGroup
	logger *log.Logger
}

func newClient(conn net.Conn, s *server, l *log.Logger) *client {
	return &client{
		conn:   conn,
		server: s,
		logger: l,
		reader: bufio.NewReader(conn),
	}
}

func (c *client) run() {
	defer c.closeConn()
	if err := c.auth(); err != nil {
		c.logger.Print(err)
		return
	}
	if err := c.join(); err != nil {
		c.logger.Print(err)
		return
	}
	defer c.leave()
	for {
		if b, err := c.reader.ReadBytes('\n'); err != nil {
			if err == io.EOF {
				break // client disconnected
			}
			if e, ok := err.(net.Error); ok && e.Timeout() {
				break // client.stop() called
			}
			panic(err)
		} else {
			var input Input
			if err := packet(b).parse(&input); err != nil {
				panic(err)
			}
			input.Id = c.id
			if err := c.game.apply(input); err != nil {
				c.logger.Print(err)
				break
			}
		}
	}
}

func (c *client) write(p packet) {
	if _, err := c.conn.Write(p); err != nil {
		if err == io.EOF {
			// client disconnected
			c.logger.Print(err) // just for debugging
			return
		}
		panic(err)
	}
}

func (c *client) stop() {
	if err := c.conn.SetReadDeadline(time.Now()); err != nil {
		panic(err)
	}
}

func (c *client) auth() error {
	p, err := c.readPacket(1 * time.Second)
	if err != nil {
		return err
	}
	var auth Auth
	if err := p.parse(&auth); err != nil {
		return err
	}
	if auth.Id != auth.Token { // fake auth, TODO: implement real auth
		return fmt.Errorf("%v auth failed", c)
	}
	c.id = auth.Id
	return nil
}

func (c *client) join() error {
	p, err := c.readPacket(1 * time.Second)
	if err != nil {
		return err
	}
	var join Join
	if err := p.parse(&join); err != nil {
		return err
	}
	game := c.server.findGame(join.GameId)
	if game == nil {
		return fmt.Errorf("game %v not found", join.GameId)
	}
	if err := game.join(c); err != nil {
		return err
	}
	c.game = game
	return nil
}

func (c *client) leave() {
	if err := c.game.leave(c); err != nil {
		c.logger.Print(err)
	}
}

func (c *client) readPacket(timeout time.Duration) (packet, error) {
	if err := c.conn.SetReadDeadline(time.Now().Add(timeout)); err != nil {
		return nil, err
	}
	if b, err := c.reader.ReadBytes('\n'); err != nil {
		return nil, err
	} else {
		return packet(b), nil
	}
}

func (c *client) closeConn() {
	if err := c.conn.Close(); err != nil {
		panic(err)
	}
}
