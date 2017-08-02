package main

import (
    "bufio"
    "encoding/json"
    "fmt"
    "net"
    "net/http"
    "strconv"
    "time"

    "github.com/go-chi/chi"
    "github.com/go-chi/chi/render"
    "github.com/alexedwards/scs/session"
)

type Wait struct {
    ID string
    Resp chan *MatchResponse
}
var match chan Wait


func MatchRouter() chi.Router {
    match = make(chan Wait, 2)

    go func() {
        for {
            c1 := <- match
            c2 := <- match
            match := &MatchResponse{
                Host:      "127.0.0.1",
                SessionID: strconv.FormatInt(time.Now().Unix(), 10),
            }
            ids := []string{c1.ID, c2.ID}
            packet, _ := json.Marshal(map[string]interface{}{
                "sid":  match.SessionID,
                "uids": ids,
            })
            conn, _ := net.Dial("tcp", "127.0.0.1:9989")
            conn.Write(packet)
            bufio.NewReader(conn).ReadLine()
            c1.Resp <- match
            c2.Resp <- match
        }
    }()

    r := chi.NewRouter()
    r.Post("/find", FindMatch)
    return r
}

type MatchResponse struct {
    Host string `json:"host"`
    SessionID string `json:"sid"`
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
    fmt.Println("cur id : ", id)
    resp := make(chan *MatchResponse)
    match <- Wait{
        ID: id,
        Resp: resp,
    }
    render.Render(w, r, NewMatchResponse(id, <- resp))
}
