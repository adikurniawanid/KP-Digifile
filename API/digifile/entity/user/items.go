package user

type (
	Folder struct {
		Folder_name string `json:"folder_name"`
		Directory   string `json:"directory"`
		Owner       string `json:"owner"`
	}
	Files struct {
		File_id      int    `json:"file_id"`
		File_name    string `json:"file_name"`
		Directory    string `json:"directory"`
		Size         string `json:"Size"`
		Trash_status bool   `json:"trash_status"`
		Owner        string `json:"owner"`
	}
	Items struct {
		Id_user   string `json:"Id_user"`
		Id_parent string `json:"Id_parent"`
	}

	Download struct {
		Id        string `json:"Id"`
		Folder_id string `json:"Folder_id"`
		File_name string `json:"File_name"`
	}
	Create_folder struct {
		Username    string `json:"username"`
		Folder_id   string `json:"folder_id"`
		Folder_name string `json:"Folder_name"`
	}
	Delete_file struct {
		File_id  string `json:"file_id"`
		Username string `json:"username"`
	}
	Delete_folder struct {
		Folder_id string `json:"folder_id"`
		Username  string `json:"username"`
	}
	Delete_trash struct {
		Id      string `json:"Id"`
		File_id string `json:"file_id"`
	}
	Rename_file struct {
		Id       string `json:"id"`
		New_name string `json:"new_name"`
		Username string `json:"username"`
	}
	Rename_folder struct {
		Username      string `json:"username"`
		New_item_name string `json:"new_item_name"`
		Id            string `json:"id"`
	}
	Get_items struct {
		Id          string `json:"Id"`
		Item_name   string `json:"item_name"`
		Curent_path string `json:"Curent_path"`
	}
)
