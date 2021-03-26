package main

import users "digifile/controller/c_user"

func main() {
	coba, _ := users.Get_path("a3ecf1cd-005b-4855-900c-4878aae60a0c", "a3ecf1cd-005b-4855-900c-4878aae60a0c")
	println(coba)
}
