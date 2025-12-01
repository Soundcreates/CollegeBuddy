package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
)

func RegisterRoutes(h *handler.Handler) *http.ServeMux {

	mainRouter := http.NewServeMux()

	apiRouter := http.NewServeMux()

	mainRouter.Handle("/api/", http.StripPrefix("/api", apiRouter))

	registerAuthRoutes(h, apiRouter)

	registerScraperRoutes(h, apiRouter)

	return mainRouter
}
