package routes

import (
	"net/http"
	// handler "somaiya-ext/internal/handler"
	handler "somaiya-ext/internal/handlers"
	// "somaiya-ext/internal/middleware"
)

func registerAuthRoutes(h *handler.Handler, router *http.ServeMux) {
	router.HandleFunc("GET /auth/OAuth", h.HandleGoogleLogin)
	router.HandleFunc("GET /auth/google/callback", h.GoogleCallBack)
	// router.HandleFunc("GET /auth/profile", middleware.WithAuth(h.Profile))

}
