package handlers

import (
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
	"somaiya-ext/service"
	"strings"
	"time"

	"google.golang.org/api/gmail/v1"
)

type ParsedMessage struct {
	ID       string `json:"id"`
	ThreadID string `json:"threadId"`
	Subject  string `json:"subject"`
	From     string `json:"from"`
	To       string `json:"to"`
	Date     string `json:"date"`
}

func extractAttachmentsFromPayload(payload *gmail.MessagePart) []models.Attatchment {
	if payload == nil {
		return []models.Attatchment{}
	}

	attachments := make([]models.Attatchment, 0)
	seenAttachmentIDs := make(map[string]struct{})

	var walkParts func(part *gmail.MessagePart)
	walkParts = func(part *gmail.MessagePart) {
		if part == nil {
			return
		}

		if part.Body != nil && part.Body.AttachmentId != "" {
			if _, exists := seenAttachmentIDs[part.Body.AttachmentId]; !exists {
				attachments = append(attachments, models.Attatchment{
					Filename:      part.Filename,
					MimeType:      part.MimeType,
					AttatchmentId: part.Body.AttachmentId,
				})
				seenAttachmentIDs[part.Body.AttachmentId] = struct{}{}
			}
		}

		for _, child := range part.Parts {
			walkParts(child)
		}
	}

	walkParts(payload)
	return attachments
}

// decodeBase64Body decodes base64 encoded email body from Gmail API
func decodeBase64Body(encodedBody string) string {
	if encodedBody == "" {
		return ""
	}
	// Gmail API returns URL-safe base64 encoded data
	decoded, err := base64.URLEncoding.DecodeString(encodedBody)
	if err != nil {
		log.Printf("Failed to decode base64 body: %v", err)
		return encodedBody // Return original if decode fails
	}
	return string(decoded)
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
	profile, err := h.BackendProfile(token)
	if err != nil {
		log.Println("Failed to fetch profile:", err.Error())
		http.Error(w, "failed to fetch profile: "+err.Error(), http.StatusInternalServerError)
		return
	}

	log.Println("Profile fetched successfully: ", profile)
	// Extract student data from profile response
	log.Println("Extracting student data")

	userRaw := profile["user"]
	log.Printf("[DEBUG] userRaw value: %+v, type: %T", userRaw, userRaw)
	if userRaw == nil {
		log.Println("User data is nil in profile")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]interface{}{"error": "user data missing"})
		return
	}
	studentData, ok := userRaw.(map[string]interface{})
	if !ok {
		log.Printf("User data type: %T", userRaw)
		log.Println("Invalid student data in profile - cannot convert to map")
		w.WriteHeader(http.StatusInternalServerError)
		json.NewEncoder(w).Encode(map[string]interface{}{"error": "invalid student data"})
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
	now := time.Now()
	weekday := int(now.Weekday())
	if weekday == 0 { //if its a sunday
		weekday = 7
	}
	monday := now.AddDate(0, 0, -weekday+1)
	monday = time.Date(monday.Year(), monday.Month(), monday.Day(), 0, 0, 0, 0, monday.Location())
	sunday := monday.AddDate(0, 0, 6)
	sunday = time.Date(sunday.Year(), sunday.Month(), sunday.Day(), 23, 59, 59, 0, sunday.Location())

	after := monday.Unix()
	before := sunday.Unix()

	query := fmt.Sprintf("after:%d before:%d", after, before)
	pageToken := ""
	var parsedMessages []models.GmailMessage
	for {
		log.Println("Fetching emails from Gmail")
		call := gmailClient.Users.Messages.List("me").Q(query).MaxResults(30)
		if pageToken != "" {
			call = call.PageToken(pageToken)
		}
		messages, err := call.Do()
		if err != nil {
			log.Println("Failed to fetch emails:", err)
			http.Error(w, "failed to fetch emails: "+err.Error(), http.StatusInternalServerError)
			return
		}
		for i := range messages.Messages {
			msg, err := gmailClient.Users.Messages.Get("me", messages.Messages[i].Id).Format("full").Do()

			if err != nil {
				log.Printf("Failed to fetch message details for ID %s: %v\n", messages.Messages[i].Id, err)
				continue
			}

			log.Println("Processing message:", msg.Id)
			allAttatchments := extractAttachmentsFromPayload(msg.Payload)

			svvEmail := ""
			if email, ok := studentData["email"].(string); ok && email != "" {
				svvEmail = email
			}

			msgData := models.GmailMessage{
				ID:           msg.Id,
				ThreadID:     msg.ThreadId,
				Student:      svvEmail,
				Snippet:      msg.Snippet,
				Attatchments: allAttatchments,
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

			// Extract body (handle base64 decoding)
			if msg.Payload.Body != nil && msg.Payload.Body.Data != "" {
				msgData.Body = decodeBase64Body(msg.Payload.Body.Data)
			} else if len(msg.Payload.Parts) > 0 {
				// Look for text/plain or text/html parts
				for _, part := range msg.Payload.Parts {
					if part.MimeType == "text/plain" || part.MimeType == "text/html" {
						if part.Body != nil && part.Body.Data != "" {
							msgData.Body = decodeBase64Body(part.Body.Data)
							break
						}
					}
				}
			}

			parsedMessages = append(parsedMessages, msgData)
		}
		if messages.NextPageToken == "" {
			break
		}
		pageToken = messages.NextPageToken
	}

	// Log sample of parsed messages
	if len(parsedMessages) > 0 {
		sampleCount := 3
		if len(parsedMessages) < sampleCount {
			sampleCount = len(parsedMessages)
		}
		log.Printf("Sample of %d messages (showing %d):", len(parsedMessages), sampleCount)
		for i := 0; i < sampleCount; i++ {
			log.Printf("  [%d] From: %s | Subject: %s", i, parsedMessages[i].From, parsedMessages[i].Subject)
		}
	}

	// Get today's date for filtering context
	today := time.Now().Format("2006-01-02")

	// Filter mails using AI filtration service
	log.Println("Sending emails to AI filtration service...")
	filterResponse, err := service.FilterEmails(parsedMessages, today)
	if err != nil {
		log.Printf("Error during AI filtration: %v", err)
		log.Println("Proceeding with unfiltered emails as fallback")
		// Return fallback response with all emails in proper format
		fallbackMessages := make([]map[string]interface{}, 0)
		for _, msg := range parsedMessages {
			fallbackMessages = append(fallbackMessages, map[string]interface{}{
				"id":          msg.ID,
				"subject":     msg.Subject,
				"from":        msg.From,
				"to":          msg.To,
				"date":        msg.Date,
				"snippet":     msg.Snippet,
				"body":        msg.Body,
				"category":    "unfiltered",
				"confidence":  0.0,
				"attachments": []interface{}{},
			})
		}
		response := map[string]interface{}{
			"success":        false,
			"messages":       fallbackMessages,
			"total_emails":   len(parsedMessages),
			"filtered_count": 0,
			"by_category":    map[string]interface{}{},
			"count":          len(parsedMessages),
			"error":          err.Error(),
			"note":           "Returning all emails due to filtration error",
		}
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(response)
		return
	}

	log.Printf("AI filtration completed: %d/%d emails retained", filterResponse.FilteredCount, filterResponse.TotalEmails)

	// Transform filtered results to include all fields mobile app expects
	transformedMessages := make([]map[string]interface{}, 0)
	for _, filtered := range filterResponse.AllFiltered {
		transformedMessages = append(transformedMessages, map[string]interface{}{
			"id":          "", // ID not available from AI filter, mobile will use index or empty
			"subject":     filtered.Subject,
			"from":        filtered.Sender, // Map sender to from
			"to":          "",              // Not available from AI filter
			"date":        filtered.Date,
			"snippet":     "", // Could extract from body if needed
			"body":        filtered.Body,
			"category":    filtered.Category,   // Add AI category for reference
			"confidence":  filtered.Confidence, // Add confidence score
			"attachments": []interface{}{},     // No attachments in filtered response
		})
	}

	// Transform by_category to use same format
	transformedByCategory := make(map[string][]map[string]interface{})
	for categoryGroup, emails := range filterResponse.ByCategory {
		transformedByCategory[categoryGroup] = make([]map[string]interface{}, 0)
		for _, filtered := range emails {
			transformedByCategory[categoryGroup] = append(transformedByCategory[categoryGroup], map[string]interface{}{
				"id":          "",
				"subject":     filtered.Subject,
				"from":        filtered.Sender,
				"to":          "",
				"date":        filtered.Date,
				"snippet":     "",
				"body":        filtered.Body,
				"category":    filtered.Category,
				"confidence":  filtered.Confidence,
				"attachments": []interface{}{},
			})
		}
	}

	// Return organized response with filtered emails
	// Include 'messages' key for mobile app compatibility
	response := map[string]interface{}{
		"success":        true,
		"messages":       transformedMessages,
		"total_emails":   filterResponse.TotalEmails,
		"filtered_count": filterResponse.FilteredCount,
		"by_category":    transformedByCategory,
		"all_filtered":   transformedMessages, // Both messages and all_filtered for compatibility
		"date":           today,
	}

	log.Println("Writing response header")
	w.WriteHeader(http.StatusOK)

	if len(transformedMessages) > 0 {
		log.Printf("[DEBUG] Sample of transformed message being sent to mobile (first message):")
		log.Printf("  Subject: %v", transformedMessages[0]["subject"])
		log.Printf("  From: %v", transformedMessages[0]["from"])
		log.Printf("  Category: %v", transformedMessages[0]["category"])
		log.Printf("  Confidence: %v", transformedMessages[0]["confidence"])
	}
	log.Printf("[DEBUG] Total messages in response: %d", len(transformedMessages))
	log.Println("Encoding response to JSON")
	json.NewEncoder(w).Encode(response)
}

// HandleGetGmailMessage fetches full details of a single Gmail message
func (h *Handler) HandleGetGmailMessage(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	log.Println("HandleGetGmailMessage called")

	// Get message ID from query params
	messageID := r.URL.Query().Get("id")
	if messageID == "" {
		log.Println("Message ID missing")
		http.Error(w, "message ID required", http.StatusBadRequest)
		return
	}

	log.Printf("Fetching message: %s", messageID)

	// Extract JWT token from Authorization header
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		http.Error(w, "missing authorization header", http.StatusUnauthorized)
		return
	}

	token := strings.TrimPrefix(authHeader, "Bearer ")
	if token == authHeader {
		http.Error(w, "invalid authorization format", http.StatusUnauthorized)
		return
	}

	// Parse JWT to get email
	claims, err := h.ParseJWTForScraping(token)
	if err != nil {
		http.Error(w, "invalid token: "+err.Error(), http.StatusUnauthorized)
		return
	}

	email, ok := claims["email"].(string)
	if !ok {
		http.Error(w, "email not found in token", http.StatusUnauthorized)
		return
	}

	log.Println("JWT validated for email:", email)

	// Get student profile
	profile, err := h.BackendProfile(token)
	if err != nil {
		http.Error(w, "failed to fetch profile: "+err.Error(), http.StatusInternalServerError)
		return
	}

	studentData, ok := profile["user"].(map[string]interface{})
	if !ok {
		http.Error(w, "invalid student data", http.StatusInternalServerError)
		return
	}

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

	// Create Gmail client
	gmailClient, err := gmailService.GmailClientFromStoredToken(r.Context(), h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET, accessToken, refreshToken, email, h.DB)
	if err != nil {
		log.Println("Failed to create Gmail client:", err)
		http.Error(w, "failed to create gmail client: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Fetch full message details
	msg, err := gmailClient.Users.Messages.Get("me", messageID).Format("full").Do()
	if err != nil {
		log.Printf("Failed to fetch message %s: %v\n", messageID, err)
		http.Error(w, "failed to fetch message: "+err.Error(), http.StatusInternalServerError)
		return
	}

	// Extract message details
	msgData := models.GmailMessage{
		ID:       msg.Id,
		ThreadID: msg.ThreadId,
		Snippet:  msg.Snippet,
	}

	// Extract headers
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

	msgData.Attatchments = extractAttachmentsFromPayload(msg.Payload)

	// Extract body (handle base64 decoding)
	if msg.Payload.Body != nil && msg.Payload.Body.Data != "" {
		// Decode base64 body
		msgData.Body = decodeBase64Body(msg.Payload.Body.Data)
	} else if len(msg.Payload.Parts) > 0 {
		// Check parts for body
		for _, part := range msg.Payload.Parts {
			if part.MimeType == "text/plain" || part.MimeType == "text/html" {
				if part.Body != nil && part.Body.Data != "" {
					msgData.Body = decodeBase64Body(part.Body.Data)
					break
				}
			}
		}
	}
	// Filter email using AI filtration service
	today := time.Now().Format("2006-01-02")
	log.Println("Filtering single email through AI service...")
	filterResponse, err := service.FilterEmails([]models.GmailMessage{msgData}, today)
	if err != nil {
		log.Printf("Error filtering email: %v", err)
		http.Error(w, "failed to filter email: "+err.Error(), http.StatusInternalServerError)
		return
	}

	log.Printf("Email filtered: %d/%d retained", filterResponse.FilteredCount, filterResponse.TotalEmails)

	response := map[string]interface{}{
		"success":        true,
		"filtered_count": filterResponse.FilteredCount,
		"by_category":    filterResponse.ByCategory,
		"all_filtered":   filterResponse.AllFiltered,
		"date":           today,
	}

	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}
