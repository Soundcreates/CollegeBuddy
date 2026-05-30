package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
	"somaiya-ext/internal/middleware"
)

func registerSyncRoutes(h *handler.Handler, router *http.ServeMux) {
	router.HandleFunc("GET /sync", middleware.WithAuth(h)(h.HandleSync))
}
