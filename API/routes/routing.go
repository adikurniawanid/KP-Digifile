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
	e.GET("delete_file/", controller.Delete_file)        //fix
	e.GET("recovery_trash/", controller.Recovery_trash)  //fix
	e.PUT("rename_file/", controller.Rename_file)        //fix
	e.POST("add_file/", controller.Add_file)             //fix
	e.POST("add_user/", controller.Add_user)             //fix
	e.POST("add_user_space/", controller.Add_user_space) //fix
	e.DELETE("delete_trash/", controller.Delete_trash)   //fix
	e.GET("login/", controller.Login)                    //fix
	//e.GET("hash_password/", controller.Hash_password)             //fix
	e.GET("get_file_list/", controller.Get_file_list)             //fix
	e.GET("get_trash_list/", controller.Get_trash_list)           //fix
	e.GET("get_activity_detail/", controller.Get_activity_detail) //fix
	// e.GET("is_admin/", controller.Is_admin)                   //fix
	// e.GET("is_user/", controller.Is_user)                     //fix
	// e.GET("is_username_exist/", controller.Is_username_exist) //fix
	// e.GET("verify_login/", controller.Verify_login)           //fix
	return e
}
