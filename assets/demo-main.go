package main

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

// func handler(w http.ResponseWriter, r *http.Request) {
// 	fmt.Fprintf(w, "Hello, World! This is my first Go web server.")
// }

func helloWordHandler(ctx *gin.Context) {
	ctx.String(http.StatusOK, "Hello, World! This is my first Go web server usin gin.")
}

func main() {
	// http.HandleFunc("/", handler)
	// fmt.Println("Server started on port :8080")
	// log.Fatal(http.ListenAndServe(":8080", nil))

	router := gin.Default()
	router.GET("/", helloWordHandler)

	log.Println("Server started on port :8080")

	if err := router.Run(":8080"); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}
