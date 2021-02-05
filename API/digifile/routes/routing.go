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

	// e.GET("/posts/", Routing.example.GetPostsController)
	// e.POST("/posts/", Routing.example.GetPostsController)
	e.DELETE("delete_file/", user.Delete_file)                  //fix user
	e.DELETE("delete_folder/", user.Delete_folder)              //fix user
	e.PUT("recovery_trash_file/", user.Recovery_trash_file)     //fix user
	e.PUT("recovery_trash_folder/", user.Recovery_trash_folder) //fix user
	e.PUT("rename_file/", user.Rename_file)                     //fix user
	e.PUT("rename_folder/", user.Rename_folder)                 //fix user
	//e.POST("add_file/", controller.Add_file)                          //fix
	// e.POST("add_folder/", controller.Add_folder)       //fix
	e.POST("add_user/", owner.Add_user)                        //fix owner
	e.PUT("edit_user/", owner.Edit_user)                       //fix owner
	e.DELETE("delete_trash_file/", user.Delete_trash_file)     //fix user
	e.DELETE("delete_trash_folder/", user.Delete_trash_folder) //fix user
	e.POST("login/", controller.Login)                         //fix
	//e.GET("hash_password/", controller.Hash_password)             //fix
	e.GET("get_file_list/", user.Get_file_list)                     //fix user
	e.GET("get_folder_list/", user.Get_folder_list)                 //fix user
	e.GET("get_all_item_list/", user.Get_all_item_list)             //fix user
	e.GET("get_trash_file_list/", user.Get_trash_file_list)         //fix user
	e.GET("get_trash_folder_list/", user.Get_trash_folder_list)     //fix user
	e.GET("get_log_activity/", owner.Get_log_activity)              //owner
	e.GET("get_user_log_activity/", owner.Get_user_log_activity)    //owner
	e.GET("get_information_storage/", user.Get_information_storage) //user
	e.GET("get_user_information/", owner.Get_user_information)      //owner
	// e.GET("is_admin/", controller.Is_admin)                   //fix
	// e.GET("is_user/", controller.Is_user)                     //fix
	// e.GET("is_username_exist/", controller.Is_username_exist) //fix
	e.GET("verify_login/", controller.Verify_login1) //fix
	e.GET("search/", owner.Search)                   //owner
	e.GET("search_user/", user.Search_user)          //user
	e.POST("upload_file/", user.Upload_file)         //user
	e.POST("upload_folder/", user.Upload_folder)     //user
	e.GET("create_folder/", user.Create_folder)      //user
	e.GET("logs/", owner.Logs)                       //owner
	e.GET("get_name/", owner.Get_name)               //owner user
	e.GET("download_file/", user.DownloadFile)
	e.GET("get_all_trash_list/", user.Get_all_trash_list)
	e.PUT("set_offline/", controller.Set_offline)
	// e.GET("is_enough_space", controller.Is_enough_space)
	return e
}
