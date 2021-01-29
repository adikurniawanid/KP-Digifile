package responsegraph

type ResponseGenericGet struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
	Id      []int       `json:"id"`
}
type Getbool struct {
	Status string `json:"status"`
	Data   bool   `json:"data"`
}
type ResponseGenericGet2 struct {
	Status  string      `json:"status"`
	Message string      `json:"message"`
	Data    interface{} `json:"data"`
	Data1   interface{} `json:"data1"`
	Id      []int       `json:"id"`
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
	Status  string        `json:"status"`
	Message string        `json:"message"`
	Data    int           `json:"data"`
	Data1   []interface{} `json:"data1"`
}

type Items struct {
	Status   string   `json:"status"`
	Message  string   `json:"message"`
	Data     []string `json:"data"`
	File     int      `json:"file"`
	Ekstensi []string `json:"ekstensi"`
	Id       []int    `json:"id"`
}

type Name struct {
	Status  string `json:"status"`
	Message string `json:"message"`
	Data    string `json:"data"`
}
