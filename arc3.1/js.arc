(def butlast (xs)
  (firstn (- (len xs) 1) xs))

; '(a b c d . e) => '(a b c d e)

(def nil-terminate (xs)
  (if (no xs)
      nil
      (and (cdr xs) (atom (cdr xs)))
      (cons (car xs) (cons (cdr xs) nil))
      (cons (car xs) (nil-terminate (cdr xs)))))

(let nest-lev 0

  (def js-q ()
    (repeat nest-lev (pr #\\))
    (pr #\")) 

  (def js-open-q ()
    (js-q)
    (= nest-lev (+ 1 (* 2 nest-lev))))

  (def js-close-q ()
    (= nest-lev (/ (- nest-lev 1) 2))
    (js-q)))

(mac js-w/qs body
  `(do (js-open-q)
       ,@body
       (js-close-q)))

(def js-quote (x)
  (if (acons x) 
       (apply js-array x)
      (number x)
       (pr x)
      (js-w/qs (js1s x))))

(def js-charesc (c)
  (case c #\newline (pr "\\n")
          #\tab     (pr "\\t")
          #\return  (pr "\\r")
          #\\       (pr "\\\\")
          #\'       (js-q)
                    (pr c)))

; an eachif would make conditional unnecessary

(def js-str/charesc (c/s)
  (js-w/qs
    (if (isa c/s 'char)    (js-charesc c/s)
        (isa c/s 'string)  (each c c/s
                             (js-charesc c)))))

(def js-infix (op . args)
  (between a args (pr op)
    (js1s a)))

(def js-infix-w/parens (op . args)
  (pr #\()
  (apply js-infix op args)
  (pr #\)))

(def js-w/commas (xs)
  (apply js-infix #\, xs))

(def js-obj args
  (pr #\{)
  (between (k v) (pair args) (pr #\,)
    (js1s k)
    (pr #\:)
    (js1s v))
  (pr #\}))

(def js-array args
  (pr #\[)
  (js-w/commas args)
  (pr #\]))

(def js-ref args
  (js1s (car args))
  (each a (cdr args)
    (pr #\[)
    (js1s a)
    (pr #\])))

(def arglist (xs)
  (pr #\()
  (js-w/commas xs) 
  (pr #\)))

(def js-fncall (f . args)
  (js1s f)
  (arglist args))

(def js-call1 (x arg)
  (if (and (acons arg) (is (car arg) 'quasiquote)) 
      (js-ref x (cons 'quote (cdr arg)))
      (js-fncall x arg)))

(def js-call (x . arg/s)
  (if (single arg/s)
      (apply js-call1 x arg/s)
      (apply js-fncall x arg/s)))

(def js-new (C . args)
  (pr "new ")
  (js1s `(,C ,@args)))

(def js-typeof args
  (pr "typeof ")
  (each a args
    (js1s a)))

; bad name when everything is an expression

(def retblock (exprs)
  (pr #\{
      "return ")
  (js-w/commas exprs)
  (pr #\; #\}))

(def js-fn (args . body)
  (pr #\( "function")
  (if (no args)
       (do (arglist nil)
           (retblock body))
      (atom args) 
       (do (arglist nil)
           (retblock
             (cons `(= ,args
                       (Array.prototype.slice.call
                         arguments))
                   body)))
      (dotted args)
       (let args1 (nil-terminate args)
         (arglist (butlast args1))
         (retblock
           (cons `(= ,(last args1)
                     (Array.prototype.slice.call
                       arguments
                       ,(- (len args1) 1)))
                 body)))
      (do (arglist args)
          (retblock body)))
  (pr #\)))

(def js-if args
  (pr #\()
  (js1s (car args))
  (each (then else) (pair (cdr args))
    (pr #\?)
    (js1s then)
    (pr #\:)
    (js1s else))
  (pr #\)))

(def js-= args
  (between (var val) (pair args) (pr #\,)
    (js1s var)
    (pr #\=)
    (js1s val)))

(def js-do exprs
  (pr #\()
  (js-w/commas exprs)
  (pr #\)))

(def js-while (test . body)
  (pr "(function(){"
        "while(") (js1s test) (pr "){")
  (apply js-do body)
  (pr   "}"
      "}).call(this)"))

(= js-macs* (table))

(mac js-mac (name args . body)
  `(= (js-macs* ',name) (fn ,args (js1s ,@body))))

(def js1 (s)
  (if (caris s 'quote)     (apply js-quote (cdr s))
      (or (isa s 'char)  
          (isa s 'string)) (js-str/charesc s) 
      (no s)               (pr 'null)  
      (atom s)             (pr s)
      (in (car s) '+ '-   
          '* '/ '>= '<=     
          '> '< '% '==
          '=== '!= '!==
          '+= '-= '*= '/=
          '%= '&& '\|\|
          '\,)             (apply js-infix-w/parens s)
      (or (caris s '\.)
          (caris s '..))   (apply js-infix (cons '|.| (cdr s)))
      (caris s 'list)      (apply js-array (cdr s))
      (caris s 'obj)       (apply js-obj (cdr s))
      (caris s 'ref)       (apply js-ref (cdr s))
      (caris s 'new)       (apply js-new (cdr s))
      (caris s 'typeof)    (apply js-typeof (cdr s))
      (caris s 'do)        (apply js-do (cdr s))
      (caris s 'if)        (apply js-if (cdr s))
      (caris s 'fn)        (apply js-fn (cdr s))
      (caris s '=)         (apply js-= (cdr s))
      (caris s 'while)     (apply js-while (cdr s))
      (caris s 'mac)       (eval `(js-mac ,@(cdr s)))
      (js-macs* (car s))   (apply (js-macs* (car s)) (cdr s))
                           (apply js-call s)))

(def js1s args
  (between a args (pr #\,)
    (js1 a)))

(def js-repl ()
  (pr "sweet> ")
  (let expr (read)
    (if (iso expr '(sour))
         (do (prn "Bye!") nil)
         (do (js expr) (js-repl)))))

(def js args
  (if (no args)
       (do (prn "Welcome to SweetScript! Type (sour) to leave.")
           (js-repl))
       (do (apply js1s args)
           (prn #\;))))

; js alias
(def sweet args (apply js args))

; macros

(js `(do

(mac let (var val . body)
  (w/uniq gvar
    `(do (= ,gvar ,val)
         ,@(tree-subst var gvar body))))

(mac with (parms . body)
  (if (no parms) 
      `(do ,@body)
      `(let ,(car parms) ,(cadr parms) 
         (with ,(cddr parms) ,@body))))

(mac when (test . body)
  `(if ,test (do ,@body)))

(mac unless (test . body)
  `(if (! ,test) (do ,@body)))

(mac until (test . body)
  `(while (! ,test) ,@body))

(mac def (name parms . body)
  `(= ,name (fn ,parms ,@body)))

; html templating system inspired by html.arc
;
; sweet> (tag input (type "text")
;          (tag ul ()
;            (tag li () "apples")
;            (tag li () "bananas")))
; (('<'+'input'+' '+('type'+'='+'\'text\''+' ')+'>')+(('<'+'ul'+'>')+(('<'+'li'+'>')+'apples'+('</'+'li'+'>'))+(('<'+'li'+'>')+'bananas'+('</'+'li'+'>'))+('</'+'ul'+'>'))+('</'+'input'+'>'));

(mac parse-attrs (attrs)
  (let acc nil
    (each (k v) (pair attrs)
      (= acc (+ acc `(',k "=" ',v " "))))
    (push '+ acc)
    acc))

(mac start-tag (spec attrs)
  (if (no attrs)
      `(+ "<" ',spec ">")
      `(+ "<" ',spec " " (parse-attrs ,attrs) ">")))

(mac end-tag (spec)
  `(+ "</" ',spec ">"))

(mac tag (spec attrs . body)
  `(+ (start-tag ,spec ,attrs)
      ,@body
      (end-tag ,spec)))

; jQuery helper macro
;  Example usage: ($ "p.neat"
;                   (addClass "ohmy")
;                   (show "slow"))

(mac $ (selector . args)
  `(.. (jQuery ,selector) ,@args))

; Examples from http://documentcloud.github.com/underscore/#styles

; Collections

(_.each [1 2 3] (fn (x) (alert x)))
(_.each {one 1 two 2 three 3} (fn (x) (alert x)))

(_.map [1 2 3] (fn (x) (* x 3)))
(_.map {one 1 two 2 three 3} (fn (x) (* x 3)))

(= sum (_.reduce [1 2 3] (fn (memo x) (+ memo x)) 0))

(= list [[0 1] [2 3] [4 5]]
   flat (_.reduceRight list (fn (a b) (.. a (concat b))) []))

(= even (_.detect [1 2 3 4 5 6] (fn (x) (== (% x 2) 0))))

; alias select
(= evens (_.filter [1 2 3 4 5 6] (fn (x) (== (% x 2) 0))))

(= odds (_.reject [1 2 3 4 5 6] (fn (x) (== (% x 2) 0))))

(_.all [true 1 null "yes"])

(_.any [true 1 null "yes"])

(_.include [1 2 3] 3)

(_.invoke [[5 1 7] [3 2 1]] "sort")

(let stooges [{name "moe" age 40} {name "larry" age 50}
              {name "curly" age 60}]
  (_.pluck stooges "name"))

(let stooges [{name "moe" age 40} {name "larry" age 50}
              {name "curly" age 60}]
  (_.max stooges (fn (stooge) stooge.age)))

(let numbers [10 5 100 2 1000]
  (_.min numbers))

(_.sortBy [1 2 3 4 5 6] (fn (x) (Math.sin x)))

(_.sortedIndex [10 20 30 40 50] 35)

((fn () (_.toArray arguments (slice 0))) 1 2 3)

(_.size {one 1 two 2 three 3})

; Function (uh, ahem) Functions

(let f (fn (greeting)
         (+ greeting ": " this.name))
  (= f (_.bind f {name "moe"} "hi"))
  (f))

; Example program
; Compiled output goes in static/sweet-example.js, which
; is linked to from static/sweet-example.html
; Depends on underscore.js and jQuery

(do

(= xs [])

(def render ()
  ($ "#xs" (empty))
  (_.each xs (fn (x)
               ($ "#xs" (append (tag div () x))))))

($ (tag input ())
   (change (fn ()
             (xs.unshift ($ this (val)))
             ($ this (val ""))
             (render)))
   (appendTo "body"))

($ (tag div (id "xs"))
   (appendTo "body")))


)) 
