package service

import (
	"context"
	"log"
	"regexp"
	config "somaiya-ext/configs"
	"somaiya-ext/internal/models"
	"strings"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/keep/v1"
	"google.golang.org/api/option"
	"gorm.io/gorm"
)

func GoogleTokenSource(student models.Student, cfg *config.Config) oauth2.TokenSource {
	token := &oauth2.Token{
		AccessToken:  student.OAccessToken,
		RefreshToken: student.ORefreshToken,
		TokenType:    "Bearer",
	}

	oauthConfig := &oauth2.Config{
		ClientID:     cfg.OAUTH_CLIENT_ID,
		ClientSecret: cfg.OAUTH_CLIENT_SECRET,
		Scopes: []string{
		},
		Endpoint: google.Endpoint,
	}

	return oauthConfig.TokenSource(context.Background(), token)
}

func NewKeepService(student models.Student, cfg *config.Config) (*keep.Service, error) {
	ctx := context.Background()

	ts := GoogleTokenSource(student, cfg)

	srv, err := keep.NewService(ctx, option.WithTokenSource(ts))
	if err != nil {
		return nil, err
	}

	return srv, nil
}

// to jus clean the subject of the email, so the todo list message looks cleaner
func normalizeSubject(subject string) string {
	re := regexp.MustCompile(`(?i)^(re:|fwd:|\[.*?\])\s*`)
	return strings.TrimSpace(re.ReplaceAllString(subject, ""))
}

func GmailThreadsToKeepNote(
	messages []models.GmailMessage,
	title string,
) *keep.Note {
	items := []*keep.ListItem{}

	for _, msg := range messages {
		items = append(items, &keep.ListItem{
			Text: &keep.TextContent{
				Text: normalizeSubject(msg.Subject),
			},
			Checked: false,
		})

	}

	return &keep.Note{
		Title: title,
		Body: &keep.Section{
			List: &keep.ListContent{
				ListItems: items,
			},
		},
	}
}

func SendToKeep(noteInstance *keep.Note, db *gorm.DB, email string, cfg *config.Config) (error, bool) {
	log.Println("Welcome to sendkeep func")
	log.Println("Performing db lookup for: ", email)
	var student models.Student
	if err := db.Model(&student).Where("svv_email = ?", email).First(&student).Error; err != nil {
		log.Println("Error performing db look up at sendtokeep")
		return err, false
	}

	log.Println("Received the student details of : ", student.Name)

	keepService, err := NewKeepService(student, cfg)
	if err != nil {
		log.Println("Error happened at SendToKeep function: ", err)
		return err, false
	}

	log.Println("Sending note to keep..")
	_, err = keepService.Notes.Create(noteInstance).Do()
	if err != nil {
		log.Println(err)
		return err, false
	}
	return nil, true
}
