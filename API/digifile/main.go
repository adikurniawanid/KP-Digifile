package main

import (
	"digifile/constant"
	"digifile/routes"
	"fmt"
	"os"
)

func main() {
	echo := routes.GetRoutes()
	address := os.Getenv(constant.APPHost)
	port := os.Getenv(constant.APPPort)
	host := fmt.Sprintf("%s:%s", address, port)

	_ = echo.Start(host)
}
