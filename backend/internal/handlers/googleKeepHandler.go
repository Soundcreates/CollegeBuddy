package handlers

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
	"somaiya-ext/service"
)

type createNoteRequest struct{
	Gmail string `json:"gmail"`
}
func (h *Handler) HandleCreateKeepNote(w http.ResponseWriter, r *http.Request) {
	log.Println("HandleCreateKeepNote called");
	w.Header().Set("Content-Type", "application/json")

	var req createNoteRequest
	// Fix 1: Use r.Body (exported) instead of r.body

	// Fix 2: Decode only returns error
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		log.Println("Error decoding request body:", err)
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	log.Println("HandleCreateKeepNote called for:", req.Gmail)

	var messages []models.GmailMessage
	// Fix 3: Correct GORM syntax and scan into slice
	if err := h.DB.Where("student = ?", req.Gmail).Find(&messages).Error; err != nil {
		log.Println("Error fetching messages:", err)
		http.Error(w, "failed to fetch messages", http.StatusInternalServerError)
		return
	}

	//gotta get the user profile for oauth tokens
	var student models.Student	
	if err := h.DB.Where("svv_email = ? ", req.Gmail).Find(&student); err != nil {
		log.Println("Error finding the student")
		http.Error(w,"Student lookup failed", http.StatusExpectationFailed)
		return	
	}
	
	content := ""
	for _, msg := range messages {
		content += fmt.Sprintf("Subject: %s || %s\n", msg.Subject, msg.Date)
	}

	if err := service.CreateKeepNote(student,h.Config,"Gmail Summary", content); err !=nil{
		log.Println("Error creating keep note:", err)
		http.Error(w, "Error creating keep note", http.StatusExpectationFailed)
	}

	json.NewEncoder(w).Encode(map[string]interface{}{
		"success" :true,
		"message": "Keep note created successfully",
	})


}
