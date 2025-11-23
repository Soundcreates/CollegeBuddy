package config

import (
	"log"
	"os"
	"strconv"

	"github.com/joho/godotenv"
)

type Config struct {
	DB_URI              string
	DB_HOST             string
	DB_PORT             string
	PORT                int
	DB_PASSWORD         string
	DB_NAME             string
	DB_USER             string
	OAUTH_CLIENT_ID     string
	OAUTH_CLIENT_SECRET string
	JWT_SECRET          string
	EXTENSION_ID        string
}

func LoadConfig() *Config {
	log.Println("Loading config vars....")
	err := godotenv.Load()
	if err != nil {
		log.Fatal("Error loading env vars")
	}

	portStr := os.Getenv("PORT")
	port := 8080 //default port no
	if portStr != "" {
		if p, err := strconv.Atoi(portStr); err == nil {
			port = p
		}
	}

	// dbPort := 5432
	// if db_port != "" {
	// 	if dbp, err := strconv.Atoi(db_port); err == nil {
	// 		dbPort = dbp
	// 	}
	// }

	cfg := &Config{
		DB_URI:              os.Getenv("DB_URI"),
		DB_HOST:             os.Getenv("DB_HOST"),
		DB_NAME:             os.Getenv("DB_NAME"),
		PORT:                port,
		DB_PASSWORD:         os.Getenv("DB_PASSWORD"),
		DB_PORT:             os.Getenv("DB_PORT"),
		DB_USER:             os.Getenv("DB_USER"),
		OAUTH_CLIENT_ID:     os.Getenv("OAUTH_CLIENT_ID"),
		OAUTH_CLIENT_SECRET: os.Getenv("OAUTH_CLIENT_SECRET"),
		JWT_SECRET:          os.Getenv("JWT_SECRET"),
		EXTENSION_ID:        os.Getenv("EXTENSION_ID"),
	}

	return cfg
}
