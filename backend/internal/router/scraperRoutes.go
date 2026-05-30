package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
	"somaiya-ext/internal/middleware"
)

func registerScraperRoutes(h *handler.Handler, router *http.ServeMux) {
	router.HandleFunc("POST /scrape/gmail", middleware.WithAuth(h)(h.HandleScrapeGmail))
	router.HandleFunc("GET /scrape/gmail/message", middleware.WithAuth(h)(h.HandleGetGmailMessage))
	router.HandleFunc("POST /scrape/gmail/stream/start", middleware.WithAuth(h)(h.HandleScrapeGmailStreamStart))
	router.HandleFunc("GET /scrape/gmail/stream/poll", middleware.WithAuth(h)(h.HandleScrapeGmailStreamPoll))
	
}
