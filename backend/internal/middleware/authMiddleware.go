package middleware

import (
	"fmt"
	"log"
	"net/http"
	"os"
	"somaiya-ext/internal/auth"
	"somaiya-ext/internal/handlers"
	"somaiya-ext/internal/models"
	"strings"

	"github.com/golang-jwt/jwt/v5"
)

func WithAuth(h *handlers.Handler) func(http.HandlerFunc) http.HandlerFunc {
	return func(next http.HandlerFunc) http.HandlerFunc {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			log.Println("AuthMiddleware: Checking Authorization header")
			authHeader := r.Header.Get("Authorization")
			if authHeader == "" {
				log.Println("Middleware saying authHeader missing")
				http.Error(w, "Authorization header required", http.StatusUnauthorized)
				return
			}

			// Extract token (format: "Bearer <token>")
			log.Println("trimming the bearer part")
			tokenString := strings.TrimPrefix(authHeader, "Bearer ")
			if tokenString == authHeader {
				http.Error(w, "Invalid authorization format", http.StatusUnauthorized)
				return
			}

			// Parse and validate JWT token
			log.Println("Parsing the jwt token ")
			_, err := auth.ParseJwt(tokenString, os.Getenv("JWT_SECRET"))
			if err == nil {
				// Token is valid, proceed to next handler
				log.Println("Token validation successful")
				next.ServeHTTP(w, r)
				return
			}

			// If we reach here, token is invalid or expired
			log.Println("Token invalid or expired, attempting refresh if expired")
			unvalidatedClaims := jwt.MapClaims{}
			jwt.ParseWithClaims(tokenString, unvalidatedClaims, func(token *jwt.Token) (interface{}, error) {
				return []byte(h.Config.JWT_SECRET), nil
			})

			// get users email from claims
			email, ok := unvalidatedClaims["email"].(string)
			if !ok {
				log.Println("Email not found in expired token claims")
				http.Error(w, "email not found in token", http.StatusUnauthorized)
				return
			}
			log.Println("Attempting to refresh token for user:", email)
			var student models.Student
			// Fetch refresh token from DB
			if err := h.DB.Where("svv_email = ? ", email).First(&student).Error; err != nil {
				log.Println("User not found in DB for token refresh:", err)
				http.Error(w, "user not found", http.StatusUnauthorized)
				return
			}
			refreshToken := student.JWTRefresh

			// Token is expired so we will handle the refresh token functionality
			refreshErr, success, response := h.RefreshToken(refreshToken)
			if refreshErr != nil || !success {
				log.Println("Token refresh failed:", refreshErr)
				http.Error(w, "Token refresh failed: "+refreshErr.Error(), http.StatusUnauthorized)
				return
			}
			newAccessToken, ok := response["access_token"].(string)
			if !ok {
				log.Println("New access token missing in refresh response")
				http.Error(w, "Token refresh failed", http.StatusUnauthorized)
				return
			}
			newAuthHeader := fmt.Sprintf("Bearer %s", newAccessToken)
			w.Header().Set("Authorization", newAuthHeader)
			// CRITICAL FIX: Update the request header so the downstream handler sees the new token
			r.Header.Set("Authorization", newAuthHeader)
			log.Println("Token refreshed successfully, proceeding with request")
			// IMPORTANT: Call the next handler after refreshing token
			next.ServeHTTP(w, r)
		})
	}
}
