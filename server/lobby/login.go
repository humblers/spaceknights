package main

import (
    "errors"
    "net/http"
    "strconv"
    "time"

    "github.com/go-chi/chi"
    "github.com/go-chi/render"
    "github.com/alexedwards/scs/session"
)

func LoginRouter() chi.Router {
    r := chi.NewRouter()
    r.Post("/dev", DevLogin)
    return r
}

type LoginRequest struct {
    ID string `json:"id"`
    Token string `json:"token"`
}

func (a *LoginRequest) Bind(r *http.Request) error {
    return nil
}

type LoginResponse struct {
    ID string `json:"id"`
    Token string `json:"token"`
    //Match **MatchResponse `json:"match,omitempty"`
}

func NewLoginResponse(id string, token string) *LoginResponse {
    resp := &LoginResponse{ID:id, Token:token}
    return resp
}

func (rd *LoginResponse) Render(w http.ResponseWriter, r *http.Request) error {
    session.PutString(r, "id", rd.ID)
    return nil
}

func DevLogin(w http.ResponseWriter, r *http.Request) {
    s_id, _ := session.GetString(r, "id")
    data := &LoginRequest{}
    if err := render.Bind(r, data); err != nil {
        render.Render(w, r, ErrInvalidRequest(err))
        return
    }
    id := data.ID
    if id == "" {
        id = s_id
    }
    if s_id != "" && s_id != id {
        render.Render(w, r, ErrInvalidRequest(errors.New("session id mismatching")))
        return
    }

    token := ""
    if id == "" {
        id = strconv.FormatInt(time.Now().Unix(), 10)
    }

    resp := NewLoginResponse(id, token)
    //match, exist := store.Get(id)
    //if exist {
    //    resp.Match = match.(**MatchResponse)
    //}
    render.Render(w, r, resp)
}