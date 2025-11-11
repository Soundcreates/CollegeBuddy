package auth

import (
	"log"
	"somaiya-ext/internal/models"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

func SignJWt(userInfo models.Student, secretKey string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": userInfo.SVVEmail,
		"netId": userInfo.SVVNetId,
		"exp":   time.Now().Add(24 * time.Hour).Unix(), // Expires in 24 hours
		"iat":   time.Now().Unix(),                     // Issued at
	})

	tokenString, err := token.SignedString(secretKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func ParseJwt(tokenString string, secretKey string) (any, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		return []byte(secretKey), nil
	}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))

	if err != nil {
		log.Fatal(err)
	}
	return token, nil
	//from here u can retrieve the 'claims' which will contain the fields that u signed ur user with for jwt
}
