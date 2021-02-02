package user

type Users struct {
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
