**SweetScript has become [LavaScript](https://github.com/evanrmurphy/lava-script).**

# SweetScript

A lispy language that compiles into JavaScript, strongly influenced by Arc.

## Install and Run

SweetScript runs on a modified version of [arc3.1](http://arclanguage.org/item?id=10254). After installing [racket](http://racket-lang.org/download/) (previously called mzscheme):

    git clone git@github.com:evanrmurphy/SweetScript.git
    cd SweetScript/arc3.1
    racket -f as.scm

You should find yourself at the `arc>` prompt. Enter `(sweet)` to use SweetScript:

    arc> (sweet)
    Welcome to SweetScript! Type (sour) to leave.
    sweet> (def hello ()
             (alert "hello world!"))
    hello=(function(){return alert('hello world!');});
    sweet> (sour)
    Bye!
    nil
    arc>
