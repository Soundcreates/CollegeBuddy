package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
	"somaiya-ext/service"
	"strings"
	"time"
)

func (h *Handler) HandleScrapeGmailStreamStart(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

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

	claims, err := h.ParseJWTForScraping(token)
	if err != nil {
		http.Error(w, "invalid token: "+err.Error(), http.StatusUnauthorized)
		return
	}
	email, ok := claims["email"].(string)
	if !ok || email == "" {
		http.Error(w, "email not found in token", http.StatusUnauthorized)
		return
	}

	job := h.gmailJobs.Create(email)

	go func(jobID string, userEmail string, bearer string) {
		if err := h.runGmailStreamJob(jobID, userEmail, bearer); err != nil {
			h.gmailJobs.SetError(jobID, err.Error())
		} else {
			h.gmailJobs.SetDone(jobID)
		}
	}(job.ID, email, token)

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success": true,
		"job_id":  job.ID,
	})
}

func (h *Handler) HandleScrapeGmailStreamPoll(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

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

	claims, err := h.ParseJWTForScraping(token)
	if err != nil {
		http.Error(w, "invalid token: "+err.Error(), http.StatusUnauthorized)
		return
	}
	email, ok := claims["email"].(string)
	if !ok || email == "" {
		http.Error(w, "email not found in token", http.StatusUnauthorized)
		return
	}

	jobID := r.URL.Query().Get("job_id")
	if jobID == "" {
		http.Error(w, "job_id required", http.StatusBadRequest)
		return
	}

	job, ok := h.gmailJobs.Get(jobID)
	if !ok {
		http.Error(w, "job not found", http.StatusNotFound)
		return
	}
	if job.Email != email {
		http.Error(w, "forbidden", http.StatusForbidden)
		return
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success":  true,
		"job_id":   job.ID,
		"done":     job.Done,
		"error":    job.Error,
		"count":    len(job.Messages),
		"messages": job.Messages,
	})
}

func (h *Handler) runGmailStreamJob(jobID string, userEmail string, token string) error {
	log.Printf("Starting gmail stream job %s for %s", jobID, userEmail)

	profile, err := h.BackendProfile(token)
	if err != nil {
		return fmt.Errorf("failed to fetch profile: %w", err)
	}

	userRaw := profile["user"]
	if userRaw == nil {
		return fmt.Errorf("user data missing in profile")
	}
	studentData, ok := userRaw.(map[string]interface{})
	if !ok {
		return fmt.Errorf("invalid student data")
	}

	accessToken, ok := studentData["o_access_token"].(string)
	if !ok || accessToken == "" {
		return fmt.Errorf("no access token found")
	}

	refreshToken, _ := studentData["o_refresh_token"].(string)

	gmailService := service.NewGmailService(h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET)
	gmailClient, err := gmailService.GmailClientFromStoredToken(
		context.Background(),
		h.Config.OAUTH_CLIENT_ID,
		h.Config.OAUTH_CLIENT_SECRET,
		accessToken,
		refreshToken,
		userEmail,
		h.DB,
	)
	if err != nil {
		return fmt.Errorf("failed to create gmail client: %w", err)
	}

	now := time.Now()
	weekday := int(now.Weekday())
	if weekday == 0 {
		weekday = 7
	}
	monday := now.AddDate(0, 0, -weekday+1)
	monday = time.Date(monday.Year(), monday.Month(), monday.Day(), 0, 0, 0, 0, monday.Location())
	sunday := monday.AddDate(0, 0, 6)
	sunday = time.Date(sunday.Year(), sunday.Month(), sunday.Day(), 23, 59, 59, 0, sunday.Location())

	query := fmt.Sprintf("after:%d before:%d", monday.Unix(), sunday.Unix())

	pageToken := ""
	parsedMessages := make([]models.GmailMessage, 0)
	for {
		call := gmailClient.Users.Messages.List("me").Q(query)
		if pageToken != "" {
			call = call.PageToken(pageToken)
		}
		messages, err := call.Do()
		if err != nil {
			return fmt.Errorf("failed to fetch emails: %w", err)
		}
		for i := range messages.Messages {
			msg, err := gmailClient.Users.Messages.Get("me", messages.Messages[i].Id).Format("full").Do()
			if err != nil {
				continue
			}
			allAttatchments := extractAttachmentsFromPayload(msg.Payload)
			msgData := models.GmailMessage{
				ID:           msg.Id,
				ThreadID:     msg.ThreadId,
				Student:      userEmail,
				Snippet:      msg.Snippet,
				Attatchments: allAttatchments,
			}
			for _, hdr := range msg.Payload.Headers {
				switch hdr.Name {
				case "From":
					msgData.From = hdr.Value
				case "To":
					msgData.To = hdr.Value
				case "Subject":
					msgData.Subject = hdr.Value
				case "Date":
					msgData.Date = hdr.Value
				}
			}
			if msg.Payload.Body != nil && msg.Payload.Body.Data != "" {
				msgData.Body = decodeBase64Body(msg.Payload.Body.Data)
			} else if len(msg.Payload.Parts) > 0 {
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

	today := time.Now().Format("2006-01-02")

	const chunkSize = 20
	accumulated := make([]map[string]interface{}, 0)
	for i := 0; i < len(parsedMessages); i += chunkSize {
		end := i + chunkSize
		if end > len(parsedMessages) {
			end = len(parsedMessages)
		}

		filterResponse, err := service.FilterEmails(parsedMessages[i:end], today)
		if err != nil {
			continue
		}

		batch := make([]map[string]interface{}, 0, len(filterResponse.AllFiltered))
		for _, filtered := range filterResponse.AllFiltered {
			batch = append(batch, map[string]interface{}{
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

		if len(batch) > 0 {
			accumulated = append(accumulated, batch...)
			h.gmailJobs.AppendMessages(jobID, batch)
		}

		if len(accumulated) >= 5 {
			// requirement: first batch becomes available while remaining continue filtering
			// after reaching 5, we still keep filtering in this goroutine
		}
	}

	return nil
}
