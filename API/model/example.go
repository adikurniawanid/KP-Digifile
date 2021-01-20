package model

import (
	"template-api-gecho/config"
	"template-api-gecho/entity"
)

type ExampleModel struct {
	db config.Database
}

// Get Example Post
func (ExampleModel ExampleModel) GetPosts(secret string) []entity.ExampleEntity {
	posts := []entity.ExampleEntity{
		{
			Title:       "NewsOne",
			Description: "NewsOneDescription",
		},
		{
			Title:       "NewsTwo",
			Description: "NewsTwoDescription",
		},
		{
			Title:       secret,
			Description: "NewsTwoDescription",
		},
	}

	return posts
}

// // createTodo add a new todo
// func createTodo(c *gin.Context) {
// 	completed, _ := strconv.Atoi(c.PostForm("completed"))
// 	todo := todoModel{Title: c.PostForm("title"), Completed: completed}
// 	db.Save(&todo)
// 	c.JSON(http.StatusCreated, gin.H{"status": http.StatusCreated, "message": "Todo item created successfully!", "resourceId": todo.ID})
// }

// // fetchAllTodo fetch all todos
// func fetchAllTodo(c *gin.Context) {
// 	var todos []todoModel
// 	var _todos []transformedTodo

// 	db.Find(&todos)

// 	if len(todos) <= 0 {
// 		c.JSON(http.StatusNotFound, gin.H{"status": http.StatusNotFound, "message": "No todo found!"})
// 		return
// 	}

// 	//transforms the todos for building a good response
// 	for _, item := range todos {
// 		completed := false
// 		if item.Completed == 1 {
// 			completed = true
// 		} else {
// 			completed = false
// 		}
// 		_todos = append(_todos, transformedTodo{ID: item.ID, Title: item.Title, Completed: completed})
// 	}
// 	c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "data": _todos})
// }

// // fetchSingleTodo fetch a single todo
// func fetchSingleTodo(c *gin.Context) {
// 	var todo todoModel
// 	todoID := c.Param("id")

// 	db.First(&todo, todoID)

// 	if todo.ID == 0 {
// 		c.JSON(http.StatusNotFound, gin.H{"status": http.StatusNotFound, "message": "No todo found!"})
// 		return
// 	}

// 	completed := false
// 	if todo.Completed == 1 {
// 		completed = true
// 	} else {
// 		completed = false
// 	}

// 	_todo := transformedTodo{ID: todo.ID, Title: todo.Title, Completed: completed}
// 	c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "data": _todo})
// }

// // updateTodo update a todo
// func updateTodo(c *gin.Context) {
// 	var todo todoModel
// 	todoID := c.Param("id")

// 	db.First(&todo, todoID)

// 	if todo.ID == 0 {
// 		c.JSON(http.StatusNotFound, gin.H{"status": http.StatusNotFound, "message": "No todo found!"})
// 		return
// 	}

// 	db.Model(&todo).Update("title", c.PostForm("title"))
// 	completed, _ := strconv.Atoi(c.PostForm("completed"))
// 	db.Model(&todo).Update("completed", completed)
// 	c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "message": "Todo updated successfully!"})
// }

// // deleteTodo remove a todo
// func deleteTodo(c *gin.Context) {
// 	var todo todoModel
// 	todoID := c.Param("id")

// 	db.First(&todo, todoID)

// 	if todo.ID == 0 {
// 		c.JSON(http.StatusNotFound, gin.H{"status": http.StatusNotFound, "message": "No todo found!"})
// 		return
// 	}

// 	db.Delete(&todo)
// 	c.JSON(http.StatusOK, gin.H{"status": http.StatusOK, "message": "Todo deleted successfully!"})
// }

// Example For Insert Update and Delete
// Get Example Post
//func (UserModel UserModel) IsEmailOrNoTelponExist(identity string) (bool, error) {
//	sqlStatement := "SELECT is_email_no_telp_exist($1)"
//	isExist := false
//
//	err := UserModel.db.GetDatabase().QueryRow(context.Background(),
//		sqlStatement,
//		identity,
//	).Scan(&isExist)
//
//	if err != nil {
//		utils.LogError(err, utils.DetailFunction())
//	}
//
//	return isExist, err
//}

// Example For Get From DB
//func (UserModel UserModel) GetUserBussinessTypesByUserID(userID string) (entity.BussinessTypeList, error) {
//	sqlStatement := "SELECT * FROM get_jenis_usaha($1)"
//
//	bisnisTypeList := entity.BussinessTypeList{}
//	res, err := UserModel.db.GetDatabase().Query(context.Background(),
//		sqlStatement,
//		userID,
//	)
//
//	defer utils.ResClose(res)
//
//	if err != nil {
//		utils.LogError(err, utils.DetailFunction())
//		return bisnisTypeList, err
//	}
//
//	for res.Next() {
//		tipeBisnis := entity.BussinessType{}
//		err := res.Scan(
//			&tipeBisnis.UserBussinessTypeID,
//			&tipeBisnis.UserBussinessType,
//		)
//		// Exit if we get an error
//		if err != nil {
//			utils.LogError(err, utils.DetailFunction())
//			return bisnisTypeList, err
//		}
//		bisnisTypeList.BussinessType = append(bisnisTypeList.BussinessType, tipeBisnis)
//	}
//
//	return bisnisTypeList, nil
//}
