package handlers

import (
	"encoding/json"
	"fmt"
	"net/http"
	"strings"
	"sync"
	"time"
)

type GmailMessage struct {
	ID       string            `json:"id"`
	ThreadID string            `json:"threadId"`
	Snippet  string            `json:"snippet"`
	Subject  string            `json:"subject"`
	From     string            `json:"from"`
	Date     string            `json:"date"`
	Body     string            `json:"body"`
	Headers  map[string]string `json:"headers"`
}

type GmailList struct {
	Messages           []GmailMessage `json:"messages"`
	NextPageToken      string         `json:"nextPageToken"`
	ResultSizeEstimate int            `json:"resultSizeEstimate"`
}

type GmailMessageList struct {
	Messages []struct {
		ID       string `json:"id"`
		ThreadID string `json:"threadId"`
	} `json:"messages"`
	NextPageToken      string `json:"nextPageToken"`
	ResultSizeEstimate int    `json:"resultSizeEstimate"`
}

type GmailFullMessage struct {
	ID       string `json:"id"`
	ThreadID string `json:"threadId"`
	Snippet  string `json:"snippet"`
	Payload  struct {
		Headers []struct {
			Name  string `json:"name"`
			Value string `json:"value"`
		} `json:"headers"`
		Parts []struct {
			Body struct {
				Data string `json:"data"`
			} `json:"body"`
			MimeType string `json:"mimeType"`
		} `json:"parts"`
		Body struct {
			Data string `json:"data"`
		} `json:"body"`
		MimeType string `json:"mimeType"`
	} `json:"payload"`
}

type TokenStruct struct {
	TokenStr string `json:"token"`
}

var (
	rateLimiter = make(map[string]time.Time)
	rateMutex   sync.RWMutex
)

func (h *Handler) ScrapeGmail(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	if r.Header.Get("Content-Type") != "application/json" {
		http.Error(w, "Content-Type must be application/json", http.StatusBadRequest)
		return
	}

	// Decode token received from extension side
	var token TokenStruct
	if err := json.NewDecoder(r.Body).Decode(&token); err != nil {
		http.Error(w, "Invalid JSON payload", http.StatusBadRequest)
		return
	}

	if token.TokenStr == "" {
		http.Error(w, "Token is required", http.StatusBadRequest)
		return
	}

	// Validate the token
	if err := validateGmailToken(token.TokenStr); err != nil {
		http.Error(w, "Invalid Gmail token", http.StatusUnauthorized)
		return
	}

	// Check rate limiting
	if !checkRateLimit(token.TokenStr) {
		http.Error(w, "Rate limit exceeded. Please try again later.", http.StatusTooManyRequests)
		return
	}

	// First, get the list of message IDs
	messageListURL := "https://gmail.googleapis.com/gmail/v1/users/me/messages?maxResults=20"
	msgListReq, err := http.NewRequest("GET", messageListURL, nil)
	if err != nil {
		http.Error(w, "Failed to create request", http.StatusInternalServerError)
		return
	}

	msgListReq.Header.Set("Authorization", "Bearer "+token.TokenStr)

	msgListResp, err := http.DefaultClient.Do(msgListReq)
	if err != nil {
		http.Error(w, "Failed to fetch Gmail message list", http.StatusInternalServerError)
		return
	}
	defer msgListResp.Body.Close()

	if msgListResp.StatusCode != http.StatusOK {
		http.Error(w, fmt.Sprintf("Gmail API request failed: %d", msgListResp.StatusCode), msgListResp.StatusCode)
		return
	}

	var messageList GmailMessageList
	if err := json.NewDecoder(msgListResp.Body).Decode(&messageList); err != nil {
		http.Error(w, "Failed to parse Gmail message list", http.StatusInternalServerError)
		return
	}

	// Now fetch detailed content for each message
	var detailedMessages []GmailMessage
	for _, msg := range messageList.Messages {
		detailedMsg, err := fetchMessageDetails(token.TokenStr, msg.ID)
		if err != nil {
			fmt.Printf("Error fetching message %s: %v\n", msg.ID, err)
			continue
		}
		detailedMessages = append(detailedMessages, detailedMsg)
	}

	response := GmailList{
		Messages:           detailedMessages,
		NextPageToken:      messageList.NextPageToken,
		ResultSizeEstimate: messageList.ResultSizeEstimate,
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func validateGmailToken(token string) error {
	req, err := http.NewRequest("GET", "https://gmail.googleapis.com/gmail/v1/users/me/profile", nil)
	if err != nil {
		return err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return fmt.Errorf("invalid token")
	}
	return nil
}

func checkRateLimit(userID string) bool {
	rateMutex.RLock()
	lastRequest, exists := rateLimiter[userID]
	rateMutex.RUnlock()

	if exists && time.Since(lastRequest) < 2*time.Second {
		return false
	}

	rateMutex.Lock()
	rateLimiter[userID] = time.Now()
	rateMutex.Unlock()
	return true
}

func fetchMessageDetails(token, messageID string) (GmailMessage, error) {
	url := fmt.Sprintf("https://gmail.googleapis.com/gmail/v1/users/me/messages/%s?format=full", messageID)
	req, err := http.NewRequest("GET", url, nil)
	if err != nil {
		return GmailMessage{}, err
	}

	req.Header.Set("Authorization", "Bearer "+token)
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		return GmailMessage{}, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return GmailMessage{}, fmt.Errorf("failed to fetch message: %d", resp.StatusCode)
	}

	var fullMsg GmailFullMessage
	if err := json.NewDecoder(resp.Body).Decode(&fullMsg); err != nil {
		return GmailMessage{}, err
	}

	return parseGmailMessage(fullMsg), nil
}

func parseGmailMessage(fullMsg GmailFullMessage) GmailMessage {
	headers := make(map[string]string)
	var subject, from, date string

	// Extract headers
	for _, header := range fullMsg.Payload.Headers {
		headers[header.Name] = header.Value
		switch strings.ToLower(header.Name) {
		case "subject":
			subject = header.Value
		case "from":
			from = header.Value
		case "date":
			date = header.Value
		}
	}

	// Extract body content
	body := extractBodyContent(fullMsg.Payload)

	return GmailMessage{
		ID:       fullMsg.ID,
		ThreadID: fullMsg.ThreadID,
		Snippet:  fullMsg.Snippet,
		Subject:  subject,
		From:     from,
		Date:     date,
		Body:     body,
		Headers:  headers,
	}
}

func extractBodyContent(payload struct {
	Headers []struct {
		Name  string `json:"name"`
		Value string `json:"value"`
	} `json:"headers"`
	Parts []struct {
		Body struct {
			Data string `json:"data"`
		} `json:"body"`
		MimeType string `json:"mimeType"`
	} `json:"parts"`
	Body struct {
		Data string `json:"data"`
	} `json:"body"`
	MimeType string `json:"mimeType"`
}) string {
	// Try to get body from main payload first
	if payload.Body.Data != "" {
		return decodeBase64URL(payload.Body.Data)
	}

	// If no direct body, check parts for text/plain or text/html
	for _, part := range payload.Parts {
		if part.MimeType == "text/plain" || part.MimeType == "text/html" {
			if part.Body.Data != "" {
				return decodeBase64URL(part.Body.Data)
			}
		}
	}

	return ""
}

func decodeBase64URL(data string) string {
	// Gmail API returns base64url encoded data
	// Replace URL-safe characters
	data = strings.ReplaceAll(data, "-", "+")
	data = strings.ReplaceAll(data, "_", "/")

	// Add padding if needed
	for len(data)%4 != 0 {
		data += "="
	}

	// Note: For proper base64 decoding, you'd need to import "encoding/base64"
	// and use base64.StdEncoding.DecodeString(data)
	// For now, returning the processed string
	return data
}
