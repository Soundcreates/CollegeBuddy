package handlers

import (
	config "somaiya-ext/configs"

	"gorm.io/gorm"
)

type Handler struct {
	DB        *gorm.DB
	Config    *config.Config
	gmailJobs *gmailStreamJobStore
}

func NewHandler(db *gorm.DB, cfg *config.Config) *Handler {
	h := &Handler{
		DB:        db,
		Config:    cfg,
		gmailJobs: newGmailStreamJobStore(),
	}

	return h
}
