package service

import (
	"context"
	config "somaiya-ext/configs"
	"somaiya-ext/internal/models"

	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
	"google.golang.org/api/keep/v1"
	"google.golang.org/api/option"
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
			"https://www.googleapis.com/auth/keep",
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

func CreateKeepNote(student models.Student, cfg *config.Config, title, content string) error {
	srv, err := NewKeepService(student, cfg)
	if err != nil {
		return err
	}

	note := &keep.Note{
		Title: title,
		Body: &keep.Section{
			Text: &keep.TextContent{
				Text: content,
			},
		},
	}

	_, err = srv.Notes.Create(note).Do()
	return err
}
