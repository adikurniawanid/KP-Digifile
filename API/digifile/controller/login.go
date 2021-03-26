package controller

import (
	"digifile/constant"
	"digifile/entity/user"
	"digifile/responsegraph"
	"net/http"

	"github.com/labstack/echo/v4"
)

func Login(c echo.Context) error {
	var page int
	page = 0
	var model user.Users
	c.Bind(&model)
	verify_login, uid := Verify_login(c)
	is_username_exist := Is_username_exist(uid)
	is_admin := Is_admin(uid)
	is_user := Is_user(uid)
	if is_username_exist == true {
		if is_admin == true {
			if verify_login == true {
				Set_online(uid)
				page = 1
			}
		} else if is_user == true {
			if verify_login == true {
				Set_online(uid)
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
