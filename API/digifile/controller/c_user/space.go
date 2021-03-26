package c_user

import (
	"context"
	"digifile/constant"
	"digifile/entity/owner"
	"digifile/entity/user"
	"digifile/responsegraph"
	"digifile/utils"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/shopspring/decimal"
)

func Is_enough_space(username string, size_file string) bool {
	var result bool
	size, err1 := decimal.NewFromString(size_file)
	if err1 != nil {
		utils.LogError(err1)
	}
	syn := "select * from is_enough_space('" + username + "','" + size.String() + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
	}
	for test.Next() {
		if err := test.Scan(&result); err != nil {
			utils.LogError(err)
		}
	}
	return result
}

func Get_information_storage(c echo.Context) error {
	var result []interface{}
	var input user.Users
	c.Bind(&input)
	var model owner.Detail_activity
	syn := "select * from get_information_storage('" + input.Uid + "');"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&model.Description); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, model.Description)
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
