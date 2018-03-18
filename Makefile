GOPATH=`pwd`/vendor

build:
	env CGO_ENABLED=0 GOPATH=$(GOPATH) go build -o ip-failar-nu

