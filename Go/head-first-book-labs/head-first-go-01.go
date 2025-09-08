package main

import "fmt"
import (
	"math"
	"reflect"
	"strings"
)

var outerLimit int = 42

func main() {
	var quantity int
	var length, width float64 //declare several same type vars at once
	var customerName string
	var otherCustomer string = "Dale"
	var thirdCustomer = "John"
	fourthCustomer := "Mary" //works only in function

	quantity = 2
	length, width = 1.2, 2.1
	customerName = "Damon Cole"

	fmt.Println("Hello Go")
	fmt.Println(math.Floor(2.75))
	fmt.Println(strings.Title("head first go"))

	fmt.Println(reflect.TypeOf(true))
	fmt.Println(reflect.TypeOf(1))
	fmt.Println(reflect.TypeOf(1.1))
	fmt.Println(reflect.TypeOf("bool"))

	fmt.Println(customerName, ", ", otherCustomer, "and", thirdCustomer)
	fmt.Println("Ordered", quantity, "pieces of", width*length, "m2 sized thing..")
	fmt.Println(fourthCustomer, "paid order.")
	fmt.Println(outerLimit)

	//convert int to float
	fmt.Println(width + float64(quantity))

}
