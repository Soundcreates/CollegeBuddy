package auth

import (
	"somaiya-ext/internal/models"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

/*
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
} */
//the above function only signs jwt tokens but doensnt handle refresh tokens so the program fails when the token gets expired
//this function below generates access token
func GenerateAccessToken(user models.Student, secretKey string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email": user.SVVEmail,
		"exp":   time.Now().Add(25 * time.Minute).Unix(), //uh we will keeep this short lived for better security
		"iat":   time.Now().Unix(),
	})

	return token.SignedString([]byte(secretKey)) // we aint returning a nil as placeholder for error as the signedstring func itself returns two stuffs the string, and error
}

//the function below generates the refresh token

func GenerateRefreshToken(user models.Student, secretKey string) (string, error) {
		token := jwt.NewWithClaims(jwt.SigningMethodHS256, jwt.MapClaims{
		"email" : user.SVVEmail,
		"exp" : time.Now().Add(30 * 24 * time.Hour).Unix(), //this is for 30 days
		"iat": time.Now().Unix(),		
	})

	return token.SignedString([]byte(secretKey)) //the same as the generateAccessToken function
}

// Simple JWT parser for existing code - keeps backward compatibility
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

// Advanced JWT parser with refresh token support
func ParseJwtWithRefresh(accessTokenString string, refreshTokenString string, secretKey string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(accessTokenString, func(token *jwt.Token) (any, error) {
		return []byte(secretKey), nil
	}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))

	if err != nil {
		// If there's an error, check if it's a token expired error
		if err == jwt.ErrTokenExpired {
			// If access token is expired, try to parse the refresh token
			refreshToken, refreshErr := jwt.Parse(refreshTokenString, func(token *jwt.Token) (any, error) {
				return []byte(secretKey), nil
			}, jwt.WithValidMethods([]string{jwt.SigningMethodHS256.Alg()}))
			
			if refreshErr != nil {
				return nil, refreshErr // Refresh token is also invalid
			}
			
			if claims, ok := refreshToken.Claims.(jwt.MapClaims); ok && refreshToken.Valid {
				return claims, nil // Return claims from valid refresh token
			}
			return nil, jwt.ErrInvalidKey
		}
		return nil, err
	}

	// If access token is valid, return its claims
	if claims, ok := token.Claims.(jwt.MapClaims); ok && token.Valid {
		return claims, nil
	}

	return nil, jwt.ErrInvalidKey
}
