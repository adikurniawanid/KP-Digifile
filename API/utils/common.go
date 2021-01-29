package utils

import (
	"crypto/rand"
	"fmt"
	"github.com/jackc/pgx/v4"
	"strings"
)

func IsStringEmpty(variable ...string) bool {
	for _, isi := range variable {
		if isi == "" {
			return true
		}
	}
	return false
}

func IsStringStrip(variable ...string) bool {
	for _, isi := range variable {
		if isi == "-" {
			return true
		}
	}
	return false
}

func GetUID() (string, error) {
	b := make([]byte, 16)
	_, err := rand.Read(b)
	if err != nil {
		LogError(err)
		return "", err
	}

	uuid := fmt.Sprintf("%x%x%x%x%x", b[0:4], b[4:6], b[6:8], b[8:10], b[10:])
	return uuid, nil
}

func TrimString(message string, trim string) string {
	message = strings.Trim(message, trim)
	return message
}

func CloseRows(rows pgx.Rows) {
	rows.Close()
}
