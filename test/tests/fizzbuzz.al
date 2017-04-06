// this is an external declaration of C's printf() function
proc fizz_buzz(n: int) -> void = {

    proc printf(fmt: const char[]) -> void

    if(n > 0){
        fizz_buzz(n - 1)
    }
    if(n < 0){
        return;
    }
    if(n % 5){
        printf("Fizz")
    }
    if(n % 3){
        printf("Buzz")
    }
}

proc main = {
    fizz_buzz(100)
    0
}