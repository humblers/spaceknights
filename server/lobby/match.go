package main

import (
    "bufio"
    "encoding/json"
    "net"
    "net/http"
    "strconv"
    "time"

    "github.com/go-chi/chi"
    "github.com/go-chi/render"
    "github.com/alexedwards/scs/session"
)

type Deck []string

type MatchCandidate struct {
    ID          string
    Deck        Deck
}
type MatchCandidates []*MatchCandidate
func (s MatchCandidates) Filter(f func(*MatchCandidate) bool) MatchCandidates {
    filtered := s[:0]
    for _, x := range s {
        if f(x) {
            filtered = append(filtered, x)
        }
    }
    return filtered
}

type GameSession struct {
    Host        string  `json:"host"`
    SessionID   string  `json:"sid"`
}

type MatchManager struct {
    Find        chan *MatchCandidate
    Cancel      chan string
    Candidates  MatchCandidates
    Games       map[string]*GameSession
}

func (m *MatchManager) Run() {
    for {
        select {
        case candidate := <- m.Find:
            m.Candidates = append(m.Candidates, candidate)
        case id := <- m.Cancel:
            m.Candidates = m.Candidates.Filter(func(x *MatchCandidate) bool { return x.ID != id } )
        default:
            if len(m.Candidates) < 2 {
                continue
            }
            session := &GameSession{
                Host:      "13.125.74.237",
                SessionID: strconv.FormatInt(time.Now().Unix(), 10),
            }
            var c1, c2 *MatchCandidate
            c1, c2, m.Candidates = m.Candidates[0], m.Candidates[1], m.Candidates[2:]
            packet, _ := json.Marshal(map[string]interface{}{
                "SessionId": session.SessionID,
                "Home": map[string]interface{}{
                    "UserId": c1.ID,
                    "Deck": c1.Deck,
                    "Knight": "shuriken",
                },
                "Visitor": map[string]interface{}{
                    "UserId": c2.ID,
                    "Deck": c2.Deck,
                    "Knight": "space_z",
                },
            })
            conn, err := net.Dial("tcp", "127.0.0.1:9989")
            if err == nil {
                conn.Write(packet)
                bufio.NewReader(conn).ReadLine()
                m.Games[c1.ID] = session
                m.Games[c2.ID] = session
            }
        }
    }
}
var manager MatchManager

func MatchRouter() chi.Router {
    manager = MatchManager{
        Find:   make(chan *MatchCandidate),
        Cancel: make(chan string),
        Games:  make(map[string]*GameSession),
    }
    go manager.Run()

    r := chi.NewRouter()
    r.Post("/find", FindMatch)
    return r
}

type FindMatchRequest struct {
    Deck    Deck   `json:"deck"`
}

func (a *FindMatchRequest) Bind(r *http.Request) error {
    return nil
}

type FindMatchResponse struct {
}

func (rd *FindMatchResponse) Render(w http.ResponseWriter, r *http.Request) error {
    return nil
}

func FindMatch(w http.ResponseWriter, r *http.Request) {
    id, _ := session.GetString(r, "id")
    data := &FindMatchRequest{}
    if err := render.Bind(r, data); err != nil {
        render.Render(w, r, ErrInvalidRequest(err))
        return
    }
    manager.Find <- &MatchCandidate{
        ID:             id,
        Deck:           data.Deck,
    }
    render.Render(w, r, &FindMatchResponse{})
}
