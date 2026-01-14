package service

import (
	"fmt"
	"log"
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
