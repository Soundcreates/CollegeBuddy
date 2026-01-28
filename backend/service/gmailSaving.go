package service

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
	"strings"
)

func FilterSomaiyaMails(messages []models.GmailMessage) ([]models.GmailMessage, error) {
	log.Println("Reached filtering station")

	filteredMessages := []models.GmailMessage{} // Initialize as empty slice
	for _, msg := range messages {
		fmt.Printf("Trying to filter mail that was sent from : %s \n", strings.ToLower(msg.From))

		flag := false
		lowerSender := strings.ToLower(msg.From)
		facultyMails := GetFacultyMails()
		if len(*facultyMails) == 0 {
			fmt.Println("Faculty mails list is empty")
		}
		fmt.Println("Checking against faculty mails now: ")
		for _, mail := range *facultyMails {
			if strings.Contains(lowerSender, mail) {
				fmt.Println("Matched faculty mail: ", mail)
				flag = true
				break
			}
		}

		if flag == true { //i know that just saying flag checks if its true or false, but just for safety
			fmt.Printf("Mail: %s, is going to be returned\n", msg.ID)
			filteredMessages = append(filteredMessages, msg)
		} else {
			fmt.Printf("Mail: %s, is being discarded \n", msg.ID)
		}
	}

	return filteredMessages, nil

}

func TextFilter(messages []models.GmailMessage) ([]models.GmailMessage, error) {
	log.Println("Reached text filtering station")
	url := "http://localhost:8000/text-classification"

	// Collect email bodies (or snippets) into a slice
	var texts []string
	for _, msg := range messages {
		if msg.Body != "" {
			texts = append(texts, msg.Body)
		} else if msg.Snippet != "" {
			texts = append(texts, msg.Snippet)
		}
	}

	// Prepare JSON payload
	jsonPayload := fmt.Sprintf(`{"text":%s}`, marshalStringSlice(texts))
	payload := strings.NewReader(jsonPayload)

	req, err := http.NewRequest("POST", url, payload)
	if err != nil {
		return nil, err
	}
	req.Header.Set("Content-Type", "application/json")

	client := &http.Client{}
	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return nil, err
	}

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

// Helper to marshal []string to JSON array
func marshalStringSlice(slice []string) string {
	var b strings.Builder
	b.WriteString("[")
	for i, s := range slice {
		b.WriteString(fmt.Sprintf("%q", s))
		if i < len(slice)-1 {
			b.WriteString(",")
		}
	}
	b.WriteString("]")
	return b.String()
}
