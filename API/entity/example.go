package entity

import "time"

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
		File_id      int     `json:"file_id"`
		File_name    string  `json:"file_name"`
		Directory    string  `json:"directory"`
		Size         float32 `json:"Size"`
		Trash_status bool    `json:"trash_status"`
		Owner        string  `json:"owner"`
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
	}
	Add_user_space struct {
		Username string `json:"username"`
		Space    int    `json:"space"`
	}
	Delete_file struct {
		File_id  int    `json:"file_id"`
		Username string `json:"username"`
	}
	Delete_trash struct {
		Owner   string `json:"owner"`
		File_id int    `json:"file_id"`
	}
	Rename_file struct {
		Id       int    `json:"id"`
		New_name string `json:"new_name"`
	}
	Search struct {
		Name        string    `json:"name"`
		Activity_id int       `json:"activity_id"`
		Start_date  time.Time `json:"start_date"`
		End_date    time.Time `json:"End_date"`
	}
)
