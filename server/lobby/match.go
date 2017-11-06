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

type Wait struct {
    ID          string
    Deck        Deck
    RespChannel chan *MatchResponse
}
var match chan Wait


func MatchRouter() chi.Router {
    match = make(chan Wait, 2)

    go func() {
        for {
            c1 := <- match
            c2 := <- match
            resp := &MatchResponse{
                Host:      "127.0.0.1",
                SessionID: strconv.FormatInt(time.Now().Unix(), 10),
            }
            packet, _ := json.Marshal(map[string]interface{}{
                "SessionId": resp.SessionID,
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
            }
            resp.Error = err
            c1.RespChannel <- resp
            c2.RespChannel <- resp
        }
    }()

    r := chi.NewRouter()
    r.Post("/find", FindMatch)
    return r
}

type MatchRequest struct {
    Deck    Deck   `json:"deck"`
}

func (a *MatchRequest) Bind(r *http.Request) error {
    return nil
}

type MatchResponse struct {
    Host        string  `json:"host"`
    SessionID   string  `json:"sid"`
    Error       error   `json:"-"`
}

func NewMatchResponse(id string, match *MatchResponse) *MatchResponse {
    store.Add(id, &match, 0)
    return match
}

func (rd *MatchResponse) Render(w http.ResponseWriter, r *http.Request) error {
    return nil
}

func FindMatch(w http.ResponseWriter, r *http.Request) {
    id, _ := session.GetString(r, "id")
    data := &MatchRequest{}
    if err := render.Bind(r, data); err != nil {
        render.Render(w, r, ErrInvalidRequest(err))
        return
    }
    respChan := make(chan *MatchResponse)
    match <- Wait{
        ID:             id,
        Deck:           data.Deck,
        RespChannel:    respChan,
    }
    resp := <-respChan
    if resp.Error != nil {
        render.Render(w, r, ErrRender(resp.Error))
        return
    }
    render.Render(w, r, NewMatchResponse(id, resp))
}
