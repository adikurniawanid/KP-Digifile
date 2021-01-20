package main

import (
	"context"
	"fmt"
	"log"
	"strconv"
	"template-api-gecho/utils"

	"github.com/jackc/pgx/v4/pgxpool"
)

var db *pgxpool.Pool

type Database struct{}

func init() {
	var err error

	host := "localhost"
	dbname := "digifile"
	user := "postgres"
	password := "postgres"
	schema := "public"

	psqlInfo := fmt.Sprintf("postgres://%s:%s@%s/%s?sslmode=disable&search_path=%s", user, password, host, dbname, schema)
	db, err = pgxpool.Connect(context.Background(), psqlInfo)
	if err != nil {
		utils.LogFatal(err)
	}
}

// func is_admin(c echo.Context) (bool, error) {
// 	var result bool
// 	result = true
// 	syn := "select is_admin('" + username + "');"
// 	hasil, err := db.Exec(context.Background(), syn)
// 	if err != nil {
// 		return result, err
// 	}
// 	if hasil.RowsAffected() < 1 {
// 		result = false
// 	}
// 	return result, nil
// }
func convert(b []byte) string {
	var a string
	for i := 0; i < len(b); i++ {
		a += strconv.Itoa(int(b[i])) + " "
	}
	return a
}
func main() {
	// var id, username string
	// fmt.Print("masukkan id : ")
	// fmt.Scan(&id)
	// fmt.Print("masukkan username : ")
	// fmt.Scan(&username)
	// var username string
	// fmt.Print("masukkan username : ")
	// fmt.Scan(&username)
	// var result bool
	// result = true
	// syn := "select is_user('" + username + "');"
	// hasil, err := db.Exec(context.Background(), syn)
	// if err != nil {
	// 	fmt.Println("Error message : ", err)
	// }
	// if hasil.RowsAffected() < 1 {
	// 	result = false
	// }
	// fmt.Println(result)
	// awal := "aw"
	// hashing := sha256.Sum256([]byte(awal))
	// password, err := hex.DecodeString(hex.EncodeToString(hashing[:]))
	// syn := "insert into jajal values('{" + convert(password) + "}');"
	// db.QueryRow(context.Background(), syn)
	// if err != nil {
	// 	fmt.Println(err)
	// }
	// fmt.Println(syn)
	syn := "select get_file_list('rsf');"
	test, err := db.Query(context.Background(), syn)
	// var arr1 []int
	// var arr2 []string
	if err != nil {
		log.Fatal(err)
	}
	var nama []interface{}
	var tampung []interface{}
	for test.Next() {
		//var size float32
		//nama = "Foto adi k"
		//size = 0.5
		if err := test.Scan(&tampung); err != nil {
			log.Fatal(err)
		}
		nama = append(nama, tampung)
		// arr1 = append(arr1, role_id)
		// arr2 = append(arr2, description)

	}
	fmt.Print(nama)
	// fmt.Println(arr1)
	// fmt.Println(arr2)
}
