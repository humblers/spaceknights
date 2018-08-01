package game

import "fmt"
import "net"
import "log"
import "time"
import "bufio"

type Client interface {
	Id() string
	Run()
	Stop()
	Write(p packet)
}

type client struct {
	id     string
	game   Game
	conn   net.Conn
	server *server
	reader *bufio.Reader
	logger *log.Logger
}

func newClient(conn net.Conn, s *server, l *log.Logger) Client {
	return &client{
		conn:   conn,
		server: s,
		logger: l,
		reader: bufio.NewReader(conn),
	}
}

func (c *client) Id() string {
	return c.id
}

func (c *client) String() string {
	return fmt.Sprintf("client %v(%v)", c.id, c.conn.RemoteAddr())
}

func (c *client) Run() {
	c.logger.Printf("%v starting", c)
	defer c.logger.Printf("%v stopped", c)
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
	if err := c.conn.SetReadDeadline(time.Time{}); err != nil { // no timeout
		panic(err)
	}
	for {
		if b, err := c.reader.ReadBytes('\n'); err != nil {
			c.logger.Print(err) // for debugging
			break
		} else {
			var input Input
			if err := packet(b).parse(&input); err != nil {
				c.logger.Print(err)
				break
			}
			input.Action.Id = c.id
			if err := c.game.Apply(input); err != nil {
				c.logger.Print(err)
				break
			}
		}
	}
}

func (c *client) Write(p packet) {
	if _, err := c.conn.Write(p); err != nil {
		c.logger.Print(err) // for debugging
		c.Stop()
	}
}

func (c *client) Stop() {
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
	if err := game.Join(c); err != nil {
		return err
	}
	c.game = game
	return nil
}

func (c *client) leave() {
	if err := c.game.Leave(c); err != nil {
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
