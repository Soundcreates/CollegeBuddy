package models

import (
	"gorm.io/gorm"
)

type Student struct {
	gorm.Model
	ID            string `json:"id" gorm:"primaryKey"`
	Name          string `json:"name"`
	SVVNetId      string `json:"svv_net_id" gorm:"unique"`
	SVVEmail      string `json:"email" gorm:"unique"`
	ProfilePic    string `json:"picture"`
	VerifiedEmail bool   `json:"verified_email"`
}

type GoogleUser struct {
	ID            string `json:"id"`
	Email         string `json:"email"`
	VerifiedEmail bool   `json:"verified_email"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
	GivenName     string `json:"given_name"`
	FamilyName    string `json:"family_name"`
}
