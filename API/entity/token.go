package entity

import "github.com/dgrijalva/jwt-go"

type CustomClaims struct {
	UserID string `json:"id_user"`
	Nama   string `json:"nama"`
	Email  string `json:"email"`
	RoleID int    `json:"id_role"`
	jwt.StandardClaims
}
