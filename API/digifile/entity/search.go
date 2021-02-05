package entity

type Search struct {
	Name        string `json:"name"`
	Activity_id int    `json:"activity_id"`
	Start_date  string `json:"start_date"`
	End_date    string `json:"End_date"`
}
