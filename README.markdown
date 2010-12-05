# SweetScript

A Lispy language that compiles into JavaScript, strongly influenced by Arc.

## Overview

*Basic SweetScript using s-expressions.*

    ; Assignment:
    (= number 42)
    (= opposite true)

    ; Conditions:
    (if opposite
      (= number -42))

    ; Arc-style if for complex conditions)
    (if a b
          c d
            e)

    ; Possibly have ternary operator as an alias
    ; for if (though not necessary since we're
    ; breaking down the expression-statement
    ; dichotomy)
    
    (?: a b
          c d
            e)
    
    ; Functions:
    (= square (function (x) (* x x)))
    (var= square (function (x) (* x x)))

    ; Possible convenience utilities for
    ; defining functions:
    (def square (x) (* x x))
    (function= square (x) (* x x))
    
    ; Arrays:
    (= list ([ 1 2 3 4 5)
    
    ; Objects:
    (= math
      ({root   (. Math sqrt)
        square square
        cube   (function (x)
                (* x (square x)))))

    ; (`[` and `{` are clever convenience functions
    ; to make things look a bit more javascripty)

    ; jQuery:
    (. ($ "body") (css "background-color" "red"))

## Member access

Works similar to Clojure's `..` special form:

    (. object member member-of-member ...)

    (. animal dog bark mute)

    (. ($ "#animal")
       (addClass "mammal")
       (toggle))
