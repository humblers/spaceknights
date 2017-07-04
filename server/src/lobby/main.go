package main

import (
    "errors"
    "flag"
    "fmt"
    "net/http"
    "strconv"
    "time"

    "github.com/alexedwards/scs/session"
    "github.com/alexedwards/scs/engine/memstore"

    "github.com/go-chi/chi"
    "github.com/go-chi/chi/docgen"
    "github.com/go-chi/chi/middleware"
    "github.com/go-chi/chi/render"
)

var routes = flag.Bool("routes", false, "Generate router documentation")

func main() {
    flag.Parse()

    r := chi.NewRouter()

    r.Use(middleware.RequestID)
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)

    e := memstore.New(0)
    r.Use(session.Manage(e))

    r.Use(render.SetContentType(render.ContentTypeJSON))

    r.Get("/", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("root."))
    })

    r.Get("/ping", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("pong"))
    })

    r.Get("/panic", func(w http.ResponseWriter, r *http.Request) {
        panic("test")
    })

    r.Route("/login", func(r chi.Router) {
        r.Post("/dev", DevLogin)
        // ToDo : implement platform authentication
    })

    r.Post("/find_match", FindMatch)

    // Mount the admin sub-router, which btw is the same as:
    // r.Route("/admin", func(r chi.Router) { admin routes here })
    r.Mount("/admin", adminRouter())

    // Passing -routes to the program will generate docs for the above
    // router definition. See the `routes.json` file in this folder for
    // the output.
    if *routes {
        fmt.Println(docgen.JSONRoutesDoc(r))
        fmt.Println(docgen.MarkdownRoutesDoc(r, docgen.MarkdownOpts{
            ProjectPath: "github.com/go-chi/chi",
            Intro:       "Welcome to the chi/_examples/rest generated docs.",
        }))
        return
    }

    http.ListenAndServe(":3333", r)
}

func DevLogin(w http.ResponseWriter, r *http.Request) {
    s_id, _ := session.GetString(r, "id")
    data := &LoginRequest{}
    if err := render.Bind(r, data); err != nil {
        render.Render(w, r, ErrInvalidRequest(err))
        return
    }
    id := data.ID
    if s_id != "" && s_id != id {
        render.Render(w, r, ErrInvalidRequest(errors.New("session id mismatching")))
        return
    }

    token := ""
    if id == "" {
        id = strconv.FormatInt(time.Now().Unix(), 10)
    }

    render.Status(r, http.StatusCreated)
    render.Render(w, r, NewLoginResponse(id, token))
}

func FindMatch(w http.ResponseWriter, r *http.Request) {
    s_id, _ := session.GetString(r, "id")
}

// A completely separate router for administrator routes
func adminRouter() chi.Router {
    r := chi.NewRouter()
    r.Use(AdminOnly)
    r.Get("/", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("admin: index"))
    })
    r.Get("/accounts", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte("admin: list accounts.."))
    })
    r.Get("/users/{userId}", func(w http.ResponseWriter, r *http.Request) {
        w.Write([]byte(fmt.Sprintf("admin: view user id %v", chi.URLParam(r, "userId"))))
    })
    return r
}

// AdminOnly middleware restricts access to just administrators.
func AdminOnly(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        isAdmin, ok := r.Context().Value("acl.admin").(bool)
        if !ok || !isAdmin {
            http.Error(w, http.StatusText(http.StatusForbidden), http.StatusForbidden)
            return
        }
        next.ServeHTTP(w, r)
    })
}

// This is entirely optional, but I wanted to demonstrate how you could easily
// add your own logic to the render.Respond method.
func init() {
    render.Respond = func(w http.ResponseWriter, r *http.Request, v interface{}) {
        if err, ok := v.(error); ok {

            // We set a default error status response code if one hasn't been set.
            if _, ok := r.Context().Value(render.StatusCtxKey).(int); !ok {
                w.WriteHeader(400)
            }

            // We log the error
            fmt.Printf("Logging err: %s\n", err.Error())

            // We change the response to not reveal the actual error message,
            // instead we can transform the message something more friendly or mapped
            // to some code / language, etc.
            render.DefaultResponder(w, r, render.M{"status": "error"})
            return
        }

        render.DefaultResponder(w, r, v)
    }
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
}

func NewLoginResponse(id string, token string) *LoginResponse {
    resp := &LoginResponse{ID:id, Token:token}
    return resp
}

func (rd *LoginResponse) Render(w http.ResponseWriter, r *http.Request) error {
    fmt.Println("rd id : ", rd.ID)
    session.PutString(r, "id", rd.ID)
    return nil
}

//--
// Error response payloads & renderers
//--

// ErrResponse renderer type for handling all sorts of errors.
//
// In the best case scenario, the excellent github.com/pkg/errors package
// helps reveal information on the error, setting it on Err, and in the Render()
// method, using it to set the application-specific error code in AppCode.
type ErrResponse struct {
    Err            error `json:"-"` // low-level runtime error
    HTTPStatusCode int   `json:"-"` // http response status code

    StatusText string `json:"status"`          // user-level status message
    AppCode    int64  `json:"code,omitempty"`  // application-specific error code
    ErrorText  string `json:"error,omitempty"` // application-level error message, for debugging
}

func (e *ErrResponse) Render(w http.ResponseWriter, r *http.Request) error {
    render.Status(r, e.HTTPStatusCode)
    return nil
}

func ErrInvalidRequest(err error) render.Renderer {
    return &ErrResponse{
        Err:            err,
        HTTPStatusCode: 400,
        StatusText:     "Invalid request.",
        ErrorText:      err.Error(),
    }
}

func ErrRender(err error) render.Renderer {
    return &ErrResponse{
        Err:            err,
        HTTPStatusCode: 422,
        StatusText:     "Error rendering response.",
        ErrorText:      err.Error(),
    }
}

var ErrNotFound = &ErrResponse{HTTPStatusCode: 404, StatusText: "Resource not found."}