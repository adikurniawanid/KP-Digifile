package controller

import (
	"context"
	"net/http"
	"template-api-gecho/entity/user"
	"template-api-gecho/utils"

	"github.com/labstack/echo/v4"
)

func Verify_login(c echo.Context) bool {
	var model user.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select verify_login('" + model.Username + "','" + Hash_256(model.Password) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return result
	}
	if err != nil {
		utils.LogError(err)
		return result
	}
	return result
}

func Verify_login1(c echo.Context) error {
	var model user.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select verify_login('" + model.Username + "','" + Hash_256(model.Password) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return c.JSON(http.StatusOK, result)
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusOK, err)
	}
	return c.JSON(http.StatusOK, result)
}
