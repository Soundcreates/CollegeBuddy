package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
	"somaiya-ext/service"
	"strings"
)

type ParsedMessage struct {
	ID       string `json:"id"`
	ThreadID string `json:"threadId"`
	Subject  string `json:"subject"`
	From     string `json:"from"`
	To       string `json:"to"`
	Date     string `json:"date"`
}

func (h *Handler) HandleScrapeGmail(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println("HandleScrapeGmail called")

	// Extract JWT token from Authorization header
	log.Println("extracting token from Authorization header")
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		log.Println("Auth header missing")
		http.Error(w, "missing authorization header", http.StatusUnauthorized)
		return
	}
	log.Println("Authorization header found")
	log.Println("Auth Header: ", authHeader)
	log.Println("Removing Bearer prefix from token")
	// Remove "Bearer " prefix
	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == authHeader {
		log.Println("Invalid authorization format - no Bearer prefix")
		http.Error(w, "invalid authorization format", http.StatusUnauthorized)
		return
	}

	log.Println("Token extracted, validating JWT")
	log.Println("Token: ", token)

	// Extract email from the Authorization header token (middleware already validated it)
	// Parse JWT to get email without re-validating (middleware did that)
	claims, err := h.ParseJWTForScraping(token)
	log.Println("Performed the ParseJWTForScraping function")
	if err != nil {

		log.Println("Failed to parse JWT:", err.Error())
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
	limit := 100
	log.Println("Fetching emails from Gmail")
	messages, err := gmailClient.Users.Messages.List("me").MaxResults(int64(limit)).Do()
	log.Printf("Fetching for %d mails", limit)

	if err != nil {
		log.Println("Failed to fetch emails:", err)
		http.Error(w, "failed to fetch emails: "+err.Error(), http.StatusInternalServerError)
		return
	}
	var parsedMessages []models.GmailMessage

	for i := range messages.Messages {
		log.Printf("Fetching  metadata of message ID: %s\n", messages.Messages[i].Id)
		msg, err := gmailClient.Users.Messages.Get("me", messages.Messages[i].Id).Format("metadata").MetadataHeaders("From", "To", "Subject", "Date").Do()
		if err != nil {
			log.Printf("Failed to fetch message details for ID %s: %v\n", messages.Messages[i].Id, err)
			continue
		}

		svvEmail := ""
		if email, ok := studentData["email"].(string); ok && email != "" {
			svvEmail = email
		}

		msgData := models.GmailMessage{
			ID:       msg.Id,
			ThreadID: msg.ThreadId,
			Student:  svvEmail,
		}

		// Extract headers from the actual message payload
		for _, h := range msg.Payload.Headers {
			switch h.Name {
			case "From":
				msgData.From = h.Value
			case "To":
				msgData.To = h.Value
			case "Subject":
				msgData.Subject = h.Value
			case "Date":
				msgData.Date = h.Value
			}
		}

		parsedMessages = append(parsedMessages, msgData)
	}

	// Log sample of parsed messages
	if len(parsedMessages) > 0 {
		sampleCount := 3
		if len(parsedMessages) < sampleCount {
			sampleCount = len(parsedMessages)
		}
		log.Printf("Parsed %d messages, first %d: %+v\n", len(parsedMessages), sampleCount, parsedMessages[0:sampleCount])
	}
	// filtering mails
	log.Println("Filtering mails to be sent to extension")
	filteredMails, err := service.FilterSomaiyaMails(parsedMessages)
	if err != nil {
		log.Println("Error happened while filtering mails")
	}
	log.Println("Mails filtered successfully")

	//returning response
	response := map[string]interface{}{
		"success":  true,
		"messages": filteredMails,
		"count":    len(messages.Messages),
	}
	log.Println("Writing header")
	w.WriteHeader(http.StatusOK)

	log.Println("Encoding response to JSON")
	json.NewEncoder(w).Encode(response)
}
