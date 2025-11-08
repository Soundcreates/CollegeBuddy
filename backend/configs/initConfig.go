package config

import (
	"fmt"
	"os"
	"strconv"

)

type Config struct{
	DB_URI string
	DB_HOST string
	DB_PORT string
	PORT int
	DB_PASSWORD string
	DB_NAME string
	DB_USER string

}

func LoadConfig() *Config{
	fmt.Println("Loading config vars....")

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
		DB_URI : os.Getenv("DB_URI"),
		DB_HOST : os.Getenv("DB_HOST"),
		DB_NAME: os.Getenv("DB_NAME"),
		PORT: port,
		DB_PASSWORD: os.Getenv("DB_PASSWORD"),
		DB_PORT: os.Getenv("DB_PORT"),
		DB_USER: os.Getenv("DB_USER"),

	}

	return cfg
}