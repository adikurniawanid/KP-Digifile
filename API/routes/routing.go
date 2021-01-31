package routes

import (
	"net/http"
	"template-api-gecho/controller"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
)

type Routing struct {
	example controller.ExampleController
}

func (Routing Routing) GetRoutes() *echo.Echo {
	e := echo.New()
	e.Use(middleware.Logger())
	e.Use(middleware.Recover())
	e.Use(middleware.CORSWithConfig(middleware.CORSConfig{
		AllowOrigins: []string{"*"},
		AllowMethods: []string{http.MethodGet, http.MethodPut, http.MethodPost, http.MethodDelete},
	}))

	// e.GET("/posts/", Routing.example.GetPostsController)
	// e.POST("/posts/", Routing.example.GetPostsController)
	e.DELETE("delete_file/", controller.Delete_file)                  //fix user
	e.DELETE("delete_folder/", controller.Delete_folder)              //fix user
	e.PUT("recovery_trash_file/", controller.Recovery_trash_file)     //fix user
	e.PUT("recovery_trash_folder/", controller.Recovery_trash_folder) //fix user
	e.PUT("rename_file/", controller.Rename_file)                     //fix user
	e.PUT("rename_folder/", controller.Rename_folder)                 //fix user
	//e.POST("add_file/", controller.Add_file)                          //fix
	// e.POST("add_folder/", controller.Add_folder)       //fix
	e.POST("add_user/", controller.Add_user)                         //fix owner
	e.PUT("edit_user/", controller.Edit_user)                        //fix owner
	e.DELETE("delete_trash_file/", controller.Delete_trash_file)     //fix user
	e.DELETE("delete_trash_folder/", controller.Delete_trash_folder) //fix user
	e.POST("login/", controller.Login)                               //fix
	//e.GET("hash_password/", controller.Hash_password)             //fix
	e.GET("get_file_list/", controller.Get_file_list)                     //fix user
	e.GET("get_folder_list/", controller.Get_folder_list)                 //fix user
	e.GET("get_all_item_list/", controller.Get_all_item_list)             //fix user
	e.GET("get_trash_file_list/", controller.Get_trash_file_list)         //fix user
	e.GET("get_trash_folder_list/", controller.Get_trash_folder_list)     //fix user
	e.GET("get_log_activity/", controller.Get_log_activity)               //owner
	e.GET("get_user_log_activity/", controller.Get_user_log_activity)     //owner
	e.GET("get_information_storage/", controller.Get_information_storage) //user
	e.GET("get_user_information/", controller.Get_user_information)       //owner
	// e.GET("is_admin/", controller.Is_admin)                   //fix
	// e.GET("is_user/", controller.Is_user)                     //fix
	// e.GET("is_username_exist/", controller.Is_username_exist) //fix
	e.GET("verify_login/", controller.Verify_login1)   //fix
	e.GET("search/", controller.Search)                //owner
	e.GET("search_user/", controller.Search_user)      //user
	e.POST("upload_file/", controller.Upload_file)     //user
	e.POST("upload_folder/", controller.Upload_folder) //user
	e.GET("create_folder/", controller.Create_folder)  //user
	e.GET("logs/", controller.Logs)                    //owner
	e.GET("get_name/", controller.Get_name)            //owner user
	e.GET("download_file/", controller.DownloadFile)
	e.GET("get_all_trash_list/", controller.Get_all_trash_list)
	// e.GET("is_enough_space", controller.Is_enough_space)
	return e
}
