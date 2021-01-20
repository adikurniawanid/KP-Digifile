package main

import (
	"fmt"
	"os"
	"template-api-gecho/constant"
	"template-api-gecho/routes"
)

// Starting server
// godotenv loaded at utils/log.go
// because log.go is loaded first than main init
// TODO: Change Architecture
func main() {
	//ini adalah testing pemanggilan function
	// id := "1"
	// username := "akdev"
	// syn := "select recovery_trash(" + id + ",'" + username + "');"
	// db := config.Getdb()
	// db.QueryRow(context.Background(), syn)

	echo := routes.Routing.GetRoutes(routes.Routing{})
	address := os.Getenv(constant.APPHost)
	port := os.Getenv(constant.APPPort)
	host := fmt.Sprintf("%s:%s", address, port)

	_ = echo.Start(host)
}
