package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
)

func RegisterRoutes(h *handler.Handler) *http.ServeMux {

	mainRouter := http.NewServeMux()

	authRouter := http.NewServeMux()

	scraperRouter := http.NewServeMux()

	mainRouter.Handle("/api", http.StripPrefix("/api", scraperRouter))

	mainRouter.Handle("/api/", http.StripPrefix("/api", authRouter))

	registerAuthRoutes(h, authRouter)

	registerScraperRoutes(h, scraperRouter)

	return mainRouter
}
