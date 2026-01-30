package config

import (
	"fmt"
	"time"

	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

func ConnectDB(cfg *Config) (*gorm.DB, error) {
	
	var dsn string
	if cfg.DATABASE_URL != "" {
		fmt.Println("Using DATABASE_URL for connection")
		dsn = cfg.DATABASE_URL
	} else {
		fmt.Printf("Connecting to db with: Host: %s, port = %s, user = %s, password=%s dbname= %s\n",
		cfg.DB_HOST, cfg.DB_PORT, cfg.DB_USER, cfg.DB_PASSWORD, cfg.DB_NAME)
		fmt.Println("Using individual DB parameters for connection")
		dsn = fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable TimeZone=Asia/Kolkata",
			cfg.DB_HOST, cfg.DB_USER, cfg.DB_PASSWORD, cfg.DB_NAME, cfg.DB_PORT)
	}

	var db *gorm.DB
	var err error
	maxRetries := 15
	for i := 0; i < maxRetries; i++ {
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
		if err == nil {
			fmt.Println("Successfully connected to the database")
			return db, nil
		}
		fmt.Printf("Failed to connect to database (attempt %d/%d): %v\n", i+1, maxRetries, err)
		time.Sleep(2 * time.Second)
	}
	fmt.Println("All attempts to connect to the database failed.")
	return nil, err
}
