package utils

import (
	"digifile/constant"
	"digifile/entity"
	"net/http"
	"os"

	"github.com/dgrijalva/jwt-go"
	"github.com/labstack/echo/v4"
)

func GetDataToken(c echo.Context) jwt.Claims {
	tokenID := getAuthorizationToken(c)
	tokenKey := os.Getenv(constant.JWTKey)
	token, _ := getParseWithClaimsJWT(tokenKey, tokenID)
	return token.Claims
}

func Middleware(next echo.HandlerFunc) echo.HandlerFunc {
	return func(c echo.Context) error {
		if !isTokenValid(c) {
			return c.JSON(
				http.StatusUnauthorized,
				GetResNoData(constant.StatusError, constant.Unauthorized),
			)
		}
		return next(c)
	}
}

func isTokenValid(c echo.Context) bool {
	tokenID := getAuthorizationToken(c)
	tokenKey := os.Getenv(constant.JWTKey)
	token, err := getParseWithClaimsJWT(tokenKey, tokenID)

	if err != nil {
		return false
	}

	_, ok := token.Claims.(*entity.CustomClaims)
	if !ok {
		return false
	}

	return true
}

func getAuthorizationToken(c echo.Context) string {
	tokenID := c.Request().Header.Get(constant.Authorization)
	tokenID = TrimString(tokenID, constant.Bearer)
	tokenID = TrimString(tokenID, " ")
	return tokenID
}

func getParseWithClaimsJWT(tokenKey string, tokenID string) (*jwt.Token, error) {
	return jwt.ParseWithClaims(
		tokenID,
		&entity.CustomClaims{},
		func(token *jwt.Token) (interface{}, error) {
			return []byte(tokenKey), nil
		},
	)
}
