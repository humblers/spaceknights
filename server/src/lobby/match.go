package main

import (
    "fmt"
    "net/http"
    "strconv"
    "time"

    "github.com/go-chi/chi"
    "github.com/go-chi/chi/render"
    "github.com/alexedwards/scs/session"
)

var input chan chan *MatchResponse


func MatchRouter() chi.Router {
    input = make(chan chan *MatchResponse, 2)

    go func() {
        for {
            c1 := <- input
            c2 := <- input
            fmt.Println("client c1, c2 : ", c1, c2)
            match := &MatchResponse{
                Host : "127.0.0.1",
                SessionID : strconv.FormatInt(time.Now().Unix(), 10),
            }
            c1 <- match
            c2 <- match
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

func NewMatchResponse(match *MatchResponse) *MatchResponse {
    return match
}

func (rd *MatchResponse) Render(w http.ResponseWriter, r *http.Request) error {
    return nil
}

func FindMatch(w http.ResponseWriter, r *http.Request) {
    id, _ := session.GetString(r, "id")
    fmt.Println("cur id : ", id)
    resp := make(chan *MatchResponse)
    input <- resp
    render.Render(w, r, NewMatchResponse(<- resp))
}
