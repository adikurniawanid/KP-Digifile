package c_owner

import (
	"context"
	"digifile/constant"
	"digifile/controller"
	"digifile/entity/user"
	"digifile/responsegraph"
	"digifile/utils"
	"net/http"
	"strconv"

	"github.com/labstack/echo/v4"
)

func Add_admin(c echo.Context) error {
	var model user.Admin
	c.Bind(&model)
	uid, _ := utils.GetUID()
	res := responsegraph.Data{
		Status:  constant.StatusError,
		Message: "",
		Data:    2,
	}
	if controller.Is_username_exist(uid) {
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
	syn := "select add_admin('" + uid + "','" + model.Username + "','" + model.Name + "','" + controller.Hash_256(model.Password) + "','" + model.Phone + "','" + model.Email + "','" + strconv.Itoa(model.Space) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		res.Message = "Data gagal ditambahkan"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	res.Status = constant.StatusSuccess
	res.Message = "Berhasil Add admin"
	res.Data = int(hasil.RowsAffected())
	return c.JSON(http.StatusOK, res)
}
