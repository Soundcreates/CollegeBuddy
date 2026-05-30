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
	"strings"
	"time"
)

func FilterSomaiyaMails(messages []models.GmailMessage) ([]models.GmailMessage, error) {
	log.Println("Reached filtering station")

	filteredMessages := []models.GmailMessage{} // Initialize as empty slice
	for _, msg := range messages {

		flag := false
		lowerSender := strings.ToLower(msg.From)
		if strings.Contains(lowerSender, "somaiya.edu") {
			flag = true
		}

		if flag == true { //i know that just saying flag checks if its true or false, but just for safety
			filteredMessages = append(filteredMessages, msg)
		}

	}

	return filteredMessages, nil

}

func TextFilter(messages []models.GmailMessage) ([]models.GmailMessage, error) {
	url := strings.TrimSpace(os.Getenv("SCRAPER_SERVICE_URL"))
	if url == "" {
		url = "https://kisha-volcanologic-motherly.ngrok-free.dev"
	}
	url = url + "/text-classification"
	log.Printf("Starting to contact the ai: %s", url)

	// Collect email bodies (or snippets) into a slice
	var texts []string
	for _, msg := range messages {
		if msg.Body != "" {
			texts = append(texts, msg.Body)
		} else if msg.Snippet != "" {
			texts = append(texts, msg.Snippet)
		}
	}

	if len(texts) == 0 {
		log.Println("Skipping AI call: no message body/snippet available to classify")
		return []models.GmailMessage{}, nil
	}

	// Prepare JSON payload
	jsonPayload, err := json.Marshal(map[string][]string{"text": texts})
	if err != nil {
		return nil, err
	}
	payload := bytes.NewReader(jsonPayload)

	req, err := http.NewRequest("POST", url, payload)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{Timeout: 60 * time.Second}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

	if resp.StatusCode < 200 || resp.StatusCode >= 300 {
		return nil, fmt.Errorf("python service returned status %d: %s", resp.StatusCode, string(body))
	}
	log.Printf("AI service response status=%d body=%s", resp.StatusCode, string(body))

	// Parse response
	type FilteredItem struct {
		Text       string  `json:"text"`
		Label      string  `json:"label"`
		Confidence float64 `json:"confidence"`
	}
	type Response struct {
		Filtered []FilteredItem `json:"filtered"`
	}
	var respData Response
	err = json.Unmarshal(body, &respData)
	if err != nil {
		return nil, err
	}

	// Filter original messages by matching text
	filteredMessages := []models.GmailMessage{}
	textSet := make(map[string]struct{})
	for _, item := range respData.Filtered {
		textSet[item.Text] = struct{}{}
	}
	for _, msg := range messages {
		if _, ok := textSet[msg.Body]; ok {
			filteredMessages = append(filteredMessages, msg)
		} else if _, ok := textSet[msg.Snippet]; ok {
			filteredMessages = append(filteredMessages, msg)
		}
	}

	return filteredMessages, nil
}
