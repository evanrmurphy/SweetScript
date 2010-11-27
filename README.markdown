# SweetScript

A Lisp-like language that compiles into JavaScript. It comes with [sweet-expressions](http://www.dwheeler.com/readable/) for programming with more conventional-looking syntax, and brings macros to JavaScript. (Note: the use of sweet-expressions doesn't conform strictly to Wheeler's spec.)

## Overview

*Basic SweetScript using s-expressions.*

    ; Assignment:
    (= number 42)
    (= opposite true)

    ; Conditions:
    (if opposite
      (= number -42))
    
    ; Functions:
    (= square (function (x) (* x x)))
    
    ; Arrays:
    (= list [1 2 3 4 5])
    
    ; Objects:
    (= math
      {root   (. Math sqrt)
       square square
       cube   (function (x)
                (* x (square x)))})

    ; jQuery:
    (. ($ "body") (css "background-color" "red"))

*SweetScript with mild use of sweet-expressions.*

    ; Assignment:
    = number 42
    = opposite true

    ; Conditions:
    if opposite
      = number -42
    
    ; Functions:
    = square
      function (x) (* x x)
    
    ; Arrays:
    = list [1 2 3 4 5]
    
    ; Objects:
    = math
      {root (. Math sqrt)
       square square
       cube   function(x)
                * x square(x)}

    ; jQuery:
    . $("body") css("background-color" "red")

*Totally sweet SweetScript.*

    ; Assignment:
    = number 42
    = opposite true

    ; Conditions:
    if opposite
      = number -42
    
    ; Functions:
    = square
      function (x) (* x x)
    
    ; Arrays:
    = list [1 2 3 4 5]
    
    ; Objects:
    = math
      {root   Math.sqrt
       square square
       cube   function(x)
                * x square(x)}

    ; jQuery:
    $("body").css("background-color" "red")

We'll get there...
