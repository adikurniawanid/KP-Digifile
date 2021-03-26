package c_owner

import (
	"context"
	"digifile/config"
	"digifile/constant"
	"digifile/controller"
	"digifile/entity/owner"
	"digifile/entity/user"
	"digifile/responsegraph"
	"digifile/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

var db = config.Getdb()

func Add_user(c echo.Context) error {
	uid, _ := utils.GetUID()
	var model user.Users
	c.Bind(&model)
	res := responsegraph.Data{
		Status:  constant.StatusError,
		Message: "",
		Data:    2,
	}
	if controller.Is_username_exist(model.Uid) {
		res.Message = "Username telah terdaftar"
		return c.JSON(http.StatusOK, res)
	}
	_, errEmail := utils.IsEmailFormat(model.Email)
	if errEmail != nil {
		res.Message = "Email tidak valid"
		return c.JSON(http.StatusOK, res)
	}
	_, errPhone := utils.IsEmailFormat(model.Phone)
	if errPhone != nil {
		res.Message = "Nomor Handphone tidak valid"
		return c.JSON(http.StatusOK, res)
	}
	if model.Space < 0 {
		res.Data = 0
		res.Message = "Space tidak valid"
		return c.JSON(http.StatusOK, res)
	}
	syn := "select add_user('" + uid + "','" + model.Username + "','" + model.Name + "','" + controller.Hash_256(model.Password) + "','" + model.Phone + "','" + model.Email + "','" + strconv.Itoa(model.Space) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		res.Message = "Data gagal ditambahkan"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	res.Status = constant.StatusSuccess
	res.Message = "Berhasil Add user"
	res.Data = int(hasil.RowsAffected())
	return c.JSON(http.StatusOK, res)
}

func Edit_user(c echo.Context) error {
	var model owner.Edit_user
	c.Bind(&model)
	res := responsegraph.Data{
		Status:  constant.StatusError,
		Message: "Username tidak ditemukan",
		Data:    2,
	}
	if controller.Is_username_exist(model.Uid) == false {
		return c.JSON(http.StatusOK, res)
	}
	syn := "select edit_user('" + model.Username + "','" + model.Name + "','" + strconv.Itoa(model.Space) + "','" + model.Email + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		res.Message = "Data gagal ditambahkan"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	res.Status = constant.StatusSuccess
	res.Message = "Berhasil Edit user"
	res.Data = int(hasil.RowsAffected())
	return c.JSON(http.StatusOK, res)
}
