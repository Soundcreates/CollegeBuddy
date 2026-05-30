package handlers

import (
	"context"
	"fmt"
	"log"
	"somaiya-ext/internal/models"
	"somaiya-ext/service"
	"strings"
	"time"

	"google.golang.org/api/gmail/v1"
)

func fetchAttachmentsByMessageIDs(gmailClient *gmail.Service, messageIDs []string) map[string][]models.Attatchment {
	attachmentsByID := make(map[string][]models.Attatchment, len(messageIDs))
	for _, id := range messageIDs {
		if id == "" {
			continue
		}
		msg, err := gmailClient.Users.Messages.Get("me", id).Format("full").Do()
		if err != nil {
			log.Printf("Failed to fetch attachments for message ID %s: %v", id, err)
			attachmentsByID[id] = []models.Attatchment{}
			continue
		}
		attachmentsByID[id] = extractAttachmentsFromPayload(msg.Payload)
	}
	return attachmentsByID
}

func (h *Handler) scrapeAndFilterGmail(ctx context.Context, email, accessToken, refreshToken string) (map[string]interface{}, error) {
	gmailService := service.NewGmailService(h.Config.OAUTH_CLIENT_ID, h.Config.OAUTH_CLIENT_SECRET)

	gmailClient, err := gmailService.GmailClientFromStoredToken(
		ctx,
		h.Config.OAUTH_CLIENT_ID,
		h.Config.OAUTH_CLIENT_SECRET,
		accessToken,
		refreshToken,
		email,
		h.DB,
	)
	if err != nil {
		return nil, fmt.Errorf("failed to create gmail client: %w", err)
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
		call := gmailClient.Users.Messages.List("me").Q(query).MaxResults(25)
		if pageToken != "" {
			call = call.PageToken(pageToken)
		}

		messages, err := call.Do()
		if err != nil {
			return nil, fmt.Errorf("failed to fetch emails: %w", err)
		}

		for i := range messages.Messages {
			msg, err := gmailClient.Users.Messages.Get("me", messages.Messages[i].Id).Format("full").Do()
			if err != nil {
				log.Printf("Failed to fetch message details for ID %s: %v", messages.Messages[i].Id, err)
				continue
			}

			msgData := models.GmailMessage{
				ID:       msg.Id,
				ThreadID: msg.ThreadId,
				Student:  email,
				Snippet:  msg.Snippet,
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

	// First-stage filtering: sender whitelist (before AI filtering)
	whitelistedMessages := filterByWhitelist(parsedMessages)
	log.Printf("Sender whitelist filter: %d/%d emails passed (removed %d non-whitelisted)",
		len(whitelistedMessages), len(parsedMessages), len(parsedMessages)-len(whitelistedMessages))

	return buildScrapeResponse(gmailClient, whitelistedMessages), nil
}

func buildScrapeResponse(gmailClient *gmail.Service, parsedMessages []models.GmailMessage) map[string]interface{} {
	today := time.Now().Format("2006-01-02")
	filterResponse, err := service.FilterEmails(parsedMessages, today)
	if err != nil {
		log.Printf("Error during AI filtration: %v", err)
		log.Println("Proceeding with unfiltered emails as fallback")

		fallbackMessages := make([]map[string]interface{}, 0, len(parsedMessages))
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

		return map[string]interface{}{
			"success":        false,
			"messages":       fallbackMessages,
			"total_emails":   len(parsedMessages),
			"filtered_count": 0,
			"by_category":    map[string]interface{}{},
			"count":          len(parsedMessages),
			"error":          err.Error(),
			"note":           "Returning all emails due to filtration error",
		}
	}
	filteredMessageIDs := make([]string, 0, len(filterResponse.AllFiltered))
	for _, filtered := range filterResponse.AllFiltered {
		if filtered.ID != "" {
			filteredMessageIDs = append(filteredMessageIDs, filtered.ID)
		}
	}
	attachmentsByID := fetchAttachmentsByMessageIDs(gmailClient, filteredMessageIDs)

	transformedMessages := make([]map[string]interface{}, 0, len(filterResponse.AllFiltered))
	for _, filtered := range filterResponse.AllFiltered {
		attachments := attachmentsByID[filtered.ID]
		if attachments == nil {
			attachments = []models.Attatchment{}
		}
		transformedMessages = append(transformedMessages, map[string]interface{}{
			"id":          filtered.ID,
			"subject":     filtered.Subject,
			"from":        filtered.Sender,
			"to":          "",
			"date":        filtered.Date,
			"snippet":     "",
			"body":        filtered.Body,
			"category":    filtered.Category,
			"confidence":  filtered.Confidence,
			"attachments": attachments,
		})
	}

	transformedByCategory := make(map[string][]map[string]interface{}, len(filterResponse.ByCategory))
	for categoryGroup, emails := range filterResponse.ByCategory {
		transformedByCategory[categoryGroup] = make([]map[string]interface{}, 0, len(emails))
		for _, filtered := range emails {
			attachments := attachmentsByID[filtered.ID]
			if attachments == nil {
				attachments = []models.Attatchment{}
			}
			transformedByCategory[categoryGroup] = append(transformedByCategory[categoryGroup], map[string]interface{}{
				"id":          filtered.ID,
				"subject":     filtered.Subject,
				"from":        filtered.Sender,
				"to":          "",
				"date":        filtered.Date,
				"snippet":     "",
				"body":        filtered.Body,
				"category":    filtered.Category,
				"confidence":  filtered.Confidence,
				"attachments": attachments,
			})
		}
	}

	return map[string]interface{}{
		"success":        true,
		"messages":       transformedMessages,
		"total_emails":   filterResponse.TotalEmails,
		"filtered_count": filterResponse.FilteredCount,
		"by_category":    transformedByCategory,
		"all_filtered":   transformedMessages,
		"date":           today,
	}
}

// filterByWhitelist: First-stage filtering - only keep emails from whitelisted senders
// This runs in the Go backend before sending to AI filtering
func filterByWhitelist(messages []models.GmailMessage) []models.GmailMessage {
	facultyMails := *service.GetFacultyMails()
	// Create a map for O(1) lookup
	whitelistMap := make(map[string]bool)
	for _, mail := range facultyMails {
		whitelistMap[strings.ToLower(mail)] = true
	}

	filtered := make([]models.GmailMessage, 0, len(messages))
	for _, msg := range messages {
		// Extract email address from "Name <email@domain>" format
		senderEmail := extractEmailAddress(msg.From)
		senderEmailLower := strings.ToLower(senderEmail)

		// Check if sender is in whitelist
		if whitelistMap[senderEmailLower] {
			filtered = append(filtered, msg)
		} else {
			log.Printf("Email from %s rejected: sender not in whitelist (subject: %s)", senderEmail, msg.Subject)
		}
	}

	return filtered
}

// extractEmailAddress: Extract email from "Name <email@domain>" or plain email format
func extractEmailAddress(from string) string {
	from = strings.TrimSpace(from)

	// Handle "Name <email@domain>" format
	if strings.Contains(from, "<") && strings.Contains(from, ">") {
		start := strings.Index(from, "<")
		end := strings.Index(from, ">")
		if start < end {
			return strings.TrimSpace(from[start+1 : end])
		}
	}

	// Return as-is if already plain email
	return from
}
