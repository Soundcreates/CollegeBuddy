package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
)

func registerScraperRoutes(h *handler.Handler, router *http.ServeMux) {
	// Remove middleware - handle auth directly in handler
	router.HandleFunc("POST /scrape/gmail", h.HandleScrapeGmail)
}
