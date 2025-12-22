package handlers

import (
	"encoding/json"
	"log"
	"net/http"
	"somaiya-ext/internal/models"
)

func (h *Handler) HandleCreateKeepNote(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	var student models.Student

	// Fix 1: Use r.Body (exported) instead of r.body
	// Fix 2: Decode only returns error
	if err := json.NewDecoder(r.Body).Decode(&student); err != nil {
		log.Println("Error decoding request body:", err)
		http.Error(w, "invalid request body", http.StatusBadRequest)
		return
	}

	log.Println("HandleCreateKeepNote called for:", student.SVVEmail)

	var messages []models.GmailMessage
	// Fix 3: Correct GORM syntax and scan into slice
	if err := h.DB.Where("student = ?", student.SVVEmail).Find(&messages).Error; err != nil {
		log.Println("Error fetching messages:", err)
		http.Error(w, "failed to fetch messages", http.StatusInternalServerError)
		return
	}

	// TODO: Call service to create note with these messages
	
}
