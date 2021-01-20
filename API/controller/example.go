package controller

import (
	"context"
	"fmt"
	"net/http"
	"strconv"
	"template-api-gecho/config"
	"template-api-gecho/constant"
	"template-api-gecho/entity"
	"template-api-gecho/model"
	"template-api-gecho/responsegraph"

	"github.com/labstack/echo/v4"
)

var db = config.Getdb()

type ExampleController struct {
	model model.ExampleModel
}

// Get Example Controller
// func (ExampleController ExampleController) GetPostsController(c echo.Context) error {
// 	secret := constant.Authorization

// 	posts := ExampleController.model.GetPosts(secret)
// 	res := responsegraph.ResponseGenericGet{
// 		Status:  constant.StatusSuccess,
// 		Message: "Berhasil Insert Data",
// 		Data:    posts,
// 	}

// 	return c.JSON(http.StatusOK, res)
// }

// NOTE : penambahan fungsi db baru dari mas adi :
//search

// func BytesToString(b [32]byte) string {
// 	bh := (*reflect.SliceHeader)(unsafe.Pointer(&b))
// 	sh := reflect.StringHeader{bh.Data, bh.Len}
// 	return *(*string)(unsafe.Pointer(&sh))
// }

// func convert(b [32]byte) string {
// 	var a string
// 	for i := 0; i < len(b); i++ {
// 		a += strconv.Itoa(int(b[i])) + " "
// 	}
// 	return a
// }

// func Hash_password(c echo.Context) error {
// 	var model entity.Users
// 	c.Bind(&model)
// 	awal := model.Password
// 	hashing := sha256.Sum256([]byte(awal))
// 	syn := "insert into jajal values('{" + convert(hashing) + "}');"
// 	db.QueryRow(context.Background(), syn)
// 	res := responsegraph.ResponseGenericGet{
// 		Status:  constant.StatusSuccess,
// 		Message: convert(hashing),
// 		Data:    model,
// 	}
// 	return c.JSON(http.StatusOK, res)
// }

func Get_activity_detail(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	var result []interface{}
	var tampung []interface{}
	syn := "select get_activity_detail('" + model.Username + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&tampung); err != nil {
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, tampung...)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_trash_list(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	var result []interface{}
	var tampung []interface{}
	syn := "select get_trash_list('" + model.Username + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&tampung); err != nil {
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, tampung...)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	return c.JSON(http.StatusOK, res)
}

func Search(c echo.Context) error {
	var model entity.Search
	c.Bind(&model)
	var result []interface{}
	var tampung []interface{}
	syn := "select search('" + model.Name + "," + strconv.Itoa(model.Activity_id) + "," + model.Start_date.String() + "," + model.End_date.String() + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&tampung); err != nil {
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, tampung...)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_file_list(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	var result []interface{}
	var tampung []interface{}
	syn := "select get_file_list('" + model.Username + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&tampung); err != nil {
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, tampung...)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	return c.JSON(http.StatusOK, res)
}

func Login(c echo.Context) error {
	var page int
	page = 0
	var model entity.Users
	c.Bind(&model)
	is_username_exist := Is_username_exist(c)
	is_admin := Is_admin(c)
	is_user := Is_user(c)
	verify_login := Verify_login(c)
	if is_username_exist == true {
		if is_admin == true {
			if verify_login == true {
				Set_online(c)
				page = 1
			}
		} else if is_user == true {
			if verify_login == true {
				Set_online(c)
				page = 2
			}
		}
	}
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Status terdeteksi",
		Data:    page,
	}
	//result := "is_username_exist = " + strconv.FormatBool(is_username_exist) + " is_admin = " + strconv.FormatBool(is_admin) + " is_user = " + strconv.FormatBool(is_user) + " verify _login = " + strconv.FormatBool(verify_login) + " role = " + strconv.Itoa(page)
	return c.JSON(http.StatusOK, res)
}

func Set_online(c echo.Context) {
	var model entity.Users
	c.Bind(&model)
	syn := "select set_online('" + model.Username + "');"
	db.Query(context.Background(), syn)
}

func Verify_login(c echo.Context) bool {
	var model entity.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select verify_login('" + model.Username + "','" + model.Password + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return result
	}
	if err != nil {
		return result
	}
	return result
}

func Is_username_exist(c echo.Context) bool {
	var model entity.Users
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
		return result
	}
	return result
}

func Is_user(c echo.Context) bool {
	var model entity.Users
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
		return result
	}
	return result
}

func Is_admin(c echo.Context) bool {
	var model entity.Users
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
		return result
	}
	return result
}

func Add_file(c echo.Context) error {
	var model entity.Files
	c.Bind(&model)
	syn := "select add_file('" + model.File_name + "','" + model.Directory + "','" + fmt.Sprintf("%f", model.Size) + "','" + model.Owner + "')"
	db.QueryRow(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Add file",
		Data:    model,
	}
	return c.JSON(http.StatusOK, res)
}

func Add_user(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	syn := "select add_user('" + model.Username + "','" + model.Name + "','" + model.Password + "','" + model.Phone + "','" + model.Email + "','" + strconv.Itoa(model.Space) + "')"
	db.QueryRow(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Add user",
		Data:    model,
	}
	return c.JSON(http.StatusOK, res)
}

func Add_user_space(c echo.Context) error {
	var model entity.Add_user_space
	c.Bind(&model)
	syn := "select add_user_space('" + model.Username + "','" + strconv.Itoa(model.Space) + "')"
	db.QueryRow(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Add user space",
		Data:    model,
	}
	return c.JSON(http.StatusOK, res)
}

func Delete_file(c echo.Context) error {
	var model entity.Delete_file
	c.Bind(&model)
	syn := "select delete_file('" + strconv.Itoa(model.File_id) + "','" + model.Username + "')"
	db.QueryRow(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Delete file",
		Data:    model,
	}
	return c.JSON(http.StatusOK, res)
}

func Delete_trash(c echo.Context) error {
	var model entity.Delete_trash
	c.Bind(&model)
	syn := "select delete_trash('" + strconv.Itoa(model.File_id) + "','" + model.Owner + "')"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Delete trash",
		Data:    "Row affected : " + strconv.Itoa(int(hasil.RowsAffected())),
	}
	if err != nil {
		return c.JSON(http.StatusBadRequest, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Recovery_trash(c echo.Context) error {
	var model entity.Delete_file
	c.Bind(&model)
	syn := "select recovery_trash('" + strconv.Itoa(model.File_id) + "','" + model.Username + "')"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Recovery trash",
		Data:    "Row affected : " + strconv.Itoa(int(hasil.RowsAffected())),
	}
	if err != nil {
		return c.JSON(http.StatusBadRequest, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Rename_file(c echo.Context) error {
	var model entity.Rename_file
	c.Bind(&model)
	syn := "select rename_file('" + strconv.Itoa(model.Id) + "','" + model.New_name + "')"
	db.QueryRow(context.Background(), syn)
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Rename file",
		Data:    model,
	}
	return c.JSON(http.StatusOK, res)
}
