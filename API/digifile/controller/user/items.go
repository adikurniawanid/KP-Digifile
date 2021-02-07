package user

import (
	"archive/zip"
	"context"
	"digifile/config"
	"digifile/constant"
	"digifile/entity/user"
	"digifile/responsegraph"
	"digifile/utils"
	"io"
	"io/ioutil"
	"net/http"
	"os"
	"strconv"
	"strings"

	"github.com/labstack/echo/v4"
	"github.com/shopspring/decimal"
)

//==================================================================deklarasi variabel db secara global
var db = config.Getdb()

//==================================================================func file log db
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

//==========================================================================func file fisik
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
	var model user.Create_folder
	c.Bind(&model)
	root := "upload/"
	res := responsegraph.Data{
		Status:  constant.StatusSuccess,
		Message: "Berhasil Create Folder",
		Data:    1,
	}
	curentpath := model.Curent_path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" || curentpath == "/" {
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

//============================================================================func upload

func Upload_file(c echo.Context) error {
	var model user.Upload
	c.Bind(&model)
	curentpath := model.Path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" || curentpath == "/" {
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
	var model user.Upload
	c.Bind(&model)
	curentpath := model.Path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" || curentpath == "/" {
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

func Delete_folder(c echo.Context) error {
	var model user.Delete_folder
	c.Bind(&model)
	syn := "select delete_folder('" + model.Folder_id + "','" + model.Username + "');"
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
	var model user.Delete_file
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

func Rename_file(c echo.Context) error {
	var model user.Rename_file
	c.Bind(&model)
	var path string
	var oldname string
	if model.New_name == "" || model.New_name == "null" || model.New_name == "undefined" {
		return c.JSON(http.StatusOK, "Nama baru tidak boleh kosong")
	}
	syn1 := "select * from get_item_information('" + model.Id + "');"
	hasil1, err := db.Query(context.Background(), syn1)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	temp := strings.Split(oldname, ".")
	var ekstensi string
	ekstensi = temp[(len(temp) - 1)]
	if ekstensi == "null" || ekstensi == "" || ekstensi == "undefined" {
		ekstensi = ""
	} else {
		ekstensi = "." + temp[(len(temp)-1)]
	}
	syn := "select rename_file('" + model.Id + "','" + model.New_name + ekstensi + "');"
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
	rename(path_full, oldname, model.New_name+ekstensi)
	return c.JSON(http.StatusOK, res)
}

func Rename_folder(c echo.Context) error {
	var model user.Rename_folder
	c.Bind(&model)
	var path string
	var oldname string
	syn1 := "select * from get_item_information('" + model.Id + "');"
	hasil1, err := db.Query(context.Background(), syn1)
	if err != nil {
		utils.LogError(err)
	}
	for hasil1.Next() {
		if err := hasil1.Scan(&oldname, &path); err != nil {
			utils.LogError(err)
		}
	}
	syn := "select rename_folder('" + model.Id + "','" + model.New_item_name + "','" + model.Username + "');"
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
	var model user.Download
	c.Bind(&model)
	root := "upload/" + model.Username
	curentpath := model.Current_path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" || curentpath == "/" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Current_path
		curentpath += "/"
	}
	//===============================================================================================membuka data yang ada pada penyimpanan fisik sesuai parameter yang ditentukan
	file, err := os.Open(root + curentpath + model.File_name)
	fi, _ := os.Stat(root + curentpath + model.File_name)
	if err != nil {
		utils.LogError(err)
	}
	defer file.Close()
	c.Response().Writer.Header().Set("Content-Disposition", "attachment; filename="+model.File_name)
	c.Response().Writer.Header().Set("Content-Length", strconv.Itoa(int(fi.Size())))
	c.Response().Writer.Header().Set("Content-Type", c.Request().Header.Get("Content-Type"))
	// ==========================================================================================menyimpan file pada penyimpanan fisik
	_, err = io.Copy(c.Response().Writer, file)
	return c.File(model.File_name)
}

func DownloadFolder(c echo.Context) error {
	var model user.Download
	c.Bind(&model)
	root := "upload/" + model.Username
	curentpath := model.Current_path
	if curentpath == "" || curentpath == "null" || curentpath == "undefined" || curentpath == "/" {
		curentpath = "/"
	} else {
		curentpath = "/" + model.Current_path
		curentpath += "/"
	}
	//===============================================================================================kompresi folder ke zip dalam directory downtemp
	fulldir, path, name := ZipWriter(root, curentpath, model.File_name)
	//===============================================================================================membuka data yang ada pada penyimpanan fisik sesuai parameter yang ditentukan
	file, err := os.Open(fulldir)
	fi, _ := os.Stat(fulldir)
	if err != nil {
		utils.LogError(err)
	}
	defer file.Close()
	temp := strings.Split(model.File_name, "/")
	filename := temp[0] + ".zip"
	c.Response().Writer.Header().Set("Content-Disposition", "attachment; filename="+filename)
	c.Response().Writer.Header().Set("Content-Length", strconv.Itoa(int(fi.Size())))
	c.Response().Writer.Header().Set("Content-Type", c.Request().Header.Get("Content-Type"))
	// ==========================================================================================menyimpan file pada penyimpanan fisik
	_, err = io.Copy(c.Response().Writer, file)
	//remove zip file temp in downtemp directory
	remove(path, name)
	return c.File(filename)
}

func addFiles(w *zip.Writer, basePath, baseInZip string) {
	// Open the Directory
	files, err := ioutil.ReadDir(basePath)
	if err != nil {
		utils.LogError(err)
	}

	for _, file := range files {
		utils.LogInfo(basePath + file.Name())
		if !file.IsDir() {
			dat, err := ioutil.ReadFile(basePath + file.Name())
			if err != nil {
				utils.LogError(err)
			}

			// Add some files to the archive.
			f, err := w.Create(baseInZip + file.Name())
			if err != nil {
				utils.LogError(err)
			}
			_, err = f.Write(dat)
			if err != nil {
				utils.LogError(err)
			}
		} else if file.IsDir() {

			// Recurse
			newBase := basePath + file.Name() + "/"
			utils.LogInfo("Recursing and Adding SubDir: " + file.Name())
			utils.LogInfo("Recursing and Adding SubDir: " + newBase)

			addFiles(w, newBase, baseInZip+file.Name()+"/")
		}
	}
}

func ZipWriter(root string, path string, foldername string) (string, string, string) {
	baseFolder := root + path + foldername
	baseOutput := "downtemp/temp.zip"
	base := "downtemp/"
	name := "temp.zip"
	// Get a Buffer to Write To
	outFile, err := os.Create(baseOutput)
	if err != nil {
		utils.LogError(err)
	}
	defer outFile.Close()

	// Create a new zip archive.
	w := zip.NewWriter(outFile)

	// Add some files to the archive.
	addFiles(w, baseFolder, foldername+"/")

	if err != nil {
		utils.LogError(err)
	}

	// Make sure to check the error on Close.
	err = w.Close()
	if err != nil {
		utils.LogError(err)
	}
	return baseOutput, base, name
}
