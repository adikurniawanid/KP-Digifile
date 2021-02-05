package controller

import (
	"context"
	"digifile/entity/user"
	"digifile/utils"

	"github.com/labstack/echo/v4"
)

func Is_username_exist(c echo.Context) bool {
	var model user.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select is_username_exist('" + model.Username + "');"
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

func Is_user(c echo.Context) bool {
	var model user.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select is_user('" + model.Username + "');"
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

func Is_admin(c echo.Context) bool {
	var model user.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select is_admin('" + model.Username + "');"
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
