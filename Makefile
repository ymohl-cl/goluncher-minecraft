BINARY=golauncher-minecraft
APP=launcher
BIN_FOLDER=bin
IGNORED_FOLDER=.ignore
MODULE_NAME := $(shell go list -m)
CONFIG_FILE=config.json
COVERAGE_FILE=coverage.txt

all: install lint test build

.PHONY: install
install:
	@go mod download
	@go get github.com/golang/mock/mockgen@v1.5.0
	@go get -u golang.org/x/lint/golint

.PHONY: build
build:
	@CGO_ENABLED=1 go build -tags static -ldflags "-s -w" -o ${BIN_FOLDER}/${BINARY} ${MODULE_NAME}/cmd/${APP}

.PHONY: ci-build
ci-build:
	@CGO_ENABLED=1 CC=x86_64-apple-darwin20.2-clang GOOS=darwin GOARCH=amd64 go build -tags static -ldflags "-s -w" -o ${BIN_FOLDER}/${BINARY}.app ${MODULE_NAME}/cmd/${APP}
	@echo binary-darwin built !
	@CGO_ENABLED=1 CC=x86_64-w64-mingw32-gcc GOOS=windows GOARCH=amd64 go build -tags static -ldflags "-s -w" -o ${BIN_FOLDER}/${BINARY}.exe ${MODULE_NAME}/cmd/${APP}
	@echo binary-windows built !
	@CGO_ENABLED=1 CC=clang GOOS=linux GOARCH=amd64 go build -tags static -ldflags "-s -w" -o ${BIN_FOLDER}/${BINARY} ${MODULE_NAME}/cmd/${APP}
	@echo binary-linux built !

.PHONY: test
test:
	@mkdir -p ${IGNORED_FOLDER}
	@go test -count=1 -race -coverprofile=${IGNORED_FOLDER}/${COVERAGE_FILE} -covermode=atomic ./...

.PHONY: covefile
	@go echo ${IGNORED_FOLDER}/${COVERAGE_FILE}

.PHONY: lint
lint:
	@golint -set_exit_status ./...

.PHONY: tools
tools:
	@go get -u golang.org/x/lint/golint

.PHONY: mock
mock:

.PHONY: clean
clean:
	@rm -rf ${IGNORED_FOLDER} 

.PHONY: fclean
fclean: clean
	@rm -rf ${BIN_FOLDER}
