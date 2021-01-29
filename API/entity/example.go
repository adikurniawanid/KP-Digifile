package entity

import (
	"time"
)

type (
	ExampleEntity struct {
		Title       string `json:"title"`
		Description string `json:"description"`
	}
	Detail_activity struct {
		Activity_id int    `json:"activity_id"`
		Description string `json:"description"`
	}
	Files struct {
		File_id      int    `json:"file_id"`
		File_name    string `json:"file_name"`
		Directory    string `json:"directory"`
		Size         string `json:"Size"`
		Trash_status bool   `json:"trash_status"`
		Owner        string `json:"owner"`
	}
	Folder struct {
		Folder_name string `json:"folder_name"`
		Directory   string `json:"directory"`
		Owner       string `json:"owner"`
	}
	Log_activity struct {
		Log_id        int       `json:"log_id"`
		Username      string    `json:"username"`
		File_id       int       `json:"file_id"`
		Activity_id   int       `json:"activity_id"`
		Activity_date time.Time `json:"activity_date"`
	}
	Role struct {
		Role_id     int    `json:"role_id"`
		Description string `json:"description"`
	}
	Users struct {
		Username     string `json:"username"`
		Name         string `json:"name"`
		Password     string `json:"password"`
		Phone        string `json:"phone"`
		Email        string `json:"email"`
		Space        int    `json:"space"`
		Unused_space int    `json:"unused_space"`
		Role_id      int    `json:"role_id"`
		Page         int    `json:"page"`
	}

	Upload struct {
		Username string `json:"username"`
		Path     string `json:"path"`
	}

	Download struct {
		Username     string `json:"username"`
		Current_path string `json:"Current_path"`
		File_name    string `json:"File_name"`
	}

	Create_folder struct {
		Username    string `json:"username"`
		Curent_path string `json:"curent_path"`
		Folder_name string `json:"Folder_name"`
	}
	Edit_user struct {
		Username string `json:"username"`
		Name     string `json:"name"`
		Space    int    `json:"space"`
		Email    string `json:"email"`
	}
	Delete_file struct {
		File_id  string `json:"file_id"`
		Username string `json:"username"`
	}
	Delete_folder struct {
		Folder_id int    `json:"folder_id"`
		Username  string `json:"username"`
	}
	Delete_trash struct {
		Owner   string `json:"owner"`
		File_id int    `json:"file_id"`
	}
	Rename_file struct {
		Id       int    `json:"id"`
		New_name string `json:"new_name"`
		Username string `json:"username"`
	}
	Rename_folder struct {
		Username      string `json:"username"`
		New_item_name string `json:"new_item_name"`
		Id            int    `json:"id"`
	}
	Search struct {
		Name        string `json:"name"`
		Activity_id int    `json:"activity_id"`
		Start_date  string `json:"start_date"`
		End_date    string `json:"End_date"`
	}
	Get_log_activity struct {
		Username      string  `json:"username"`
		Name          string  `json:"name"`
		Tanggal       *string `json:"tanggal"`
		Last_activity *string `json:"last_activity"`
		Kuota         string  `json:"kuota"`
		Status        string  `json:"status"`
	}
	Get_user_log_activity struct {
		Tanggal       string `json:"tanggal"`
		Last_activity string `json:"last_activity"`
	}
	Get_items struct {
		Username    string `json:"username"`
		Item_name   string `json:"item_name"`
		Curent_path string `json:"Curent_path"`
	}
	Get_activity struct {
		Activity_date time.Time `json:"activity_date"`
		Description   string    `json:"description"`
		File_name     string    `json:"file_name"`
	}
	Is_enough_space struct {
		Username string `json:"username"`
		Size     string `json:"Size"`
	}
)
