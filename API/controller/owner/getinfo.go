package owner

import (
	"context"
	"net/http"
	"strconv"
	"template-api-gecho/constant"
	"template-api-gecho/entity/owner"
	"template-api-gecho/entity/user"
	"template-api-gecho/responsegraph"
	"template-api-gecho/utils"

	"github.com/labstack/echo/v4"
)

func Get_user_information(c echo.Context) error {
	var model user.Users
	c.Bind(&model)
	syn := "select * from get_user_information('" + model.Username + "');"
	hasil, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
	}
	for hasil.Next() {
		if err := hasil.Scan(&model.Username, &model.Name, &model.Space, &model.Email); err != nil {
			utils.LogError(err)
		}
	}
	res := responsegraph.Userinformation{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Username: model.Username,
		Name:     model.Name,
		Space:    model.Space,
		Email:    model.Email,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_name(c echo.Context) error {
	var result string
	var input user.Users
	c.Bind(&input)
	syn := "select * from get_name('" + input.Username + "');"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&result); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
	}
	res := responsegraph.Name{
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

func Logs(c echo.Context) error {
	var model user.Users
	var result int
	c.Bind(&model)
	syn := "select count(log_id) as jumlah from logs where username='" + model.Username + "';"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&result); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	var result1 []interface{}
	var model1 owner.Get_user_log_activity
	syn1 := "select * from get_user_log_activity('" + model.Username + "'," + strconv.Itoa(model.Page) + ");"
	test1, err := db.Query(context.Background(), syn1)
	for test1.Next() {
		if err := test1.Scan(&model1.Tanggal, &model1.Last_activity); err != nil {
			utils.LogError(err)
		}
		result1 = append(result1, model1)
	}
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   result1,
	}
	return c.JSON(http.StatusOK, res)
}
