package main // import "github.com/etu/ip.failar.nu"

import (
	"github.com/gorilla/mux"
	"log"
	"net"
	"net/http"
)

func main() {
	router := NewRouter()

	log.Fatal(http.ListenAndServe(":8123", router))
}

func NewRouter() *mux.Router {
	router := mux.NewRouter().StrictSlash(true)

	router.HandleFunc("/", RootHandler)

	return router
}

func RootHandler(w http.ResponseWriter, r *http.Request) {
	var ip string
	addr := r.RemoteAddr

	if proxy := r.Header.Get("x-forwarded-for"); proxy != "" {
		ip = proxy
	} else {
		ip, _, _ = net.SplitHostPort(addr)
	}

	w.Write([]byte(ip))
	w.Write([]byte("\n"))
}
