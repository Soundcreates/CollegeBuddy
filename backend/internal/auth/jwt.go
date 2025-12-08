package auth

import (
	"somaiya-ext/internal/models"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func SignJWt( userInfo models.Student, secretKey string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": userInfo.SVVEmail,
		"netId": userInfo.SVVNetId,
		"exp":   time.Now().Add(24 * time.Hour).Unix(), // Expires in 24 hours
		"iat":   time.Now().Unix(),                     // Issued at
	})

	tokenString, err := token.SignedString([]byte(secretKey))
	if err != nil {
		return "", err
	}
	// NOTE: Context is not needed here since we're just signing a token
	// The JWT itself carries the user information
	return tokenString, nil
}

func ParseJwt(tokenString string, secretKey string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		return []byte(secretKey), nil
	}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))

	if err != nil {
		return nil, err
	}

	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, jwt.ErrInvalidKey
}
