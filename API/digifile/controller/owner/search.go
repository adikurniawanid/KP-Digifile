package owner

import (
	"context"
	"digifile/constant"
	"digifile/entity"
	"digifile/entity/owner"
	"digifile/responsegraph"
	"digifile/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

func Search(c echo.Context) error {
	var model entity.Search
	var input owner.Get_log_activity
	c.Bind(&model)
	var result []interface{}
	var username []interface{}
	syn := "select * from search_owner('" + model.Name + "'," + strconv.Itoa(model.Activity_id) + ",'" + model.Start_date + "','" + model.End_date + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Username, &input.Name, &input.Tanggal, &input.Last_activity, &input.Kuota, &input.Status); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input)
		username = append(username, input.Username)
	}
	res := responsegraph.ResponseGenericGet2{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   username,
	}
	return c.JSON(http.StatusOK, res)
}
