package lobby

import (
	"encoding/json"
	"log"
	"net/http"
	"net/url"
	"os"
	"testing"
	"time"

	"github.com/gomodule/redigo/redis"
	"github.com/humblers/spaceknights/pkg/restsocket"
	wsclient "github.com/paper-vessel/websocket-testing"
	uuid "github.com/satori/go.uuid"
	"github.com/stretchr/testify/assert"
)

var (
	socketserver *restsocket.RESTfulServer
	socketclient *wsclient.WebsocketClient
	done         chan struct{}
	debugCh      = make(chan string)
)

func startSocketServer() *restsocket.RESTfulServer {
	logger := log.New(os.Stderr, "", log.Ldate|log.Ltime|log.Lshortfile)

	p := &redis.Pool{
		Dial: func() (redis.Conn, error) {
			c, err := redis.Dial("tcp", ":6379")
			if err != nil {
				return nil, err
			}
			return c, nil
		},

		MaxIdle:     3,
		IdleTimeout: 240 * time.Second,
	}

	m := http.NewServeMux()
	server := restsocket.NewRESTfulServer(m, logger)
	AuthRouter("/auth", server, m, p, logger)

	go http.ListenAndServe("127.0.0.1:9090", m)
	return server
}

func TestMain(m *testing.M) {
	socketserver = startSocketServer()
	u, _ := url.Parse("ws://localhost:9090/auth/login")
	opts := wsclient.SocketClientOpts{
		URL:       u,
		KeepAlive: false,
	}
	socketclient = wsclient.NewWebSocketClient(opts)
	code := m.Run()
	os.Exit(code)
}

func TestLogoutHandlerSuccess(t *testing.T) {
	socketclient.LoginRequest = &wsclient.LoginRequest{
		PType: "dev",
		PID:   "",
	}
	for i := 0; i < 4; i++ {
		err := socketclient.Connect()
		assert.Nil(t, err)

		req, _ := http.NewRequest(http.MethodPost, "ws://localhost:9090/auth/logout", nil)
		uid, _ := uuid.NewV4()
		cid := uid.String()
		req.Header.Set("X-Correlation-Id", cid)
		err = socketclient.Connection().WriteRequest(req)
		assert.Nil(t, err)
		resp, err := socketclient.Connection().ReadResponse()
		assert.Nil(t, err)
		assert.NotNil(t, resp)
		assert.Equal(t, cid, resp.Header.Get("X-Correlation-Id"))
		defer resp.Body.Close()
		assert.Nil(t, err)
		dec := json.NewDecoder(resp.Body)
		var res CommonResponse
		dec.Decode(&res)
		assert.Equal(t, CommonResponse{}, res)

		socketclient.Connection().Close()
	}
}
