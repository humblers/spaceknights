package restsocket

import (
	"bufio"
	"context"
	"io"
	"log"
	"net/http"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

const (
	writeWait = 10 * time.Second

	maxMessageSize = 512

	closeWriteWait = 10 * time.Second

	readResponseTimeout = 10 * time.Second
)

type mutexWriter struct {
	websocketWriter io.WriteCloser
	mu              *sync.Mutex
}

func newMutexWriter(w io.WriteCloser, m *sync.Mutex) io.WriteCloser {
	return &mutexWriter{
		websocketWriter: w,
		mu:              m,
	}
}

func (w *mutexWriter) Write(p []byte) (int, error) {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.websocketWriter.Write(p)
}

func (w *mutexWriter) Close() error {
	w.mu.Lock()
	defer w.mu.Unlock()
	return w.websocketWriter.Close()
}

type RESTfulConn struct {
	server *RESTfulServer

	UserID      string
	conn        *websocket.Conn
	writerMutex *sync.Mutex

	closeChResp chan bool
	closeChConn chan bool
	once        *sync.Once
	logger      *log.Logger
}

func newRESTfulConn(s *RESTfulServer, wc *websocket.Conn, l *log.Logger) *RESTfulConn {
	rc := &RESTfulConn{
		server:      s,
		conn:        wc,
		once:        &sync.Once{},
		writerMutex: &sync.Mutex{},
		logger:      l,
	}
	wc.SetCloseHandler(rc.closeHandler)
	return rc
}

func (rc *RESTfulConn) ReadJSON(v interface{}) error {
	return rc.conn.ReadJSON(v)
}

func (rc *RESTfulConn) WriteJSON(v interface{}) error {
	return rc.conn.WriteJSON(v)
}

func (rc *RESTfulConn) closeHandler(closeCode int, opt string) error {
	if rc.closeChResp != nil {
		rc.closeChResp <- true
	}

	if rc.closeChConn != nil {
		rc.once.Do(func() { rc.closeChConn <- true })
	}

	rc.server.UnregisterConn(rc)
	message := websocket.FormatCloseMessage(closeCode, opt)
	rc.conn.WriteControl(websocket.CloseMessage, message, time.Now().Add(closeWriteWait))

	return rc.conn.Close()
}

func (rc *RESTfulConn) Close() error {
	return rc.closeHandler(websocket.CloseNormalClosure, "")
}

func (rc *RESTfulConn) Serve() {
	go rc.serve()
}

func (rc *RESTfulConn) serve() {
	ctx, cancelCtx := context.WithCancel(context.Background())
	defer cancelCtx()
	//defer rc.logger.Print("exit rest api serve loop")
	rc.closeChConn = make(chan bool)
	defer close(rc.closeChConn)
	reqCh := make(chan *response)
	defer close(reqCh)
	var wg sync.WaitGroup
	wg.Add(2)
	go func() {
		defer wg.Done()
		for {
			select {
			case <-rc.closeChConn:
				//rc.logger.Printf("exit response loop")
				return
			case resp := <-reqCh:
				go func() {
					rc.server.handler.ServeHTTP(resp, resp.req)
					resp.cancelCtx()
					resp.finishRequest()
				}()
				reqCh <- nil
			}

		}
	}()
	go func() {
		defer wg.Done()
		for {
			resp, err := rc.readRequest(ctx)
			if err != nil {
				//rc.logger.Printf("exit request loop(%v)", err)
				return
			}
			reqCh <- resp
			<-reqCh
		}
	}()
	wg.Wait()
}

// msgType == websocket.messageType
func (rc *RESTfulConn) nextWriter(msgType int) (io.WriteCloser, error) {
	rc.writerMutex.Lock()
	defer rc.writerMutex.Unlock()
	writer, err := rc.conn.NextWriter(msgType)
	if err != nil {
		return nil, err
	}
	return newMutexWriter(writer, rc.writerMutex), nil
}

func (rc *RESTfulConn) readRequest(ctx context.Context) (*response, error) {
	var reader io.Reader
	var err error
	var req *http.Request
	if _, reader, err = rc.conn.NextReader(); err == nil {
		if req, err = http.ReadRequest(bufio.NewReader(reader)); err == nil {
			// replace Header "UID" for easy control
			req.Header.Del("UID")
			req.Header.Add("UID", rc.UserID)

			ctx, cancelCtx := context.WithCancel(ctx)
			req = req.WithContext(ctx)
			w := &response{
				conn:          rc,
				cancelCtx:     cancelCtx,
				req:           req,
				reqBody:       req.Body,
				handlerHeader: make(http.Header),
				contentLength: -1,
			}
			w.cw.res = w
			bufw, _ := rc.nextWriter(websocket.TextMessage)
			w.cw.writer = bufw
			w.w = newBufioWriterSize(&w.cw, bufferBeforeChunkingSize)
			return w, nil
		}
	}
	return nil, err
}
