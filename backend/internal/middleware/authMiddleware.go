package middleware

import (
	"log"
	"net/http"
	"os"
	"somaiya-ext/internal/auth"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

func WithAuth(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		log.Println("AuthMiddleware: Checking Authorization header")
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
			log.Println("Middleware saying authHeader missing")
			http.Error(w, "Authorization header required", http.StatusUnauthorized)
			return
		}

		// Extract token (format: "Bearer <token>")
		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == authHeader {
			http.Error(w, "Invalid authorization format", http.StatusUnauthorized)
			return
		}

		// Parse and validate JWT token
		_, err := auth.ParseJwt(tokenString, os.Getenv("JWT_SECRET"))
		if err != nil {
			if err == jwt.ErrTokenExpired {
				log.Println("Access token expired. Client should refresh token.")
				http.Error(w, "Token expired. Please refresh your token.", http.StatusUnauthorized)
				return
			}
			log.Println("Token validation failed:", err)
			http.Error(w, "Invalid token: "+err.Error(), http.StatusUnauthorized)
			return
		}

		log.Println("Token validation successful")
		// Token is valid, proceed to next handler
		next.ServeHTTP(w, r)
	})
}
