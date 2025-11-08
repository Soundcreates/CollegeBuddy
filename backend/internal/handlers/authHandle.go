package handler


import(
	"net/http"
)



func (h *Handler) Login (w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("hello world"))
}

func (h *Handler) Register(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("Hello world"))
}

func (h *Handler) Profile(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("HEllo world"))
}