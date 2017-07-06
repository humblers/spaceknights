package main

import (
    "fmt"
    "net/http"

    "github.com/go-chi/chi"
    "github.com/alexedwards/scs/session"
)

func MatchRouter() chi.Router {
    r := chi.NewRouter()
    r.Post("/find", FindMatch)
    return r
}

func FindMatch(w http.ResponseWriter, r *http.Request) {
    s_id, _ := session.GetString(r, "id")
    fmt.Println("cur id : ", s_id)
}
