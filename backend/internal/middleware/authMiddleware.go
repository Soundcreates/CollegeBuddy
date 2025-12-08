package middleware

import (
	"net/http"
	"os"
	"somaiya-ext/internal/auth"
	"strings"
)

func WithAuth(next http.HandlerFunc) http.HandlerFunc {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		authHeader := r.Header.Get("Authorization")
		if authHeader == "" {
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
			http.Error(w, "Invalid token: "+err.Error(), http.StatusUnauthorized)
			return
		}
		

		// Token is valid, proceed to next handler
		next.ServeHTTP(w,r)
	})
}
