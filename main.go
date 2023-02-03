package main

import (
	"fmt"
	"net/http"
	"time"
	
	"github.com/gin-gonic/gin"
)

func main() {
	
	engine := gin.New()
	
	engine.Use(gin.Logger())
	engine.Use(gin.Recovery())
	
	api := engine.Group("/api/mini")
	
	api.GET("hello", func(c *gin.Context) {
		c.JSON(http.StatusOK, "hello world")
	})
	
	s := &http.Server{
		Addr:           fmt.Sprintf(":%s", "7716"),
		Handler:        engine,
		ReadTimeout:    time.Second * 30,
		WriteTimeout:   time.Second * 30,
		MaxHeaderBytes: 1 << 20,
	}
	s.ListenAndServe()
}
