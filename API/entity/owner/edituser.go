package owner

type Edit_user struct {
	Username string `json:"username"`
	Name     string `json:"name"`
	Space    int    `json:"space"`
	Email    string `json:"email"`
}
