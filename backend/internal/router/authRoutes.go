package routes

import (
	"net/http"
	// handler "somaiya-ext/internal/handler"
	handler "somaiya-ext/internal/handlers"
)

func registerAuthRoutes(h* handler.Handler, router *http.ServeMux) {


	router.HandleFunc("POST /auth/login", h.Login)
	router.HandleFunc("POST /auth/register", h.Register)
	router.HandleFunc("GET /auth/profile", h.Profile)
}