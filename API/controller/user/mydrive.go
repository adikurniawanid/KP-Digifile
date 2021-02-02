package user

import (
	"context"
	"net/http"
	"strings"
	"template-api-gecho/constant"
	"template-api-gecho/entity/user"
	"template-api-gecho/responsegraph"
	"template-api-gecho/utils"

	"github.com/labstack/echo/v4"
)

func Get_file_list(c echo.Context) error {
	var model user.Get_items
	var input user.Get_items
	c.Bind(&model)
	curentpath := model.Curent_path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	var result []string
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from get_file_list('" + model.Username + "','" + curentpath + "');"
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
		item_id = append(item_id, item)
		tampung = strings.Split(input.Item_name, ".")
		extension = append(extension, tampung[(len(tampung)-1)])
		result = append(result, input.Item_name)
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil Select Data",
		Data:     result,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_folder_list(c echo.Context) error {
	var model user.Get_items
	var input user.Get_items
	c.Bind(&model)
	curentpath := model.Curent_path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	var result []interface{}
	var item_id []int
	var item int
	syn := "select * from get_folder_list('" + model.Username + "','" + curentpath + "');"
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
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Id:      item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_all_item_list(c echo.Context) error {
	var model user.Get_items
	var input user.Get_items
	c.Bind(&model)
	curentpath := model.Curent_path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	var result []string
	var count_file int
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from Get_all_item_list('" + model.Username + "','" + curentpath + "');"
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
	count := "select * from get_file_count('" + model.Username + "','" + curentpath + "');"
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
