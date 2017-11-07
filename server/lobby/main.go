package main

import (
    "flag"
    "fmt"
    "net/http"

    "github.com/alexedwards/scs/session"
    "github.com/alexedwards/scs/engine/memstore"

    "github.com/go-chi/chi"
    "github.com/go-chi/docgen"
    "github.com/go-chi/chi/middleware"
    "github.com/go-chi/render"
)

var routes = flag.Bool("routes", false, "Generate router documentation")

var store *memstore.MemStore = memstore.New(0)

func main() {
    flag.Parse()

    r := chi.NewRouter()

    r.Use(middleware.RequestID)
    r.Use(middleware.Logger)
    r.Use(middleware.Recoverer)

    r.Use(session.Manage(store))

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

    r.Mount("/login", LoginRouter())
    r.Mount("/match", MatchRouter())
    r.Post("/logout", Logout)

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


type LogoutResponse struct {
}

func NewLogoutResponse() *LogoutResponse {
    resp := &LogoutResponse{}
    return resp
}

func (rd *LogoutResponse) Render(w http.ResponseWriter, r *http.Request) error {
    return nil
}
func Logout(w http.ResponseWriter, r *http.Request) {
    session.Clear(r)
    render.Render(w, r, NewLogoutResponse())
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
