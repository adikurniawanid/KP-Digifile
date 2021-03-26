package routes

import (
	"digifile/controller"
	owner "digifile/controller/c_owner"
	user "digifile/controller/c_user"
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

	//route untuk user
	r_user := e.Group("/user")
	r_user.DELETE("/delete_file", user.Delete_file)                      //done
	r_user.DELETE("/delete_folder", user.Delete_folder)                  //done
	r_user.PUT("/recovery_trash_file", user.Recovery_trash_file)         //done
	r_user.PUT("/recovery_trash_folder", user.Recovery_trash_folder)     //done
	r_user.PUT("/rename_file", user.Rename_file)                         //done, tapi nama belum berupa id
	r_user.PUT("/rename_folder", user.Rename_folder)                     //done, tapi nama belum berupa id
	r_user.DELETE("/delete_trash_file", user.Delete_trash_file)          //done, tapi cek bagian fungsi remove
	r_user.DELETE("/delete_trash_folder", user.Delete_trash_folder)      //done, tapi cek bagian fungsi remove
	r_user.GET("/get_file_list", user.Get_file_list)                     //done
	r_user.GET("/get_folder_list", user.Get_folder_list)                 //done
	r_user.GET("/get_all_item_list", user.Get_all_item_list)             //done
	r_user.GET("/get_trash_file_list", user.Get_trash_file_list)         //done
	r_user.GET("/get_trash_folder_list", user.Get_trash_folder_list)     //done
	r_user.GET("/search_user", user.Search_user)                         //done, tapi cek bagian username/id
	r_user.GET("/upload_file", user.Upload_file)                         //done, tapi cek bagian penamaan
	r_user.POST("/upload_folder", user.Upload_folder)                    //done, tapi cek bagian penamaan
	r_user.GET("/create_folder", user.Create_folder)                     //done, tapi cek bagian currentpath/id
	r_user.GET("/download_file", user.DownloadFile)                      //done
	r_user.GET("/download_folder", user.DownloadFolder)                  //done
	r_user.GET("/get_all_trash_list", user.Get_all_trash_list)           //done
	r_user.GET("/get_information_storage", user.Get_information_storage) //done

	//route untuk owner
	r_owner := e.Group("/owner")
	r_owner.POST("/add_user", owner.Add_user)                          //done
	r_owner.PUT("/edit_user", owner.Edit_user)                         //done, tapi cek bagian username/id
	r_owner.GET("/get_log_activity", owner.Get_log_activity)           //done, tapi cek bagian username/id
	r_owner.GET("/get_user_log_activity", owner.Get_user_log_activity) //done, tapi cek bagian username/id
	r_owner.GET("/get_user_information", owner.Get_user_information)   //done, tapi cek bagian username/id
	r_owner.GET("/search", owner.Search)                               //done, tapi cek bagian username/id
	r_owner.GET("/logs", owner.Logs)                                   //done
	r_owner.GET("/get_name", owner.Get_name)                           //done

	//route common
	e.POST("/login", controller.Login)            //done
	e.PUT("/set_offline", controller.Set_offline) //done
	//e.POST("add_admin/", owner.Add_admin) //baru
	//e.GET("verify_login/", controller.Verify_login1)
	return e
}
