package models

import "time"

type Attatchment struct {
	Filename      string `json:"filename"`
	MimeType      string `json:"mimeType"`
	AttatchmentId string `json:"attachmentId"`
}

type GmailMessage struct {
	ID           string        `json:"id"`
	ThreadID     string        `json:"threadId"`
	Subject      string        `json:"subject"`
	From         string        `json:"from"`
	To           string        `json:"to"`
	Date         string        `json:"date"`
	Student      string        `json:"student"` // Foreign key to Student's SVVEmail
	Snippet      string        `json:"snippet"` // Not stored in DB
	Body         string        `json:"body"`    // Not stored in DB
	Attatchments []Attatchment `json:"attachments" gorm:"-"`
	// CreatedAt is managed by GORM autoCreateTime; existing rows get zero time.
	CreatedAt time.Time `json:"created_at" gorm:"autoCreateTime"`
}
