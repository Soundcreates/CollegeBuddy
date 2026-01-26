package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
)

func RegisterRoutes(h *handler.Handler) *http.ServeMux {

	mainRouter := http.NewServeMux()

	apiRouter := http.NewServeMux()

	mainRouter.HandleFunc("/health", func(w http.ResponseWriter, r* http.Request) {
		w.Write([]byte("OK"))
	})
	
	mainRouter.Handle("/api/", http.StripPrefix("/api", apiRouter))

	registerAuthRoutes(h, apiRouter)

	registerScraperRoutes(h, apiRouter)

	return mainRouter
}
