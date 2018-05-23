package main

import (
	"bufio"
	"net"
	"net/http"
	"strconv"
	"time"

	"github.com/alexedwards/scs/session"
	"github.com/go-chi/chi"
	"github.com/go-chi/render"
	"github.com/golang/glog"
)

type Deck []string

type Candidate struct {
	UserId  string
	Deck    *Deck
	Knights *[]string
}

type Find struct {
	UserId     string
	FindResult chan *Game
}

type MatchManager struct {
	Candidacy  chan *Candidate
	Withdraw   chan string
	FindGame   chan *Find
	Candidates map[string]*Candidate
	Games      map[string]*Game
}

func (m *MatchManager) Run() {
	for {
		select {
		case candidate := <-m.Candidacy:
			m.Candidates[candidate.UserId] = candidate
			if len(m.Candidates) < 2 {
				break
			}
			m.MatchingCandidates()
		case id := <-m.Withdraw:
			delete(m.Candidates, id)
		case find := <-m.FindGame:
			game, exists := m.Games[find.UserId]
			if exists && !m.IsGameRunning(game) {
				delete(m.Games, find.UserId)
				game = nil
			}
			find.FindResult <- game
		}
	}
}

func (m *MatchManager) RequestGameSession(candidates ...*Candidate) bool {
	if len(candidates) < 1 {
		glog.Errorf("at least 1 candidate required")
		return false
	}
	if len(candidates) > 2 {
		glog.Errorf("maximum 2 candidate supported")
		return false
	}
	game := &Game{
		//Host:      "13.125.74.237",
		Host:      "127.0.0.1",
		SessionID: strconv.FormatInt(time.Now().Unix(), 10),
	}
	req := SessionRequest{
		SessionId: game.SessionID,
	}
	for i, candidate := range candidates {
		m.Games[candidate.UserId] = game
		switch i {
		case 0:
			req.Home = *candidate
		case 1:
			req.Visitor = *candidate
		}
	}
	conn, err := net.Dial("tcp", "127.0.0.1:9989")
	if err != nil {
		glog.Errorf("game server connect fail:%v", err)
		return false
	}
	defer conn.Close()
	conn.Write(NewPacket(req))
	if b, _, err := bufio.NewReader(conn).ReadLine(); err == nil {
		packet := Packet(b)
		var resp SessionResponse
		if err := packet.Parse(&resp); err == nil {
			glog.Infof("game session(%v, %v) create req result : %v", game.Host, game.SessionID, resp.Created)
			return resp.Created
		}
	}
	return false
}

func (m *MatchManager) MatchingCandidates() {
	keys := make([]string, 0, 2)
	for key := range m.Candidates {
		keys = append(keys, key)
		if len(keys) >= 2 {
			break
		}
	}
	id1, id2 := keys[0], keys[1]
	if created := m.RequestGameSession(m.Candidates[id1], m.Candidates[id2]); !created {
		delete(m.Games, id1)
		delete(m.Games, id2)
	}
	delete(m.Candidates, id1)
	delete(m.Candidates, id2)
}

func (m *MatchManager) IsGameRunning(game *Game) (res bool) {
	conn, err := net.Dial("tcp", "127.0.0.1:9989")
	if err != nil {
		glog.Errorf("game server connect fail:%v", err)
		return
	}
	defer conn.Close()
	conn.Write(NewPacket(SessionRequest{
		SessionId:   game.SessionID,
		DoNotCreate: true,
	}))
	if err := conn.SetReadDeadline(time.Now().Add(1 * time.Second)); err != nil {
		glog.Errorf("read time out : %v", err)
		return
	}
	b, _, err := bufio.NewReader(conn).ReadLine()
	if err != nil {
		return
	}
	packet := Packet(b)
	var resp SessionResponse
	if err := packet.Parse(&resp); err != nil {
		return
	}
	return resp.Exists
}

var manager MatchManager

func MatchRouter() chi.Router {
	manager = MatchManager{
		Candidacy:  make(chan *Candidate),
		Withdraw:   make(chan string),
		FindGame:   make(chan *Find),
		Candidates: make(map[string]*Candidate),
		Games:      make(map[string]*Game),
	}
	go manager.Run()

	r := chi.NewRouter()
	r.Post("/find", FindGame)
	r.Post("/candidacy", Candidacy)
	r.Post("/instruct", Instruct)
	r.Post("/withdraw", WithDraw)
	return r
}

func (a *Player) Bind(r *http.Request) error {
	return nil
}

func Candidacy(w http.ResponseWriter, r *http.Request) {
	id, _ := session.GetString(r, "id")
	data := &Player{}
	if err := render.Bind(r, data); err != nil {
		render.Render(w, r, ErrInvalidRequest(err))
		return
	}
	manager.Candidacy <- &Candidate{
		UserId:  id,
		Deck:    &data.Deck,
		Knights: &data.Knights,
	}
	render.Render(w, r, &CommonSuccess{})
}

func Instruct(w http.ResponseWriter, r *http.Request) {
	id, _ := session.GetString(r, "id")
	data := &Player{}
	if err := render.Bind(r, data); err != nil {
		render.Render(w, r, ErrInvalidRequest(err))
		return
	}
	manager.RequestGameSession(&Candidate{
		UserId:  id,
		Deck:    &data.Deck,
		Knights: &data.Knights,
	})
	render.Render(w, r, &CommonSuccess{})
}

func WithDraw(w http.ResponseWriter, r *http.Request) {
	id, _ := session.GetString(r, "id")
	manager.Withdraw <- id
	render.Render(w, r, &CommonSuccess{})
}

func (rd *Game) Render(w http.ResponseWriter, r *http.Request) error {
	return nil
}

func FindGame(w http.ResponseWriter, r *http.Request) {
	id, _ := session.GetString(r, "id")
	result := make(chan *Game)
	manager.FindGame <- &Find{
		UserId:     id,
		FindResult: result,
	}
	game := <-result
	if game != nil {
		render.Render(w, r, game)
		return
	}
	render.Render(w, r, ErrNotFound)
}
