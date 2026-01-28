package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
	"somaiya-ext/internal/middleware"
)

func registerScraperRoutes(h *handler.Handler, router *http.ServeMux) {
	router.HandleFunc("POST /scrape/gmail", middleware.WithAuth(h)(h.HandleScrapeGmail))
	router.HandleFunc("GET /scrape/gmail/message", middleware.WithAuth(h)(h.HandleGetGmailMessage))
	
}
