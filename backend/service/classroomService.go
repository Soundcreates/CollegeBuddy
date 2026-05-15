package service

import (
	"context"
	"net/http"
	"time"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/classroom/v1"
	"google.golang.org/api/option"
	"gorm.io/gorm"
)

// ClassroomClientFromStoredToken creates an authenticated Google Classroom service
// using stored OAuth tokens. It reuses the dbTokenSource for automatic token persistence.
func ClassroomClientFromStoredToken(ctx context.Context, clientID, clientSecret, accessToken, refreshToken, email string, db *gorm.DB) (*classroom.Service, error) {
	config := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  "https://collegebuddy-service.onrender.com/api/auth/google/callback",
		Scopes: []string{
			"https://www.googleapis.com/auth/classroom.courses.readonly",
			"https://www.googleapis.com/auth/classroom.coursework.me",
			"https://www.googleapis.com/auth/classroom.student-submissions.me.readonly",
			"https://www.googleapis.com/auth/drive.readonly",
		},
		Endpoint: google.Endpoint,
	}

	token := &oauth2.Token{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
		Expiry:       time.Now(), // Force refresh on first use
	}

	tokenSource := config.TokenSource(ctx, token)
	tokenSource = &dbTokenSource{
		source: tokenSource,
		db:     db,
		email:  email,
	}

	client := oauth2.NewClient(ctx, tokenSource)

	return classroom.NewService(ctx, option.WithHTTPClient(client))
}

// GoogleHTTPClientFromStoredToken builds an OAuth2 HTTP client that auto-refreshes
// Google access tokens and persists refreshed tokens to DB.
func GoogleHTTPClientFromStoredToken(ctx context.Context, clientID, clientSecret, accessToken, refreshToken, email string, db *gorm.DB) *http.Client {
	config := &oauth2.Config{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		RedirectURL:  "https://collegebuddy-service.onrender.com/api/auth/google/callback",
		Scopes: []string{
			"https://www.googleapis.com/auth/drive.readonly",
		},
		Endpoint: google.Endpoint,
	}

	token := &oauth2.Token{
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
		TokenType:    "Bearer",
		Expiry:       time.Now(), // Force refresh on first use
	}

	tokenSource := config.TokenSource(ctx, token)
	tokenSource = &dbTokenSource{
		source: tokenSource,
		db:     db,
		email:  email,
	}

	return oauth2.NewClient(ctx, tokenSource)
}
