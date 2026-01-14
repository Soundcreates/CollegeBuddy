package models

type GmailMessage struct {
	ID       string `json:"id" gorm:"primaryKey unique"`
	ThreadID string `json:"threadId" gorm:"column:thread_id"`
	Subject  string `json:"subject"`
	From     string `json:"from"`
	To       string `json:"to"`
	Date     string `json:"date"`
	Student  string `json:"student"`          // Foreign key to Student's SVVEmail
	Snippet  string `json:"snippet" gorm:"-"` // Not stored in DB
	Body     string `json:"body" gorm:"-"`    // Not stored in DB
}
