package utils

import "template-api-gecho/responsegraph"

func GetResData(status string, message string, data interface{}) responsegraph.ResponseGenericGet {
	res := responsegraph.ResponseGenericGet{
		Status:  status,
		Message: message,
		Data:    data,
	}
	return res
}

func GetResNoData(status string, message string) responsegraph.ResponseGenericIn {
	res := responsegraph.ResponseGenericIn{
		Status:  status,
		Message: message,
	}
	return res
}
