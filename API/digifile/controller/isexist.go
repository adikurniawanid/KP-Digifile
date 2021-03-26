package controller

import (
	"context"
	"digifile/utils"
)

func Is_username_exist(uid string) bool {
	var result bool
	result = true
	syn := "select is_username_exist('" + uid + "');"
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

func Is_user(uid string) bool {
	var result bool
	result = true
	syn := "select is_user('" + uid + "');"
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

func Is_admin(uid string) bool {
	var result bool
	result = true
	syn := "select is_admin('" + uid + "');"
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
