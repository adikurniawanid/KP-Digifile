package user

import (
	"os"
	"template-api-gecho/utils"
)

func isexist(path string, name string) bool {
	tampung := path + name
	result := false
	if _, err := os.Stat(tampung); os.IsNotExist(err) {
		utils.LogError(err)
		result = false
	} else {
		result = true
	}
	return result
}
func isexist1(path string) bool {
	result := false
	if _, err := os.Stat(path); os.IsNotExist(err) {
		utils.LogError(err)
		result = false
	} else {
		result = true
	}
	return result
}
