package restsocket

import (
	"log"
	"net/http"
	"sync"

	"github.com/gorilla/websocket"
)

type userID string

type RESTfulServer struct {
	upgrader    websocket.Upgrader
	connMapLock sync.Mutex
	conns       map[userID]*RESTfulConn
	handler     http.Handler
	logger      *log.Logger
}

func NewRESTfulServer(h http.Handler, l *log.Logger) *RESTfulServer {
	return &RESTfulServer{
		upgrader: websocket.Upgrader{
			ReadBufferSize:  1024,
			WriteBufferSize: 1024,
		},
		conns:   make(map[userID]*RESTfulConn),
		handler: h,
		logger:  l,
	}
}

func (rs *RESTfulServer) Upgrade(w http.ResponseWriter, r *http.Request) (*RESTfulConn, error) {
	rs.logger.Printf("websocket upgrade")
	c, err := rs.upgrader.Upgrade(w, r, nil)
	if err != nil {
		return nil, err
	}

	return newRESTfulConn(rs, c, rs.logger), nil
}

func (rs *RESTfulServer) ConnectionFromID(id string) *RESTfulConn {
	rs.connMapLock.Lock()
	defer rs.connMapLock.Unlock()
	return rs.conns[userID(id)]
}

func (rs *RESTfulServer) RegisterConn(c *RESTfulConn) {
	uid := userID(c.UserID)
	rs.connMapLock.Lock()
	defer rs.connMapLock.Unlock()
	if dup, exists := rs.conns[uid]; exists {
		rs.connMapLock.Unlock()
		dup.Close()
		rs.connMapLock.Lock()
	}
	rs.conns[uid] = c
}

func (rs *RESTfulServer) UnregisterConn(c *RESTfulConn) {
	rs.connMapLock.Lock()
	defer rs.connMapLock.Unlock()
	delete(rs.conns, userID(c.UserID))
}
