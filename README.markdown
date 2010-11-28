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

    $("body").css("background-color" "red").toggle()

We'll get there...

## Member access

Works similar to Clojure's dot special form:

    (. object member)
    
Unfortunately, prefix notation for the dot operator could seem strange to the JavaScript programmer, and it quickly becomes awkward when chaining:

    (. (. (. animal dog) bark) mute)

Lisps typically permit . as a valid character in symbols (is this true? does arc?), though JavaScript doesn't. If we disallow the . in SweetScript symbols, we ensure that variable names will stay more consistent across compilation to JavaScript, and also have the possibility for using an infix dot operator. We do this by expanding infix dot operators to the prefix form from left to right in the order that they appear:

    animal.dog.bark.mute
    => (. animal dog).bark.mute 
    => (. (. animal dog) bark).mute 
    => (. (. (. animal dog) bark) mute)

## Familiarity whitespace characters

Following Clojure, the comma ',' can be a whitespace character to help programmers familiar with using it in their code. By treating the colon ':' in the same way, SweetScript object literals can be written exactly as they are in JavaScript:

    {apple: "a fruit", banana: "another fruit"}
    {apple "a fruit" banana "another fruit"}     ; They can also be written in a lispier fashion

## Macros



