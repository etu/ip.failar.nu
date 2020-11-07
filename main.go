package main // import "github.com/etu/ip.failar.nu"

import (
	"flag"
	"fmt"
	"log"
	"net"
	"net/http"

	"github.com/gorilla/mux"
)

func main() {
	var port uint

	flag.UintVar(&port, "port", 8123, "Port to listen to")
	flag.Parse()

	router := NewRouter()
	log.Fatal(http.ListenAndServe(fmt.Sprintf(":%d", port), router))
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
