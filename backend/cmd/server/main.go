package main

import (
	"fmt"
	"net/http"
	config "somaiya-ext/configs"
	handler "somaiya-ext/internal/handlers"
	routes "somaiya-ext/internal/router"

)




func main() {

	//first we load config vars
	cfg := config.LoadConfig()
	//then we connect to db
	db, err := config.ConnectDB()
	if err !=nil {
		fmt.Printf("%s", err)
	}

	handler := handler.NewHandler(db, cfg)

	//this is the main Router
	routes.RegisterRoutes(handler)
	
	http.ListenAndServe(":8080", nil);

	
}