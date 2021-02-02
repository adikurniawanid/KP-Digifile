package controller

import (
	"crypto/sha256"
	"encoding/base64"
)

func Hash_256(input string) string {
	hasher := sha256.New()
	hasher.Write([]byte(input))
	sha := base64.URLEncoding.EncodeToString(hasher.Sum(nil))
	return sha
}
