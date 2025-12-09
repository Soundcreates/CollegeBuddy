package main

import (
	"fmt"
	"net/http"
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
		fmt.Printf("%s", err)
	}
	db.AutoMigrate(&models.Student{})

	handler := handler.NewHandler(db, cfg)

	//this is the main Router
	mux := routes.RegisterRoutes(handler)

	// Configure CORS to allow requests from your frontend
	c := cors.New(cors.Options{
		AllowedOrigins: []string{
			"http://localhost:5173",                               // Vite dev server
			"chrome-extension://jkbjennlilioelogocancfjnplomepcl", // Your Chrome extension
		},
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

	fmt.Println("Server starting on :8080")
	http.ListenAndServe(":8080", handler2)
}
