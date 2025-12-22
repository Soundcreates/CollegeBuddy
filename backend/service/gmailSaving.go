package service

import (
	"log"
	"somaiya-ext/internal/models"
	"strings"

	"gorm.io/gorm"
)

func StoreGmailMessages(db *gorm.DB, studentEmail string, messages []models.GmailMessage) (error, bool) {
	//first , find the student by email
	log.Println("Reached the gmail storing service function")
	var student models.Student
	if err := db.Where("svv_email = ?", studentEmail).First(&student).Error; err != nil {
		log.Println("Error finding student:", err.Error())
		return err, false
	}
	log.Println("Student found:", student.SVVEmail)

	log.Println("Filtering the email messages before storing")
	mailsToStore , err:= FilterMails(messages)
	if err != nil {
		log.Println("Error filtering mails:", err.Error())
		return err, false
	}
	// Now, store each GmailMessage associated with the student
	for _, msg := range mailsToStore {
		log.Println("Storing message ID:", msg.ID)
	// msg.Student should be set to student's email before saving
		msg.Student = student.SVVEmail
		if err := db.Find(&models.GmailMessage{}).Where("id = ?", msg.ID).Error; err != nil {
			log.Printf("Message ID %s already exists, skipping\n", msg.ID)
			continue
		}
		if err := db.Create(&msg).Error; err != nil {
			log.Fatalf("Error storing message ID %s: %v", msg.ID, err)
			return err, false
		}
		log.Printf("Message ID %s stored successfully\n", msg.ID)
	}

	log.Println("All messages processed for student:", student.SVVEmail)

	return nil, true
}





func FilterMails(messages []models.GmailMessage) ([]models.GmailMessage, error) {


	var filteredMessages []models.GmailMessage
	for _, msg := range messages {
		//TODO: add filtering logic here
		score := 0.0
		signals := []string{}

		suffixToCheck:= "somaiya.edu"

		if strings.HasSuffix(msg.From,suffixToCheck) {
			score += 0.5
			signals = append(signals, "edu_domain")
		}

		keywords := []string{"exam", "assignment", "lecture", "professor", "results", "syllabus", "semester", "university", "campus", "somaiya","computer", "engineering"}
		for _, k := range keywords {
			if strings.Contains(strings.ToLower(msg.Subject), k) {
				score += 0.2
				signals = append(signals, "keyword_"+k)
			}
		}

		IsUniversity := score >=0.6
		if(IsUniversity){

			filteredMessages = append(filteredMessages, msg)
		}else{
			continue;
		}


		
	}

	return filteredMessages, nil		
}