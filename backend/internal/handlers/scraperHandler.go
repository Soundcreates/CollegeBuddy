package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"somaiya-ext/service"
	"strings"
)

func (h *Handler) HandleScrapeGmail(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println("HandleScrapeGmail called")

	// Extract JWT token from Authorization header
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		http.Error(w, "missing authorization header", http.StatusUnauthorized)
		return
	}

	// Remove "Bearer " prefix
	token := strings.TrimPrefix(authHeader, "Bearer ")

	// Get student profile using the token
	profile, err := h.Profile(token)
	if err != nil {
		http.Error(w, "failed to fetch profile: "+err.Error(), http.StatusUnauthorized)
		return
	}

	// Extract student data from profile response
	studentData, ok := profile["user"].(map[string]interface{})
	if !ok {
		http.Error(w, "invalid student data", http.StatusInternalServerError)
		return
	}

	// Get OAuth tokens from student record
	accessToken, ok := studentData["o_access_token"].(string)
	if !ok || accessToken == "" {
		http.Error(w, "no access token found", http.StatusUnauthorized)
		return
	}

	refreshToken, ok := studentData["o_refresh_token"].(string)
	if !ok {
		refreshToken = ""
	}

	// Initialize Gmail service
	gmailService := service.NewGmailService(h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET)

	// Create Gmail client with stored tokens
	gmailClient, err := gmailService.GmailClientFromStoredToken(r.Context(), h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET, accessToken, refreshToken)
	if err != nil {
		http.Error(w, "failed to create gmail client: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Fetch emails from Gmail
	messages, err := gmailClient.Users.Messages.List("me").MaxResults(10).Do()
	if err != nil {
		http.Error(w, "failed to fetch emails: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return response
	response := map[string]interface{}{
		"success":  true,
		"messages": messages.Messages,
		"count":    len(messages.Messages),
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
