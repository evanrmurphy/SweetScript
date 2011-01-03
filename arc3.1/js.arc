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
    (pr #\')) 

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

(mac def (name parms . body)
  `(= ,name (fn ,parms ,@body)))

; Start of haml-like html templating
; system. Right now just takes html tags
; with no attributes, e.g.
;
; sweet> (haml
; 
;        (html
;          (body
;            (ul
;              (li (input))))))
; ('<'+'html'+'>'+('<'+'body'+'>'+('<'+'ul'+'>'+('<'+'li'+'>'+('<'+'input'+'>'+''+'</'+'input'+'>')+'</'+'li'+'>')+'</'+'ul'+'>')+'</'+'body'+'>')+'</'+'html'+'>');

(mac haml (expr)
  `(+ "<" ',(car expr) ">"
      ,(if (cdr expr)
           `(haml ,@(cdr expr))
           "")
      "</" ',(car expr) ">"))

)) 
