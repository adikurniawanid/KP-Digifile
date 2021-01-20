package responsegraph

type ResponseGenericGet struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

type ResponseGenericIn struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
}

type ResponseValidation struct {
	Status  string      `json:"status"`
	Message bool        `json:"message"`
	Data    interface{} `json:"data"`
}

type ResponseBytes struct {
	Status  string      `json:"status"`
	Message []byte      `json:"message"`
	Data    interface{} `json:"data"`
}

type ResponseArrayMultiType struct {
	Status  string        `json:"status"`
	Message string        `json:"message"`
	Data    []interface{} `json:"data"`
}

type Data struct {
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    int    `json:"data"`
}
