package config

import (
	"context"
	"digifile/constant"
	"digifile/utils"
	"fmt"
	"os"

	"github.com/jackc/pgx/v4/pgxpool"
)

var db *pgxpool.Pool

func init() {
	var err error

	host := os.Getenv(constant.DBHost)
	dbname := os.Getenv(constant.DBName)
	user := os.Getenv(constant.DBUser)
	password := os.Getenv(constant.DBPassword)
	schema := os.Getenv(constant.DBSchema)

	psqlInfo := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable&search_path=%s", user, password, host, dbname, schema)
	db, err = pgxpool.Connect(context.Background(), psqlInfo)
	if err != nil {
		utils.LogFatal(err)
	}
}

func Getdb() *pgxpool.Pool {
	return db
}
