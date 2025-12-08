package service

import (
	"context"
	"fmt"
	"somaiya-ext/internal/models"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/gmail/v1"
	"google.golang.org/api/option"
)

type GmailService struct {
	Config struct {
		OAuthClientID     string
		OAuthClientSecret string
	}
}

func NewGmailService(clientID, clientSecret string) *GmailService {
	return &GmailService{}
}

func (gs *GmailService) GmailClientFromStoredToken(ctx context.Context, clientID, clientSecret, accessToken, refreshToken string) (*gmail.Service, error) {

	config := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  "http://localhost:8080/api/auth/google/callback",
		Scopes: []string{
			"https://www.googleapis.com/auth/gmail.readonly",
		},
		Endpoint: google.Endpoint,
	}
	token := &oauth2.Token{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
	}

	client := config.Client(ctx, token)

	return gmail.NewService(ctx, option.WithHTTPClient(client))
}

func (gs *GmailService) ScrapeGmailEmails(ctx context.Context, student models.Student) ([]*gmail.Message, error) {
	if student.OAccessToken == "" {
		return nil, fmt.Errorf("access token not found for student %s", student.SVVEmail)
	}

	gmailService, err := gs.GmailClientFromStoredToken(ctx, gs.Config.OAuthClientID, gs.Config.OAuthClientSecret, student.OAccessToken, student.ORefreshToken)
	if err != nil {
		return nil, err
	}

	// Query Gmail API for messages
	results, err := gmailService.Users.Messages.List("me").MaxResults(10).Do()
	if err != nil {
		return nil, err
	}

	return results.Messages, nil
}
