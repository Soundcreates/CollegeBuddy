package main

import (
	"fmt"
	"net/http"
	config "somaiya-ext/configs"
	handler "somaiya-ext/internal/handlers"
	"somaiya-ext/internal/models"
	routes "somaiya-ext/internal/router"
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
	routes.RegisterRoutes(handler)

	http.ListenAndServe(":8080", nil)

}
