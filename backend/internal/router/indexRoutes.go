package routes

import (
	"net/http"
	handler "somaiya-ext/internal/handlers"
)


func RegisterRoutes(h *handler.Handler){
	
	mainRouter := http.NewServeMux()

	authRouter := http.NewServeMux()

	mainRouter.Handle("/api", http.StripPrefix("/api", authRouter))

	registerAuthRoutes(h, authRouter)


	
}