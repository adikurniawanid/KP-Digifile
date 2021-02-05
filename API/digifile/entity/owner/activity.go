package owner

import "time"

type (
	Detail_activity struct {
		Activity_id int    `json:"activity_id"`
		Description string `json:"description"`
	}
	Log_activity struct {
		Log_id        int       `json:"log_id"`
		Username      string    `json:"username"`
		File_id       int       `json:"file_id"`
		Activity_id   int       `json:"activity_id"`
		Activity_date time.Time `json:"activity_date"`
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
	Get_activity struct {
		Activity_date time.Time `json:"activity_date"`
		Description   string    `json:"description"`
		File_name     string    `json:"file_name"`
	}
)
