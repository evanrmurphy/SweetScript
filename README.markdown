# SweetScript

A Lisp-like language that compiles into JavaScript. It comes with [sweet-expressions](http://www.dwheeler.com/readable/) for programming with more conventional-looking syntax, and brings the power of macros to JavaScript.

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
      {root   Math.sqrt
       square square
       cube   (function(x)
                (* x (square x)))})

*SweetScript making use of sweet-expressions.*

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
       cube   (function(x)
                (* x (square x)))}
