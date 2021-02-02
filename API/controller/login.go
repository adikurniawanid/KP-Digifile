package controller

import (
	"net/http"
	"template-api-gecho/constant"
	"template-api-gecho/entity/user"
	"template-api-gecho/responsegraph"

	"github.com/labstack/echo/v4"
)

func Login(c echo.Context) error {
	var page int
	page = 0
	var model user.Users
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
