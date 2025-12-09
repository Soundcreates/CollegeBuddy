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
		log.Println("Auth header missing")
		http.Error(w, "missing authorization header", http.StatusUnauthorized)
		return
	}

	// Remove "Bearer " prefix
	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == authHeader {
		log.Println("Invalid authorization format - no Bearer prefix")
		http.Error(w, "invalid authorization format", http.StatusUnauthorized)
		return
	}

	log.Println("Token extracted, validating JWT")

	// Validate JWT token first
	claims, err := h.ParseJWTForScraping(token)
	if err != nil {
		log.Println("JWT validation failed:", err.Error())
		http.Error(w, "invalid token: "+err.Error(), http.StatusUnauthorized)
		return
	}

	// Extract email from claims to verify token is valid
	log.Println("Extracting email from JWT claims")
	email, ok := claims["email"].(string)
	if !ok {
		log.Println("Email not found in JWT claims")
		http.Error(w, "email not found in token", http.StatusUnauthorized)
		return
	}

	log.Println("JWT validated for email:", email)

	// Get student profile using the token
	log.Println("Fetching profile")
	profile, err := h.Profile(w, token)
	if err != nil {
		log.Println("Failed to fetch profile:", err.Error())
		http.Error(w, "failed to fetch profile: "+err.Error(), http.StatusInternalServerError)
		return
	}

	log.Println("Profile fetched successfully")
	// Extract student data from profile response
	log.Println("Extracting student data")

	studentData, ok := profile["user"].(map[string]interface{})
	if !ok {
		log.Println("Invalid student data in profile - cannot convert to map")
		http.Error(w, "invalid student data", http.StatusInternalServerError)
		return
	}

	log.Println("(HandleScrapeGmail)=> Student data extracted successfully", studentData)
	// Get OAuth tokens from student record
	log.Println("Extracting OAuth tokens")
	accessToken, ok := studentData["o_access_token"].(string)
	if !ok || accessToken == "" {
		log.Println("Access token missing in student data")
		http.Error(w, "no access token found", http.StatusUnauthorized)
		return
	}

	//getting refresh tokens
	log.Println("Getting refresh token")
	refreshToken, ok := studentData["o_refresh_token"].(string)
	if !ok {
		log.Println("Refresh token missing, proceeding without it")
		refreshToken = ""
	}

	// Initialize Gmail service
	log.Println("Initializing Gmail service")
	gmailService := service.NewGmailService(h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET)

	// Create Gmail client with stored tokens
	log.Println("Creating Gmail client")
	gmailClient, err := gmailService.GmailClientFromStoredToken(r.Context(), h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET, accessToken, refreshToken, email, h.DB)
	if err != nil {
		log.Println("Failed to create Gmail client:", err)
		http.Error(w, "failed to create gmail client: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Fetch emails from Gmail
	log.Println("Fetching emails from Gmail")
	messages, err := gmailClient.Users.Messages.List("me").MaxResults(10).Do()
	if err != nil {
		log.Println("Failed to fetch emails:", err)
		http.Error(w, "failed to fetch emails: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Return response
	log.Println("Successfully fetched emails, preparing response")
	response := map[string]interface{}{
		"success":  true,
		"messages": messages.Messages,
		"count":    len(messages.Messages),
	}
	log.Println("Writing header")
	w.WriteHeader(http.StatusOK)

	log.Println("Encoding response to JSON")
	json.NewEncoder(w).Encode(response)
}
