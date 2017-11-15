package main

import (
    "bufio"
    "net"
    "net/http"
    "strconv"
    "time"

    "github.com/go-chi/chi"
    "github.com/go-chi/render"
    "github.com/alexedwards/scs/session"
    "github.com/golang/glog"
)

type Deck []string

type Candidate struct {
    UserId string
    Deck   *Deck
    Knight string
}

type Find struct {
    UserId     string
    FindResult chan *Game
}

type MatchManager struct {
    Candidacy  chan *Candidate
    Withdraw   chan string
    FindGame   chan *Find
    Candidates map[string]*Deck
    Games      map[string]*Game
}

func (m *MatchManager) Run() {
    for {
        select {
        case candidate := <- m.Candidacy:
            m.Candidates[candidate.UserId] = candidate.Deck
            if len(m.Candidates) < 2 {
                break
            }
            m.MatchingCandidates()
        case id := <- m.Withdraw:
            delete(m.Candidates, id)
        case find := <- m.FindGame:
            game, exists := m.Games[find.UserId]
            if exists && !m.IsGameRunning(game) {
                delete(m.Games, find.UserId)
                game = nil
            }
            find.FindResult <- game
        }
    }
}

func (m *MatchManager) MatchingCandidates() {
    keys := make([]string, 0, 2)
    for key := range m.Candidates {
        keys = append(keys, key)
        if len(keys) >= 2{
            break
        }
    }
    c1, c2 := keys[0], keys[1]
    d1, d2 := m.Candidates[c1], m.Candidates[c2]
    session := &Game{
        Host:      "13.125.74.237",
		//Host:      "127.0.0.1",
        SessionID: strconv.FormatInt(time.Now().Unix(), 10),
    }
    m.Games[c1] = session; m.Games[c2] = session
    delete(m.Candidates, c1); delete(m.Candidates, c2)

    conn, err := net.Dial("tcp", "127.0.0.1:9989")
    if err != nil {
        glog.Errorf("game server connect fail:%v", err)
        return
    }
    defer conn.Close()
    conn.Write(NewPacket(SessionRequest{
        SessionId: session.SessionID,
        Home: Candidate{
            UserId: c1,
            Deck:   d1,
            Knight: "shuriken",
        },
        Visitor: Candidate{
            UserId: c2,
            Deck:   d2,
            Knight: "space_z",
        },
    }))
    var created bool
    if b, _, err := bufio.NewReader(conn).ReadLine(); err == nil {
        packet := Packet(b)
        var resp SessionResponse
        if err := packet.Parse(&resp); err == nil {
            created = resp.Created
            glog.Infof("game session(%v, %v) create req result : %v", session.Host, session.SessionID, created)
        }
    }
    if !created {
        delete(m.Games, c1); delete(m.Games, c2)
    }
}

func (m *MatchManager) IsGameRunning(game *Game) (res bool){
    conn, err := net.Dial("tcp", "127.0.0.1:9989")
    if err != nil {
        glog.Errorf("game server connect fail:%v", err)
        return
    }
    defer conn.Close()
    conn.Write(NewPacket(SessionRequest{
        SessionId:      game.SessionID,
        DoNotCreate:    true,
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
        Candidates: make(map[string]*Deck),
        Games:      make(map[string]*Game),
    }
    go manager.Run()

    r := chi.NewRouter()
    r.Post("/find", FindGame)
    r.Post("/candidacy", Candidacy)
    r.Post("/withdraw", WithDraw)
    return r
}

type CandidacyRequest struct {
    Deck    Deck   `json:"deck"`
}

func (a *CandidacyRequest) Bind(r *http.Request) error {
    return nil
}

func Candidacy(w http.ResponseWriter, r *http.Request) {
    id, _ := session.GetString(r, "id")
    data := &CandidacyRequest{}
    if err := render.Bind(r, data); err != nil {
        render.Render(w, r, ErrInvalidRequest(err))
        return
    }
    manager.Candidacy <- &Candidate{
        UserId: id,
        Deck:   &data.Deck,
    }
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
    game := <- result
    if game != nil {
        render.Render(w, r, game)
        return
    }
    render.Render(w, r, ErrNotFound)
}