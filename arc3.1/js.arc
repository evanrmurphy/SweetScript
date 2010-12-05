; Arcscript | arc2js | Jarcscript
; thanks to garply for the name ArcScript (http://arclanguage.org/item?id=12166)

; TODO
; improve get and fncall/objref/listcall situation
; watch http://www.quirksmode.org/compatibility.html
; string escaping
;  using single quotes here and double in HTML. just that covers considerable nesting!
; warn if using invalid symbol, valid in arc but not js
; optional parameters on functions (done?)
; implement 'expand= etc. for more robust '=?
; could quote be a function defined in js?
; use aw's {} syntax for tables?
; symbols that can't be used in Javascript identifiers (+, -, *, /, etc.) are extra ssyntax possibilites
; are arrays isomorphic to always-proper (or always-improper) lists? keep in mind the boolean value of an empty array

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

; works for quoting lists but not expressions
;  because '(fn (x) x) => list(fn,x(),x);
;                      instead of
;                      => 'function(x){return x;}'
(def js-quote (x)
  (if ;acons.x 
      ; (js1/s `(list ,@x))
      (number x)
       (pr x)
      (js-w/qs (js1/s x))))

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
  (pr #\()
  (between a args (pr op)
    (js1/s a))
  (pr #\)))

(def js-obj args
  (pr #\{)
  (between 2a (pair args) (pr #\,)
    (js1/s (car 2a))
    (pr #\:)
    (js1/s (cadr 2a)))
  (pr #\}))

(def js-array args
  (pr #\[)
  (between a args (pr #\,)
    (js1/s a))
  (pr #\]))

(def js-objref (h k)
  (js1/s h)
  (pr #\[)
  (js1/s k)
  (pr #\]))

(def arglist (xs)
  (pr #\()
  (between x xs (pr #\,)
    (js1/s x)) 
  (pr #\)))

(def js-fncall (f . args)
  (js1/s f)
  (arglist args))

; x!y => (x 'y) => (fncall x 'y)
; x.`y => (x `y) => (objref x 'y)

(def js-call1 (x arg)
  (if (and (acons arg) (is (car arg) 'quasiquote)) 
      (js-objref x (cons 'quote (cdr arg)))
      (js-fncall x arg)))

(def js-call (x . arg/s)
  (if (single arg/s)
      (apply js-call1 x arg/s)
      (apply js-fncall x arg/s)))

(def js-new (C . args)
  (pr "new ")
  (js1/s `(,C ,@args)))

(def js-typeof args
  (pr "typeof ")
  (each a args
    (js1/s a)))

(def retblock (stmts)
  (pr #\{)
  (on s stmts
    (if (is index (- (len stmts) 1))
        (pr "return "))
    (js1/s s)
    (pr #\;))
  (pr #\}))

(def optional1 (x)
  (caris x 'o))

; incorrect or just ugly?
; name conflictions with optional in fromjson

(def optional (x)
  (if (atom x)
      nil
      (or (optional1 (car x)) (optional (cdr x)))))

; couldn't use var= for optional parms: "Unexpected token var"
; ok to use assign instead of var=? should still have fn scope...
; something wrong with optional parms?
; no destructuring bind

(def js-fn (args . body)
  (pr #\( "function")
  (if (no args)
      (do (arglist nil)
          (retblock body))
      (atom args)                       ; lone rest parm
      (do (arglist nil)
          (retblock
            (cons `(var= ,args (arraylist arguments))
                  body)))
      (optional args)
      (do (arglist
            (accum acc
              (each a args
                (if (optional1 a)
                    (acc (cadr a))
                    (acc a)))))
          (retblock
            (accum a
              (each o (nthcdr (pos optional1 args) args)
                (a `(unless ,(cadr o)
                      (assign ,(cadr o) ,(cadr:cdr o)))))
              (apply a body))))
      (dotted args)                     ; dotted rest parm
      (let args1 (nil-terminate args)
        (arglist (butlast args1))
        (retblock
          (cons `(var= ,(last args1)
                       (nthcdr ,(- (len args1) 1) (arraylist arguments)))
                body)))
      (do (arglist args)
          (retblock body)))
  (pr #\)))

(def js-if args
  (pr #\()
  (js1/s (car args))
  (each 2a (pair (cdr args))
    (pr #\?)
    (js1/s (car 2a))
    (pr #\:)
    ;(pr:js1/s cadr.2a) ; why or/when fails?
    (js1/s (cadr 2a)))
  (pr #\)))

(def js-assign (var val)
  (js1/s var)
  (pr #\=)
  (js1/s val))

(def js-var= (var val)
  (pr "var ")
  (js1/s var)
  (pr #\=)
  (js1/s val))

(def doblock (stmts)
  (pr #\{)
  (on s stmts
    (js1/s s)
    (pr #\;))
  (pr #\}))

(def js-for (v init end step . body)
  (pr "for" #\()
  (js `(var= ,v ,init)
      `(isnt ,v ,end))
  (js1/s step)                      ; separate bc can't have semicolon
  (pr #\))
  (doblock body))

(def js-forin (v h . body)
  (pr "for" #\()
  (js1/s v)
  (pr " in ")
  (js1/s h)
  (pr #\))
  (doblock body))

(def js1 (s)
  (if (caris s 'quote)        (apply js-quote (cdr s))
      (or (isa s 'char)  
          (isa s 'string))    (js-str/charesc s) 
          (atom s)               (pr s)
          (in (car s) '+ '-   
              '* '/ '>= '<=     
              '> '< '% '===     
              '&& '\|\| '\.)   (apply js-infix s)
          (caris s 'car)       (apply js-car (cdr s))
          (caris s 'cdr)       (apply js-cdr (cdr s))
          (caris s 'obj)       (apply js-obj (cdr s))
          (caris s 'array)     (apply js-array (cdr s))
          (caris s 'objref)    (apply js-objref (cdr s))
          (caris s 'fncall)    (apply js-fncall (cdr s))
          (caris s 'listref)   (apply js-listref (cdr s))
          (caris s 'new)       (apply js-new (cdr s))
          (caris s 'typeof)    (apply js-typeof (cdr s))
          (caris s 'if)        (apply js-if (cdr s))
          (caris s 'fn)        (apply js-fn (cdr s))
          (caris s 'assign)    (apply js-assign (cdr s))
          (caris s 'var=)      (apply js-var= (cdr s))
          (caris s 'jsfor)     (apply js-for (cdr s))
          (caris s 'jsforin)   (apply js-forin (cdr s))
          (js-macs* (car s))     (apply (js-macs* (car s)) (cdr s))
          (apply js-call s)))

; thanks, fallintothis (http://arclanguage.org/item?id=12100)
; consider improving based on http://arclanguage.org/item?id=12165

(def ssexpand-all (expr)
  (if (ssyntax expr)
       (let expanded (ssexpand expr)
         (if (is expanded expr)
             expr
             (ssexpand-all expanded)))
      (atom expr)
       expr
      (is (car expr) 'quote)
       (if (caris (cadr expr) 'unquote)
           (list 'quote (ssexpand-all (cadr expr)))
           expr)
      (cons (ssexpand-all (car expr))
            (ssexpand-all (cdr expr)))))

(def js1/s args
  (between a (ssexpand-all args) (pr #\;)
    (js1 a)))

(def js args
  (apply js1/s args)
  (pr #\;))



