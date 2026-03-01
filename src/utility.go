package main

import (
	"fmt"
	"path"
	"runtime"
	"strings"
)

func GetFunctionName(skip int) string {
	pc, _, _, _ := runtime.Caller(skip)
	// strip module name from the function name
	funcName := strings.TrimPrefix(runtime.FuncForPC(pc).Name(), GetModuleName())
	return fmt.Sprintf("%s", funcName)
}

func GetLineNumber(skip int) string {
	_, _, line, _ := runtime.Caller(skip)
	return fmt.Sprintf("%v", line)
}
func ParentDirectoryOfThisFile() string {
	_, file, _, _ := runtime.Caller(1)
	return path.Dir(file)
}

func GetModuleName() string {
	// the last / at the end actually not a part of the module name but
	// I've put it there so that GetFunctionName above can return function name without it
	return "github.com/srumut/ecommerce/"
}

func DetailedError(err error) error {
	return fmt.Errorf("%v:%v -> %w", GetFunctionName(2), GetLineNumber(2), err)
}
