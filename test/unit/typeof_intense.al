proc bet -> typeof(0) = 0
proc foo -> typeof(bet) = bet
proc bar -> typeof(foo()()) = foo()()

proc main = {
    let y = bar
    let k = y()
    0
}
