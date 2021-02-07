package routes

import (
	"digifile/controller"
	"digifile/controller/owner"
	"digifile/controller/user"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

func GetRoutes() *echo.Echo {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowMethods: []string{http.MethodGet, http.MethodPut, http.MethodPost, http.MethodDelete},
	}))
	e.DELETE("delete_file/", user.Delete_file)
	e.DELETE("delete_folder/", user.Delete_folder)
	e.PUT("recovery_trash_file/", user.Recovery_trash_file)
	e.PUT("recovery_trash_folder/", user.Recovery_trash_folder)
	e.PUT("rename_file/", user.Rename_file)
	e.PUT("rename_folder/", user.Rename_folder)
	e.POST("add_user/", owner.Add_user)
	e.PUT("edit_user/", owner.Edit_user)
	e.DELETE("delete_trash_file/", user.Delete_trash_file)
	e.DELETE("delete_trash_folder/", user.Delete_trash_folder)
	e.POST("login/", controller.Login)
	e.GET("get_file_list/", user.Get_file_list)
	e.GET("get_folder_list/", user.Get_folder_list)
	e.GET("get_all_item_list/", user.Get_all_item_list)
	e.GET("get_trash_file_list/", user.Get_trash_file_list)
	e.GET("get_trash_folder_list/", user.Get_trash_folder_list)
	e.GET("get_log_activity/", owner.Get_log_activity)
	e.GET("get_user_log_activity/", owner.Get_user_log_activity)
	e.GET("get_information_storage/", user.Get_information_storage)
	e.GET("get_user_information/", owner.Get_user_information)
	e.GET("verify_login/", controller.Verify_login1)
	e.GET("search/", owner.Search)
	e.GET("search_user/", user.Search_user)
	e.POST("upload_file/", user.Upload_file)
	e.POST("upload_folder/", user.Upload_folder)
	e.GET("create_folder/", user.Create_folder)
	e.GET("logs/", owner.Logs)
	e.GET("get_name/", owner.Get_name)
	e.GET("download_file/", user.DownloadFile)
	e.GET("download_folder/", user.DownloadFolder)
	e.GET("get_all_trash_list/", user.Get_all_trash_list)
	e.PUT("set_offline/", controller.Set_offline)
	return e
}
