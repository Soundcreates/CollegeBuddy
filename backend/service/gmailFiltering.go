package service

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"somaiya-ext/internal/models"
	"sync"
	"time"
)

// Email represents the schema expected by scraperService
type FilterableEmail struct {
	ID       string `json:"id,omitempty"`
	Subject  string `json:"subject"`
	Sender   string `json:"sender"`
	Body     string `json:"body"`
	Date     string `json:"date"`
	RawEmail string `json:"raw_email,omitempty"`
}

// FilteredEmailResult represents a filtered email from scraperService
type FilteredEmailResult struct {
	ID         string  `json:"id,omitempty"`
	Subject    string  `json:"subject"`
	Sender     string  `json:"sender"`
	Body       string  `json:"body"`
	Category   string  `json:"category"`
	Confidence float64 `json:"confidence"`
	Date       string  `json:"date,omitempty"`
}

// FilterResponse represents the full response from scraperService
type FilterResponse struct {
	Success       bool                             `json:"success"`
	Date          string                           `json:"date,omitempty"`
	TotalEmails   int                              `json:"total_emails"`
	FilteredCount int                              `json:"filtered_count"`
	ByCategory    map[string][]FilteredEmailResult `json:"by_category"`
	AllFiltered   []FilteredEmailResult            `json:"all_filtered"`
}


// FilterEmails sends emails to AI filtration service and returns organized results
func FilterEmails(mails []models.GmailMessage, filterDate string) (FilterResponse, error) {
	log.Println("Starting AI-based email filtration...")

	if len(mails) == 0 {
		log.Println("No emails to filter")
		return FilterResponse{
			Success:       true,
			Date:          filterDate,
			TotalEmails:   0,
			FilteredCount: 0,
			ByCategory:    make(map[string][]FilteredEmailResult),
			AllFiltered:   []FilteredEmailResult{},
		}, nil
	}

	// Convert GmailMessage to FilterableEmail format
	filterableEmails := make([]FilterableEmail, 0)
	for _, msg := range mails {
		email := FilterableEmail{
			ID:      msg.ID,
			Subject: msg.Subject,
			Sender:  msg.From,
			Body:    msg.Body,
			Date:    msg.Date,
		}

		// Use snippet as fallback if body is empty
		if email.Body == "" {
			email.Body = msg.Snippet
		}

		// Only include emails with at least some content
		if email.Subject != "" || email.Body != "" {
			filterableEmails = append(filterableEmails, email)
		}
	}

	if len(filterableEmails) == 0 {
		log.Println("No emails with valid content to filter")
		return FilterResponse{
			Success:       true,
			Date:          filterDate,
			TotalEmails:   len(mails),
			FilteredCount: 0,
			ByCategory:    make(map[string][]FilteredEmailResult),
			AllFiltered:   []FilteredEmailResult{},
		}, nil
	}

	// We'll send emails to scraperService in fixed-size batches to avoid classification timeouts.
	// Strategy:
	// - Batch size: 5 emails per request.
	// - Use a semaphore-limited worker pool to run multiple requests concurrently (configurable via env `SCRAPER_MAX_CONCURRENCY`).
	// - Collect and merge all responses into a single FilterResponse.
	const batchSize = 5

	maxConc := 4
	if v := os.Getenv("SCRAPER_MAX_CONCURRENCY"); v != "" {
		if parsed, err := fmt.Sscanf(v, "%d", &maxConc); parsed == 0 || err != nil {
			// keep default if parse fails
			maxConc = 4
		}
	}

	// helper to post a payload to scraper service (same as before)
	postToScraper := func(emailsChunk []FilterableEmail) (FilterResponse, error) {
		payload := map[string]interface{}{
			"emails": emailsChunk,
			"date":   filterDate,
		}
		jsonPayload, err := json.Marshal(payload)
		if err != nil {
			log.Printf("Error marshaling chunk request: %v", err)
			return FilterResponse{}, fmt.Errorf("error marshaling request: %w", err)
		}

		scraperURL := GetScraperServiceURL() + "/filter-emails"
		log.Printf("[DEBUG] Posting %d emails to scraperService at: %s", len(emailsChunk), scraperURL)

		req, err := http.NewRequest("POST", scraperURL, bytes.NewReader(jsonPayload))
		if err != nil {
			log.Printf("Error creating request: %v", err)
			return FilterResponse{}, fmt.Errorf("error creating request: %w", err)
		}
		req.Header.Set("Content-Type", "application/json")

		client := &http.Client{Timeout: 120 * time.Second}
		start := time.Now()
		resp, err := client.Do(req)
		duration := time.Since(start)
		if err != nil {
			log.Printf("Error making request to scraperService: %v (duration: %s)", err, duration)
			return FilterResponse{}, fmt.Errorf("error calling scraperService: %w", err)
		}
		defer resp.Body.Close()

		respBody, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("Error reading response: %v", err)
			return FilterResponse{}, fmt.Errorf("error reading response: %w", err)
		}

		if resp.StatusCode < 200 || resp.StatusCode >= 300 {
			log.Printf("ScraperService returned status %d: %s", resp.StatusCode, string(respBody))
			return FilterResponse{}, fmt.Errorf("scraperService returned status %d", resp.StatusCode)
		}

		var fr FilterResponse
		if err := json.Unmarshal(respBody, &fr); err != nil {
			log.Printf("Error parsing response: %v", err)
			return FilterResponse{}, fmt.Errorf("error parsing response: %w", err)
		}
		log.Printf("[DEBUG] scraperService processed %d emails in %s -> filtered %d", fr.TotalEmails, duration, fr.FilteredCount)
		return fr, nil
	}

	// Build batches
	n := len(filterableEmails)
	var batches [][]FilterableEmail
	for i := 0; i < n; i += batchSize {
		end := i + batchSize
		if end > n {
			end = n
		}
		batches = append(batches, filterableEmails[i:end])
	}

	log.Printf("[BATCH] Created %d batches (batchSize=%d) for %d emails", len(batches), batchSize, n)

	// Concurrency control
	sem := make(chan struct{}, maxConc)
	var wg sync.WaitGroup
	resCh := make(chan FilterResponse, len(batches))
	errCh := make(chan error, len(batches))

	for _, b := range batches {
		wg.Add(1)
		sem <- struct{}{}
		go func(chunk []FilterableEmail) {
			defer wg.Done()
			defer func() { <-sem }()
			fr, err := postToScraper(chunk)
			if err != nil {
				errCh <- err
				return
			}
			resCh <- fr
		}(b)
	}

	// wait for workers
	go func() {
		wg.Wait()
		close(resCh)
		close(errCh)
	}()

	// aggregate results
	final := FilterResponse{
		Success:       true,
		Date:          filterDate,
		TotalEmails:   0,
		FilteredCount: 0,
		ByCategory:    make(map[string][]FilteredEmailResult),
		AllFiltered:   []FilteredEmailResult{},
	}

	// collect responses
	var firstErr error
	for r := range resCh {
		final.TotalEmails += r.TotalEmails
		final.FilteredCount += r.FilteredCount
		for k, v := range r.ByCategory {
			final.ByCategory[k] = append(final.ByCategory[k], v...)
		}
		final.AllFiltered = append(final.AllFiltered, r.AllFiltered...)
	}
	// capture any error
	select {
	case e := <-errCh:
		firstErr = e
	default:
	}

	if firstErr != nil {
		return FilterResponse{}, firstErr
	}

	log.Printf("AI filtration completed: %d/%d emails marked as important", final.FilteredCount, final.TotalEmails)
	return final, nil
}

// GetScraperServiceURL returns the scraperService URL (configurable via env)
func GetScraperServiceURL() string {
	url := os.Getenv("SCRAPER_SERVICE_URL")
	if url == "" {
		url = "https://kisha-volcanologic-motherly.ngrok-free.dev"
	}
	return url
}
