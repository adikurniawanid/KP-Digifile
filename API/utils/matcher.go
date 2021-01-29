package utils

import "regexp"

func IsPhoneNumber(s string) (bool, error) {
	matched, err := regexp.Match(`[+][0-9]{2}[0-9]{10,}`, []byte(s))
	if err != nil {
		LogError(err)
		return matched, err
	}
	return matched, nil
}

func IsEmailFormat(s string) (bool, error) {
	matched, err := regexp.Match(`^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$`, []byte(s))
	if err != nil {
		LogError(err)
		return matched, err
	}
	return matched, nil
}
