package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	errChan := make(chan error)

	http.HandleFunc("/test", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("test"))
	})

	if err := http.ListenAndServe("0.0.0.0:9000", nil); err != nil {
		errChan <- err
	}

	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGTERM, syscall.SIGQUIT)

	fmt.Println("httpserver is up")

	select {
	case err := <-errChan:
		panic(err)
	case sig := <-sigChan:
		switch sig {
		case syscall.SIGTERM, syscall.SIGQUIT:
			break
		}
	}
}
