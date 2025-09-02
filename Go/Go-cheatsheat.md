## Cheatsheat
### Build & Run
    go run hello.go
    > hello

    go build hello.go
    ./hello
    > hello

### Strings & Escape values
    "this is string" use double quotes for string
    'q' string rune uses single quote and output unicodechar code

    \n  A newline character
    \t  A tab character
    \"  Double quotation marks
    \\  A backslash

Exportattava muuttuja tai funktio alkaa isolla kirjamella

    var Customer string = John" //Exported variable can be used also outside of package

    var customer string = "Jane" //unexported variable can be used only in package
    
