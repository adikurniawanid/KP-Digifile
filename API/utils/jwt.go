package utils

import (
	"github.com/dgrijalva/jwt-go"
)

// Generate JWT Token
func GenerateToken(claim jwt.Claims, tokenKey string) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claim)

	idToken, err := token.SignedString([]byte(tokenKey))

	return idToken, err
}
