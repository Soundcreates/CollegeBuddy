package main

import (
	"fmt"
	"log"
	"net/http"
	"os"
	config "somaiya-ext/configs"
	handler "somaiya-ext/internal/handlers"
	"somaiya-ext/internal/models"
	routes "somaiya-ext/internal/router"

	"github.com/rs/cors"
)

func main() {
	//first we load config vars
	cfg := config.LoadConfig()
	//then we connect to db
	db, err := config.ConnectDB(cfg)
	if err != nil {
		log.Fatal(err)
	}
	db.AutoMigrate(&models.Student{}, &models.GmailMessage{})
	log.Println("Database migrated successfully")
	handler := handler.NewHandler(db, cfg)

	//this is the main Router
	mux := routes.RegisterRoutes(handler)
	extension_id := cfg.EXTENSION_ID
	allowedOrigins := []string{
		"http://localhost:5173",                               // Vite dev server
		"chrome-extension://" + extension_id, // Your Chrome extension
	}
	if os.Getenv("ALLOWED_ORIGIN") != "" {
		allowedOrigins = append(allowedOrigins, os.Getenv("ALLOWED_ORIGIN"))
	}

	// Configure CORS to allow requests from your frontend
	c := cors.New(cors.Options{
		AllowedOrigins: allowedOrigins,
		AllowedMethods: []string{
			"GET", "POST", "PUT", "DELETE", "OPTIONS",
		},
		AllowedHeaders: []string{
			"Content-Type",
			"Authorization",
		},
		ExposedHeaders: []string{
			"Content-Type",
		},
		AllowCredentials: true,
	})

	handler2 := c.Handler(mux)

	port := fmt.Sprintf(":%d", cfg.PORT)
	fmt.Println("Server starting on " + port)
	http.ListenAndServe(port, handler2)
}
