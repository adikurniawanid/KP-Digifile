package controller

import (
	"context"
	"crypto/sha256"
	"encoding/base64"
	"io"
	"net/http"
	"os"
	"strconv"
	"strings"
	"template-api-gecho/config"
	"template-api-gecho/constant"
	"template-api-gecho/entity"
	"template-api-gecho/model"
	"template-api-gecho/responsegraph"
	"template-api-gecho/utils"

	"github.com/labstack/echo/v4"
	"github.com/shopspring/decimal"
)

var db = config.Getdb()

type ExampleController struct {
	model model.ExampleModel
}

func Hash_256(input string) string {
	hasher := sha256.New()
	hasher.Write([]byte(input))
	sha := base64.URLEncoding.EncodeToString(hasher.Sum(nil))
	return sha
}

func isexist(path string, name string) bool {
	tampung := path + name
	result := false
	if _, err := os.Stat(tampung); os.IsNotExist(err) {
		utils.LogError(err)
		result = false
	} else {
		result = true
	}
	return result
}
func isexist1(path string) bool {
	result := false
	if _, err := os.Stat(path); os.IsNotExist(err) {
		utils.LogError(err)
		result = false
	} else {
		result = true
	}
	return result
}
func verify_duplicate_file(path string, name string) string {
	arr := strings.Split(name, ".")
	aftersplit := ""
	for i := 0; i < (len(arr) - 1); i++ {
		aftersplit += arr[i] + "."
	}
	if len(arr) != 0 && len(arr) != 1 {
		tampung := aftersplit
		inc := 0
		idx := (len(tampung) - 1)
		for {
			if isexist(path, name) {
				inc++
				temp := tampung[:idx] + "(" + strconv.Itoa(inc) + ")" + tampung[idx:]
				name = temp + arr[(len(arr)-1)]
			} else {
				break
			}
		}
	} else {
		tampung := name
		inc := 0
		for {
			if isexist(path, name) {
				inc++
				name = tampung + "(" + strconv.Itoa(inc) + ")"
			} else {
				break
			}
		}
	}

	gabung := path + name
	file, err := os.Create(gabung)
	if err != nil {
		utils.LogError(err)
	}
	defer file.Close()
	return gabung
}

func verify_duplicate_folder(path string, name string) string {
	tampung := name
	inc := 0
	for {
		if isexist(path, name) {
			inc++
			name = tampung + "(" + strconv.Itoa(inc) + ")"
		} else {
			break
		}
	}
	gabung := path + name
	err := os.MkdirAll(gabung, 0755)
	if err != nil {
		utils.LogError(err)
	}
	return gabung
}
func remove(path string, name string) string {
	tampung := path + name
	err := os.RemoveAll(tampung)
	if err != nil {
		utils.LogError(err)
	}
	return tampung
}
func rename(path string, oldname string, newname string) string {
	old := path + oldname
	new := path + newname
	err := os.Rename(old, new)
	if err != nil {
		utils.LogError(err)
	}
	return new
}

func Create_folder(c echo.Context) error {
	var model entity.Create_folder
	c.Bind(&model)
	root := "upload/"
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Create Folder",
		Data:    1,
	}
	curentpath := model.Curent_path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	if isexist1(root + model.Username + curentpath + model.Folder_name) {
		res.Message = "Duplikasi ditemukan, gagal Create Folder"
		res.Data = 0
		return c.JSON(http.StatusAccepted, res)
	}
	err := os.MkdirAll(root+model.Username+curentpath+model.Folder_name, 0755)
	if err != nil {
		res.Message = "Gagal Create Folder"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusAccepted, res)
	}
	Add_folder(model.Folder_name, curentpath, model.Username)
	return c.JSON(http.StatusAccepted, res)
}

func Upload_file(c echo.Context) error {
	var model entity.Upload
	c.Bind(&model)
	curentpath := model.Path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Path
		curentpath += "/"
	}
	root := "upload/"
	// =======================================================cek jika directory root belum ada
	if isexist1(root) == false {
		err := os.MkdirAll(root, 0755)
		if err != nil {
			utils.LogError(err)
		}
	}
	username := model.Username
	utils.LogInfo(model.Username)
	newfolder := root + username + curentpath
	// ===========================================================cek jika directory usernmae belum ada
	if isexist1(newfolder) == false {
		err := os.MkdirAll(newfolder, 0755)
		if err != nil {
			utils.LogError(err)
		}
	}
	// =================================================================ini untuk meminta Request data dan membaginya sesuai size yang di definisikan
	err1 := c.Request().ParseMultipartForm(2 * 1024 * 1024 * 1024)
	if err1 != nil {
		utils.LogError(err1)
	}
	// ====================================================================ini agar dapat upload multi
	m, err2 := c.MultipartForm()
	if err2 != nil {
		utils.LogError(err2)
	}
	// =========================================================================ini nama parameter file
	files := m.File["myfiles"]
	for i, _ := range files {
		// =========================================================================ini cek penyimpanan drive akun
		if Is_enough_space(model.Username, strconv.Itoa(int(files[i].Size))) == false {
			return c.JSON(http.StatusAccepted, "Ruang penyimpanan tidak mencukupi untuk upload. Semua proses upload file selanjutnya dibatalkan")
		}
		// ============================================================================ini membaca file
		file, err := files[i].Open()
		defer file.Close()
		if err != nil {
			utils.LogError(err)
		}
		newfile := ""
		// ============================================================================ini cek directory file ada atau tidak
		if isexist(newfolder, files[i].Filename) {
			newfile = verify_duplicate_file(newfolder, files[i].Filename)
			// =============================================================================ini di split untuk mendapatkan nama file
			arr := strings.Split(newfile, "/")
			// =================================================================================ini memanggil function db
			Add_file(arr[(len(arr)-1)], curentpath, files[i].Size, model.Username)
			// =================================================================================ini proses pembuatan file pada temporary disk
			dst, err1 := os.Create(newfile)
			defer dst.Close()
			if err1 != nil {
				utils.LogError(err1)
			}
			// ======================================================================================ini untuk menyimpan file
			if _, err := io.Copy(dst, file); err != nil {
				if err != nil {
					utils.LogError(err)
				}
			}
		} else {
			// =================================================================================ini proses pembuatan file pada temporary disk
			dst, err1 := os.Create(newfolder + files[i].Filename)
			// =================================================================================ini memanggil function db
			Add_file(files[i].Filename, curentpath, files[i].Size, model.Username)
			defer dst.Close()
			if err1 != nil {
				utils.LogError(err1)
			}
			// ======================================================================================ini untuk menyimpan file
			if _, err := io.Copy(dst, file); err != nil {
				if err != nil {
					utils.LogError(err)
				}
			}
		}
	}
	return c.JSON(http.StatusAccepted, "Done")
}

func Upload_folder(c echo.Context) error {
	var model entity.Upload
	c.Bind(&model)
	curentpath := model.Path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Path
		curentpath += "/"
	}
	root := "upload/"
	// =======================================================cek jika directory root belum ada
	if isexist1(root) == false {
		err := os.MkdirAll(root, 0755)
		if err != nil {
			utils.LogError(err)
		}
	}
	username := model.Username
	utils.LogInfo(model.Username)
	newfolder := root + username + curentpath
	// ===========================================================cek jika directory usernmae belum ada
	if isexist1(newfolder) == false {
		err := os.MkdirAll(newfolder, 0755)
		if err != nil {
			utils.LogError(err)
		}
	}
	// =================================================================ini untuk meminta Request data dan membaginya sesuai size yang di definisikan
	err1 := c.Request().ParseMultipartForm(2 * 1024 * 1024 * 1024)
	if err1 != nil {
		utils.LogError(err1)
	}
	// ====================================================================ini agar dapat upload multi
	m, err2 := c.MultipartForm()
	if err2 != nil {
		utils.LogError(err2)
	}
	// =========================================================================ini nama parameter file
	files := m.File["myfiles"]
	for i, _ := range files {
		if Is_enough_space(model.Username, strconv.Itoa(int(files[i].Size))) == false {
			return c.JSON(http.StatusAccepted, "Ruang penyimpanan tidak mencukupi untuk upload. Semua proses upload file selanjutnya dibatalkan")
		}
		// ============================================================================ini membaca file
		file, err := files[i].Open()
		defer file.Close()
		if err != nil {
			utils.LogError(err)
		}
		newfile := ""
		// ============================================================================ini cek directory file ada atau tidak
		if isexist(newfolder, files[i].Filename) {
			newfile = verify_duplicate_file(newfolder, files[i].Filename)
			// =============================================================================ini di split untuk mendapatkan nama file
			arr := strings.Split(newfile, "/")
			ah := arr[:(len(arr) - 1)]
			folder := ""
			// ==================================================================================proses pengambilan folder dari file
			for i := 0; i < len(ah); i++ {
				folder += ah[i] + "/"
			}
			folderdb := "/"
			// ==============================================================================================proses pengambilan folder untuk db
			for i := 2; i < (len(ah) - 1); i++ {
				folderdb += ah[i] + "/"
			}
			foldername := ah[(len(ah) - 1)]
			directory := "/"
			for i := 2; i < len(ah); i++ {
				directory += ah[i] + "/"
			}
			// =================================================================================================pengecekan directory
			if isexist1(folder) == false {
				// =======================================================================================================pemanggilan function db
				Add_folder(foldername, folderdb, model.Username)
			}
			// ===============================================================================================================pembuatan directory pada penyimpanan fisik
			os.MkdirAll(folder, 0755)
			filename := arr[(len(arr) - 1)]
			// ================================================================================================================pemanggilan function db
			Add_file(filename, directory, files[i].Size, model.Username)
			// =================================================================================ini proses pembuatan file pada temporary disk
			dst, err1 := os.Create(newfile)
			defer dst.Close()
			if err1 != nil {
				utils.LogError(err1)
			}
			// ======================================================================================ini untuk menyimpan file
			if _, err := io.Copy(dst, file); err != nil {
				if err != nil {
					utils.LogError(err)
				}
			}
		} else {
			temp := newfolder + files[i].Filename
			// =============================================================================ini di split untuk mendapatkan nama file
			arr := strings.Split(temp, "/")
			ah := arr[:(len(arr) - 1)]
			folder := ""
			// ==================================================================================proses pengambilan folder dari file
			for i := 0; i < len(ah); i++ {
				folder += ah[i] + "/"
			}
			folderdb := "/"
			// ==============================================================================================proses pengambilan folder untuk db
			for i := 2; i < (len(ah) - 1); i++ {
				folderdb += ah[i] + "/"
			}
			foldername := ah[(len(ah) - 1)]
			directory := "/"
			for i := 2; i < len(ah); i++ {
				directory += ah[i] + "/"
			}
			// =================================================================================================pengecekan directory
			if isexist1(folder) == false {
				// =======================================================================================================pemanggilan function db
				Add_folder(foldername, folderdb, model.Username)
			}
			// ===============================================================================================================pembuatan directory pada penyimpanan fisik
			os.MkdirAll(folder, 0755)
			filename := arr[(len(arr) - 1)]
			// =================================================================================ini proses pembuatan file pada temporary disk
			dst, err1 := os.Create(newfolder + files[i].Filename)
			// ================================================================================================================pemanggilan function db
			Add_file(filename, directory, files[i].Size, model.Username)
			defer dst.Close()
			if err1 != nil {
				utils.LogError(err1)
			}
			// ======================================================================================ini untuk menyimpan file
			if _, err := io.Copy(dst, file); err != nil {
				if err != nil {
					utils.LogError(err)
				}
			}
		}
	}
	return c.JSON(http.StatusAccepted, "Done")
}

func Is_enough_space(username string, size_file string) bool {
	var result bool
	size, err1 := decimal.NewFromString(size_file)
	if err1 != nil {
		utils.LogError(err1)
	}
	syn := "select * from is_enough_space('" + username + "','" + size.String() + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
	}
	for test.Next() {
		if err := test.Scan(&result); err != nil {
			utils.LogError(err)
		}
	}
	return result
}

func Get_trash_file_list(c echo.Context) error {
	var model entity.Get_items
	var input entity.Get_items
	c.Bind(&model)
	var result []interface{}
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from get_trash_file_list('" + model.Username + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		tampung = strings.Split(input.Item_name, ".")
		extension = append(extension, tampung[(len(tampung)-1)])
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	res := responsegraph.ResponseGenericGet2{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   extension,
		Id:      item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_trash_folder_list(c echo.Context) error {
	var model entity.Get_items
	var input entity.Get_items
	c.Bind(&model)
	var result []interface{}
	var item_id []int
	var item int
	syn := "select * from get_trash_folder_list('" + model.Username + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Id:      item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Search(c echo.Context) error {
	var model entity.Search
	var input entity.Get_log_activity
	c.Bind(&model)
	var result []interface{}
	var username []interface{}
	syn := "select * from search_owner('" + model.Name + "'," + strconv.Itoa(model.Activity_id) + ",'" + model.Start_date + "','" + model.End_date + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Username, &input.Name, &input.Tanggal, &input.Last_activity, &input.Kuota, &input.Status); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input)
		username = append(username, input.Username)
	}
	res := responsegraph.ResponseGenericGet2{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   username,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_file_list(c echo.Context) error {
	var model entity.Get_items
	var input entity.Get_items
	c.Bind(&model)
	curentpath := model.Curent_path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	var result []string
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from get_file_list('" + model.Username + "','" + curentpath + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		item_id = append(item_id, item)
		tampung = strings.Split(input.Item_name, ".")
		extension = append(extension, tampung[(len(tampung)-1)])
		result = append(result, input.Item_name)
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil Select Data",
		Data:     result,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_folder_list(c echo.Context) error {
	var model entity.Get_items
	var input entity.Get_items
	c.Bind(&model)
	curentpath := model.Curent_path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	var result []interface{}
	var item_id []int
	var item int
	syn := "select * from get_folder_list('" + model.Username + "','" + curentpath + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Id:      item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_all_item_list(c echo.Context) error {
	var model entity.Get_items
	var input entity.Get_items
	c.Bind(&model)
	curentpath := model.Curent_path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Curent_path
		curentpath += "/"
	}
	var result []string
	var count_file int
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from Get_all_item_list('" + model.Username + "','" + curentpath + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	count := "select * from get_file_count('" + model.Username + "','" + curentpath + "');"
	hasil1, err := db.Query(context.Background(), count)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&count_file); err != nil {
			utils.LogError(err)
		}
	}
	for i := 0; i < count_file; i++ {
		tampung = strings.Split(result[i], ".")
		extension = append(extension, tampung[(len(tampung)-1)])
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Data:     result,
		File:     count_file,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Search_user(c echo.Context) error {
	var model entity.Get_items
	var input entity.Get_items
	c.Bind(&model)
	var result []string
	var count_file int
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from search_user('" + model.Username + "','" + model.Item_name + "');"
	test, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusBadRequest, err)
	}
	for test.Next() {
		if err := test.Scan(&input.Item_name, &item); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, input.Item_name)
		item_id = append(item_id, item)
	}
	count := "select * from get_search_file_count('" + model.Username + "','" + model.Item_name + "');"
	hasil1, err := db.Query(context.Background(), count)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&count_file); err != nil {
			utils.LogError(err)
		}
	}
	for i := 0; i < count_file; i++ {
		tampung = strings.Split(result[i], ".")
		extension = append(extension, tampung[(len(tampung)-1)])
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Data:     result,
		File:     count_file,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_log_activity(c echo.Context) error {
	var result []interface{}
	var username []interface{}
	var model entity.Get_log_activity
	syn := "select * from get_log_activity;"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&model.Username, &model.Name, &model.Tanggal, &model.Last_activity, &model.Kuota, &model.Status); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, model)
		username = append(username, model.Username)
	}
	res := responsegraph.ResponseGenericGet2{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   username,
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	return c.JSON(http.StatusOK, res)
}

func Get_user_log_activity(c echo.Context) error {
	var result []interface{}
	var input entity.Users
	c.Bind(&input)
	var model entity.Get_user_log_activity
	syn := "select * from get_user_log_activity('" + input.Username + "','" + strconv.Itoa(input.Page) + "');"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&model.Tanggal, &model.Last_activity); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, model)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	return c.JSON(http.StatusOK, res)
}

func Logs(c echo.Context) error {
	var model entity.Users
	var result int
	c.Bind(&model)
	syn := "select count(log_id) as jumlah from logs where username='" + model.Username + "';"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&result); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	var result1 []interface{}
	var model1 entity.Get_user_log_activity
	syn1 := "select * from get_user_log_activity('" + model.Username + "'," + strconv.Itoa(model.Page) + ");"
	test1, err := db.Query(context.Background(), syn1)
	for test1.Next() {
		if err := test1.Scan(&model1.Tanggal, &model1.Last_activity); err != nil {
			utils.LogError(err)
		}
		result1 = append(result1, model1)
	}
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
		Data1:   result1,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_information_storage(c echo.Context) error {
	var result []interface{}
	var input entity.Users
	c.Bind(&input)
	var model entity.Detail_activity
	syn := "select * from get_information_storage('" + input.Username + "');"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&model.Description); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
		result = append(result, model.Description)
	}
	res := responsegraph.ResponseGenericGet{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	return c.JSON(http.StatusOK, res)
}

func Get_name(c echo.Context) error {
	var result string
	var input entity.Users
	c.Bind(&input)
	syn := "select * from get_name('" + input.Username + "');"
	test, err := db.Query(context.Background(), syn)
	for test.Next() {
		if err := test.Scan(&result); err != nil {
			utils.LogError(err)
			return c.JSON(http.StatusBadRequest, err)
		}
	}
	res := responsegraph.Name{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Select Data",
		Data:    result,
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusForbidden, err)
	}
	return c.JSON(http.StatusOK, res)
}

func Login(c echo.Context) error {
	var page int
	page = 0
	var model entity.Users
	c.Bind(&model)
	is_username_exist := Is_username_exist(c)
	is_admin := Is_admin(c)
	is_user := Is_user(c)
	verify_login := Verify_login(c)
	if is_username_exist == true {
		if is_admin == true {
			if verify_login == true {
				Set_online(c)
				page = 1
			}
		} else if is_user == true {
			if verify_login == true {
				Set_online(c)
				page = 2
			}
		}
	}
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Status terdeteksi",
		Data:    page,
	}
	//result := "is_username_exist = " + strconv.FormatBool(is_username_exist) + " is_admin = " + strconv.FormatBool(is_admin) + " is_user = " + strconv.FormatBool(is_user) + " verify _login = " + strconv.FormatBool(verify_login) + " role = " + strconv.Itoa(page)
	return c.JSON(http.StatusOK, res)
}

func Set_online(c echo.Context) {
	var model entity.Users
	c.Bind(&model)
	syn := "select set_online('" + model.Username + "');"
	db.Query(context.Background(), syn)
}

func Verify_login(c echo.Context) bool {
	var model entity.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select verify_login('" + model.Username + "','" + Hash_256(model.Password) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return result
	}
	if err != nil {
		utils.LogError(err)
		return result
	}
	return result
}

func Verify_login1(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select verify_login('" + model.Username + "','" + Hash_256(model.Password) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return c.JSON(http.StatusOK, result)
	}
	if err != nil {
		utils.LogError(err)
		return c.JSON(http.StatusOK, err)
	}
	return c.JSON(http.StatusOK, result)
}

func Is_username_exist(c echo.Context) bool {
	var model entity.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select is_username_exist('" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return result
	}
	if err != nil {
		utils.LogError(err)
		return result
	}
	return result
}

func Is_user(c echo.Context) bool {
	var model entity.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select is_user('" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return result
	}
	if err != nil {
		utils.LogError(err)
		return result
	}
	return result
}

func Is_admin(c echo.Context) bool {
	var model entity.Users
	c.Bind(&model)
	var result bool
	result = true
	syn := "select is_admin('" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if hasil.RowsAffected() == 0 {
		result = false
		return result
	}
	if err != nil {
		utils.LogError(err)
		return result
	}
	return result
}

func Add_folder(folder_name string, directory string, owner string) (string, error) {
	syn := "select * from add_folder('" + folder_name + "','" + directory + "','" + owner + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
		return "row affected : " + strconv.Itoa(int(hasil.RowsAffected())), err
	}
	return "row affected : " + strconv.Itoa(int(hasil.RowsAffected())), err
}

func Add_file(file_name string, path string, size int64, username string) (bool, error) {
	result := false
	size1 := strconv.FormatInt(size, 10)
	size2, err1 := decimal.NewFromString(size1)
	if err1 != nil {
		utils.LogError(err1)
		return result, err1
	}
	syn := "select add_file('" + file_name + "','" + path + "','" + size2.String() + "','" + username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		utils.LogWarn("row affected = " + strconv.Itoa(int(hasil.RowsAffected())))
		utils.LogError(err)
		return result, err
	}
	result = true
	return result, err
}

func Add_user(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	res := responsegraph.Data{
		Status:  constant.StatusError,
		Message: "",
		Data:    2,
	}
	if Is_username_exist(c) {
		res.Message = "Username telah terdaftar"
		return c.JSON(http.StatusOK, res)
	}
	if model.Space < 0 {
		res.Data = 0
		res.Message = "Space tidak valid"
		return c.JSON(http.StatusOK, res)
	}
	syn := "select add_user('" + model.Username + "','" + model.Name + "','" + Hash_256(model.Password) + "','" + model.Phone + "','" + model.Email + "','" + strconv.Itoa(model.Space) + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		res.Message = "Data gagal ditambahkan"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	res.Status = constant.StatusSuccess
	res.Message = "Berhasil Add user"
	res.Data = int(hasil.RowsAffected())
	return c.JSON(http.StatusOK, res)
}

func Edit_user(c echo.Context) error {
	var model entity.Edit_user
	c.Bind(&model)
	res := responsegraph.Data{
		Status:  constant.StatusError,
		Message: "Username tidak ditemukan",
		Data:    2,
	}
	if Is_username_exist(c) == false {
		return c.JSON(http.StatusOK, res)
	}
	syn := "select edit_user('" + model.Username + "','" + model.Name + "','" + strconv.Itoa(model.Space) + "','" + model.Email + "');"
	hasil, err := db.Exec(context.Background(), syn)
	if err != nil {
		res.Message = "Data gagal ditambahkan"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	res.Status = constant.StatusSuccess
	res.Message = "Berhasil Edit user"
	res.Data = int(hasil.RowsAffected())
	return c.JSON(http.StatusOK, res)
}

func Delete_folder(c echo.Context) error {
	var model entity.Delete_folder
	c.Bind(&model)
	syn := "select delete_folder('" + strconv.Itoa(model.Folder_id) + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil delete folder",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal dihapus"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Delete_file(c echo.Context) error {
	var model entity.Delete_file
	c.Bind(&model)
	syn := "select delete_file('" + model.File_id + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil delete file",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal dihapus"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Delete_trash(c echo.Context) error {
	var model entity.Delete_trash
	c.Bind(&model)
	var path string
	var oldname string
	syn1 := "select * from get_item_information(" + strconv.Itoa(model.File_id) + ");"
	hasil1, err := db.Query(context.Background(), syn1)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	syn := "select delete_trash('" + strconv.Itoa(model.File_id) + "','" + model.Owner + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil delete trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal dihapus"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	path_full := "upload/" + model.Owner + path
	// ================================================================function untuk menghapus pada penyimpanan fisik
	remove(path_full, oldname)
	return c.JSON(http.StatusOK, res)
}

func Recovery_trash_file(c echo.Context) error {
	var model entity.Delete_file
	c.Bind(&model)
	syn := "select recovery_trash_file('" + model.File_id + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil recovery trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal direcovery"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Recovery_trash_folder(c echo.Context) error {
	var model entity.Delete_folder
	c.Bind(&model)
	syn := "select recovery_trash_folder('" + strconv.Itoa(model.Folder_id) + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil recovery trash",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal direcovery"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	return c.JSON(http.StatusOK, res)
}

func Rename_file(c echo.Context) error {
	var model entity.Rename_file
	c.Bind(&model)
	var path string
	var oldname string
	syn1 := "select * from get_item_information(" + strconv.Itoa(model.Id) + ");"
	hasil1, err := db.Query(context.Background(), syn1)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	syn := "select rename_file(" + strconv.Itoa(model.Id) + ",'" + model.New_name + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil rename file",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal diperbaharui"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	path_full := "upload/" + model.Username + path
	// ================================================================function untuk rename pada penyimpanan fisik
	rename(path_full, oldname, model.New_name)
	return c.JSON(http.StatusOK, res)
}

func Rename_folder(c echo.Context) error {
	var model entity.Rename_folder
	c.Bind(&model)
	var path string
	var oldname string
	syn1 := "select * from get_item_information(" + strconv.Itoa(model.Id) + ");"
	hasil1, err := db.Query(context.Background(), syn1)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	syn := "select rename_folder(" + strconv.Itoa(model.Id) + ",'" + model.New_item_name + "','" + model.Username + "');"
	hasil, err := db.Exec(context.Background(), syn)
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil rename folder",
		Data:    int(hasil.RowsAffected()),
	}
	if err != nil {
		res.Message = "Data gagal diperbaharui"
		res.Data = 0
		utils.LogError(err)
		return c.JSON(http.StatusOK, res)
	}
	path_full := "upload/" + model.Username + path
	// ================================================================function untuk rename pada penyimpanan fisik
	rename(path_full, oldname, model.New_item_name)
	return c.JSON(http.StatusOK, res)
}

func DownloadFile(c echo.Context) error {
	var model entity.Download
	c.Bind(&model)
	root := "upload/" + model.Username
	curentpath := model.Current_path
	if curentpath == "" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Current_path
		curentpath += "/"
	}
	//===============================================================================================membuka data yang ada pada penyimpanan fisik sesuai parameter yang ditentukan
	file, err := os.Open(root + curentpath + model.File_name)
	if err != nil {
		utils.LogError(err)
	}
	defer file.Close()
	c.Response().Writer.Header().Set("Content-Disposition", "attachment; filename="+model.File_name)
	c.Response().Writer.Header().Set("Content-Type", c.Request().Header.Get("Content-Type"))
	// ==========================================================================================menyimpan file pada penyimpanan fisik
	_, err = io.Copy(c.Response().Writer, file)
	return c.File(model.File_name)
}

func Get_all_trash_list(c echo.Context) error {
	var model entity.Get_items
	c.Bind(&model)
	var items []string
	var count_file int
	var extension []string
	var tampung []string
	var item_id []int
	var item int
	syn := "select * from get_all_trash_list('" + model.Username + "');"
	hasil, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
	}
	for hasil.Next() {
		if err := hasil.Scan(&model.Item_name, &item); err != nil {
			utils.LogError(err)
		}
		items = append(items, model.Item_name)
		item_id = append(item_id, item)
	}
	count := "select * from get_trash_file_count('" + model.Username + "');"
	hasil1, err := db.Query(context.Background(), count)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&count_file); err != nil {
			utils.LogError(err)
		}
	}
	for i := 0; i < count_file; i++ {
		tampung = strings.Split(items[i], ".")
		extension = append(extension, tampung[(len(tampung)-1)])
	}
	res := responsegraph.Items{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Data:     items,
		File:     count_file,
		Ekstensi: extension,
		Id:       item_id,
	}
	return c.JSON(http.StatusOK, res)
}

func Get_user_information(c echo.Context) error {
	var model entity.Users
	c.Bind(&model)
	syn := "select * from get_user_information('" + model.Username + "');"
	hasil, err := db.Query(context.Background(), syn)
	if err != nil {
		utils.LogError(err)
	}
	for hasil.Next() {
		if err := hasil.Scan(&model.Username, &model.Name, &model.Space, &model.Email); err != nil {
			utils.LogError(err)
		}
	}
	res := responsegraph.Userinformation{
		Status:   constant.StatusSuccess,
		Message:  "Berhasil select data",
		Username: model.Username,
		Name:     model.Name,
		Space:    model.Space,
		Email:    model.Email,
	}
	return c.JSON(http.StatusOK, res)
}
