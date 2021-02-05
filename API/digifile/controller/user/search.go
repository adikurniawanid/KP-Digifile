package user

import (
	"context"
	"digifile/constant"
	"digifile/entity/user"
	"digifile/responsegraph"
	"digifile/utils"
	"net/http"
	"strings"

	"github.com/labstack/echo/v4"
)

func Search_user(c echo.Context) error {
	var model user.Get_items
	var input user.Get_items
	c.Bind(&model)
	var result []string
	var count_file int
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from search_user('" + model.Username + "','" + model.Item_name + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	count := "select * from get_search_file_count('" + model.Username + "','" + model.Item_name + "');"
	hasil1, err := db.Query(context.Background(), count)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&count_file); err != nil {
			utils.LogError(err)
		}
	}
	for i := 0; i < count_file; i++ {
		tampung = strings.Split(result[i], ".")
		extension = append(extension, tampung[(len(tampung)-1)])
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Data:     result,
		File:     count_file,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}
