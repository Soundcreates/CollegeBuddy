package service

import (
	"fmt"
	"log"
	"somaiya-ext/internal/models"
	"strings"

	"gorm.io/gorm"
)

func StoreGmailMessages(db *gorm.DB, studentEmail string, messages []models.GmailMessage) (error, bool, []models.GmailMessage) {
	//first , find the student by email
	log.Println("Reached the gmail storing service function")
	var student models.Student
	if err := db.Where("svv_email = ?", studentEmail).First(&student).Error; err != nil {
		log.Println("Error finding student:", err.Error())
		return err, false, nil
	}
	log.Println("Student found:", student.SVVEmail)

	log.Println("Filtering the email messages before storing")
	var dummy []models.GmailMessage //send this for errors
	mailsToStore, err := FilterSomaiyaMails(messages)
	if err != nil {
		log.Println("Error filtering mails:", err.Error())
		return err, false, dummy
	}
	// Now, store each GmailMessage associated with the student
	for _, msg := range mailsToStore {

		var existingMail models.GmailMessage
		// msg.Student should be set to student's email before saving
		msg.Student = student.SVVEmail
		log.Printf("Checking if message %s already exists", msg.ThreadID)

		if err := db.Where("thread_id = ? ", msg.ThreadID).Find(&existingMail).Error; err == nil {
			log.Printf("Message Id: %s already exists in the database, so not storing it.")
			continue
		}
		log.Println("Now since the message doesnt already exist in the db, we will be storing them..")
		if err := db.Create(&msg).Error; err != nil {
			log.Fatalf("Error storing message ID %s: %v", msg.ID, err)
			return err, false, dummy
		}
		log.Printf("Message ID %s stored successfully\n", msg.ID)
	}

	log.Println("All messages processed for student:", student.SVVEmail)

	return nil, true, mailsToStore
}

func FilterSomaiyaMails(messages []models.GmailMessage) ([]models.GmailMessage, error) {
	log.Println("Reached filtering station")
	suffix := []string{"@somaiya.edu", "@classroom.google.com"}

	filteredMessages := []models.GmailMessage{} // Initialize as empty slice
	for _, msg := range messages {
		fmt.Printf("Trying to filter mail: %s \n", msg.ID)

		flag bool = false
		for _,mail := range service.Faculty_mail {
			if strings.Contains(msg.From, mail){
				flag = true
				break
			}
		}

		// Use Contains instead of HasSuffix because From header often comes as "Name <email@domain.com>"
		if flag && flag == true { //i know that just saying flag checks if its true or false, but just for safety
			fmt.Printf("Mail: %s, is going to be returned\n", msg.ID)
			filteredMessages = append(filteredMessages, msg)
		} else {
			fmt.Printf("Mail: %s, is being discarded \n", msg.ID)
		}
	}

	return filteredMessages, nil

}
