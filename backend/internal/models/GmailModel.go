package models



type GmailMessage struct {
	ID      string `json:"id" gorm:"primaryKey"`
	ThreadID string `json:"threadId"`
	Subject string `json:"subject"`
	From    string `json:"from"`
	To      string `json:"to"`
	Date    string `json:"date"`
	Student string `json:"student"` // Foreign key to Student's SVVEmail

}