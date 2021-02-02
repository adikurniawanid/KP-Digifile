package main

import (
	"fmt"
	"os"
	"template-api-gecho/constant"
	"template-api-gecho/routes"
)

func main() {
	echo := routes.GetRoutes()
	address := os.Getenv(constant.APPHost)
	port := os.Getenv(constant.APPPort)
	host := fmt.Sprintf("%s:%s", address, port)

	_ = echo.Start(host)
}
