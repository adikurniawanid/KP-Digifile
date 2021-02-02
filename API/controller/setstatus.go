package controller

import (
	"context"
	"net/http"
	"template-api-gecho/config"
	"template-api-gecho/constant"
	"template-api-gecho/entity/user"
	"template-api-gecho/responsegraph"
	"template-api-gecho/utils"

	"github.com/labstack/echo/v4"
)

var db = config.Getdb()

func Set_online(c echo.Context) {
	var model user.Users
	c.Bind(&model)
	syn := "select set_online('" + model.Username + "');"
	db.Query(context.Background(), syn)
}

func Set_offline(c echo.Context) error {
	var model user.Users
	c.Bind(&model)
	syn := "select * from set_offline('" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Set offline",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Gagal set offline"
		res.Data = 0
		utils.LogError(err)
	}
	return c.JSON(http.StatusOK, res)
}
