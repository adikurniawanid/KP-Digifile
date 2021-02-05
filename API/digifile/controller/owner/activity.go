package owner

import (
	"context"
	"digifile/constant"
	"digifile/entity/owner"
	"digifile/entity/user"
	"digifile/responsegraph"
	"digifile/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

func Get_log_activity(c echo.Context) error {
	var result []interface{}
	var username []interface{}
	var model owner.Get_log_activity
	syn := "select * from get_log_activity;"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&model.Username, &model.Name, &model.Tanggal, &model.Last_activity, &model.Kuota, &model.Status); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, model)
		username = append(username, model.Username)
	}
	res := responsegraph.ResponseGenericGet2{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   username,
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	return c.JSON(http.StatusOK, res)
}

func Get_user_log_activity(c echo.Context) error {
	var result []interface{}
	var input user.Users
	c.Bind(&input)
	var model owner.Get_user_log_activity
	syn := "select * from get_user_log_activity('" + input.Username + "','" + strconv.Itoa(input.Page) + "');"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&model.Tanggal, &model.Last_activity); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, model)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	return c.JSON(http.StatusOK, res)
}
