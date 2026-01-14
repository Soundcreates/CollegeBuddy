package service

import (
	"context"
	"log"
	"somaiya-ext/internal/models"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/gmail/v1"
	"google.golang.org/api/option"
	"gorm.io/gorm"
)

type GmailService struct {
	Config struct {
		OAuthClientID     string
		OAuthClientSecret string
	}
	DB *gorm.DB
}

func NewGmailService(clientID, clientSecret string) *GmailService {
	return &GmailService{}
}

func (gs *GmailService) GmailClientFromStoredToken(ctx context.Context, clientID, clientSecret, accessToken, refreshToken string, email string, db *gorm.DB) (*gmail.Service, error) {

	config := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  "http://localhost:8080/api/auth/google/callback",
		Scopes: []string{
			"https://www.googleapis.com/auth/gmail.readonly",
			"https://www.googleapis.com/auth/gmail.modify",
		},
		Endpoint: google.Endpoint,
	}

	// Create token with proper expiry so oauth2 library knows when to refresh
	// Set expiry to now so it will automatically refresh on first use
	token := &oauth2.Token{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
		Expiry:       time.Now(), // Set to now so it will refresh automatically
	}

	// Create a custom token source that will update DB when token is refreshed
	tokenSource := config.TokenSource(ctx, token)
	tokenSource = &dbTokenSource{
		source: tokenSource,
		db:     db,
		email:  email,
	}

	client := oauth2.NewClient(ctx, tokenSource)

	return gmail.NewService(ctx, option.WithHTTPClient(client))
}

// Custom token source that saves refreshed tokens to database
type dbTokenSource struct {
	source oauth2.TokenSource
	db     *gorm.DB
	email  string
}

func (dts *dbTokenSource) Token() (*oauth2.Token, error) {
	token, err := dts.source.Token()
	if err != nil {
		return nil, err
	}

	// If token was refreshed (has non-zero expiry), save to database
	if token.Expiry.Unix() > time.Now().Unix() {
		log.Printf("Token refreshed, saving to database for %s", dts.email)
		err = dts.db.Model(&models.Student{}).
			Where("svv_email = ?", dts.email).
			Updates(map[string]interface{}{
				"o_access_token":        token.AccessToken,
				"o_refresh_token":       token.RefreshToken,
				"o_access_token_expiry": token.Expiry.Unix(),
			}).Error
		if err != nil {
			log.Printf("Failed to save refreshed token: %v", err)
		}
	}

	return token, nil
}
