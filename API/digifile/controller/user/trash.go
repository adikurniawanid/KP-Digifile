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

func Get_trash_file_list(c echo.Context) error {
	var model user.Get_items
	var input user.Get_items
	c.Bind(&model)
	var result []interface{}
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from get_trash_file_list('" + model.Username + "');"
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
		tampung = strings.Split(input.Item_name, ".")
		extension = append(extension, tampung[(len(tampung)-1)])
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	res := responsegraph.ResponseGenericGet2{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   extension,
		Id:      item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_trash_folder_list(c echo.Context) error {
	var model user.Get_items
	var input user.Get_items
	c.Bind(&model)
	var result []interface{}
	var item_id []int
	var item int
	syn := "select * from get_trash_folder_list('" + model.Username + "');"
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
func Get_all_trash_list(c echo.Context) error {
	var model user.Get_items
	c.Bind(&model)
	var items []string
	var count_file int
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from get_all_trash_list('" + model.Username + "');"
	hasil, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
	}
	for hasil.Next() {
		if err := hasil.Scan(&model.Item_name, &item); err != nil {
			utils.LogError(err)
		}
		items = append(items, model.Item_name)
		item_id = append(item_id, item)
	}
	count := "select * from get_trash_file_count('" + model.Username + "');"
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
		tampung = strings.Split(items[i], ".")
		extension = append(extension, tampung[(len(tampung)-1)])
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Data:     items,
		File:     count_file,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Delete_trash_file(c echo.Context) error {
	var model user.Delete_trash
	c.Bind(&model)
	var path string
	var oldname string
	utils.LogInfo("id : " + model.File_id)
	utils.LogInfo("username : " + model.Owner)
	syn1 := "select * from get_item_information('" + model.File_id + "');"
	hasil1, err := db.Query(context.Background(), syn1)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	syn := "select delete_trash_file('" + model.File_id + "','" + model.Owner + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil delete trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal dihapus"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	path_full := "upload/" + model.Owner + path
	// ================================================================function untuk menghapus pada penyimpanan fisik
	remove(path_full, oldname)
	return c.JSON(http.StatusOK, res)
}

func Delete_trash_folder(c echo.Context) error {
	var model user.Delete_trash
	c.Bind(&model)
	var path string
	var oldname string
	utils.LogInfo("ini id : " + model.File_id)
	utils.LogInfo("ini user : " + model.Owner)
	syn1 := "select * from get_item_information('" + model.File_id + "');"
	hasil1, err1 := db.Query(context.Background(), syn1)
	if err1 != nil {
		utils.LogError(err1)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	syn := "select * from delete_trash_folder('" + model.File_id + "','" + model.Owner + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil delete trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal dihapus"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	path_full := "upload/" + model.Owner + path
	// ================================================================function untuk menghapus pada penyimpanan fisik
	remove(path_full, oldname)
	return c.JSON(http.StatusOK, res)
}

func Recovery_trash_file(c echo.Context) error {
	var model user.Delete_file
	c.Bind(&model)
	syn := "select recovery_trash_file('" + model.File_id + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil recovery trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal direcovery"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Recovery_trash_folder(c echo.Context) error {
	var model user.Delete_folder
	c.Bind(&model)
	syn := "select recovery_trash_folder('" + model.Folder_id + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil recovery trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal direcovery"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	return c.JSON(http.StatusOK, res)
}
