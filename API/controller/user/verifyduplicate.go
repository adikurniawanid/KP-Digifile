package user

import (
	"os"
	"strconv"
	"strings"
	"template-api-gecho/utils"
)

func verify_duplicate_folder(path string, name string) string {
	tampung := name
	inc := 0
	for {
		if isexist(path, name) {
			inc++
			name = tampung + "(" + strconv.Itoa(inc) + ")"
		} else {
			break
		}
	}
	gabung := path + name
	err := os.MkdirAll(gabung, 0755)
	if err != nil {
		utils.LogError(err)
	}
	return gabung
}
func verify_duplicate_file(path string, name string) string {
	arr := strings.Split(name, ".")
	aftersplit := ""
	for i := 0; i < (len(arr) - 1); i++ {
		aftersplit += arr[i] + "."
	}
	if len(arr) != 0 && len(arr) != 1 {
		tampung := aftersplit
		inc := 0
		idx := (len(tampung) - 1)
		for {
			if isexist(path, name) {
				inc++
				temp := tampung[:idx] + "(" + strconv.Itoa(inc) + ")" + tampung[idx:]
				name = temp + arr[(len(arr)-1)]
			} else {
				break
			}
		}
	} else {
		tampung := name
		inc := 0
		for {
			if isexist(path, name) {
				inc++
				name = tampung + "(" + strconv.Itoa(inc) + ")"
			} else {
				break
			}
		}
	}

	gabung := path + name
	file, err := os.Create(gabung)
	if err != nil {
		utils.LogError(err)
	}
	defer file.Close()
	return gabung
}
