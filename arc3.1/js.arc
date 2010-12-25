; Arcscript | arc2js | Jarcscript
; thanks to garply for the name ArcScript (http://arclanguage.org/item?id=12166)

; NOTES:
; changing reader and ssyntax for dot broke rest params
; in javascript, parameters are optional by default
;  rest params and keyword params are tricky though
;  (use the arguments array in javascript)
; warn if using invalid symbol, valid in arc but not js
; string escaping

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

(def js-dot1 (h k)
  (js1/s h)
  (pr #\.)
  (js1/s k))

(def js-dot args
  (between a args (pr #\.)
    (js1/s a)))

(def js-ref1 (h k)
  (js1/s h)
  (pr #\[)
  (js1/s k)
  (pr #\]))

(def js-ref args
  (js1/s (car args))
  (each a (cdr args)
    (pr #\[)
    (js1/s a)
    (pr #\])))

(def arglist (xs)
  (pr #\()
  (between x xs (pr #\,)
    (js1/s x)) 
  (pr #\)))

(def js-fncall (f . args)
  (js1/s f)
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

;(def js-dotted (x)
;  (if (atom x)
;       nil
;      (is (car x) '\.)
;       t
;      (and (cdr x) (or (atom (cdr x))
;                       (js-dotted (cdr x))))))

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
      ;(js-dotted args)                  ; dotted rest parm
      ; (let args1 (nil-terminate args)
      ;   (arglist (butlast args1))
      ;   (retblock
      ;     (cons `(var= ,(last args1)
      ;                  (nthcdr ,(- (len args1) 1) (arraylist arguments)))
      ;           body)))
      (do (arglist args)
          (retblock body)))
  (pr #\)))

(def js-ternary (c t e)
  (pr #\()
  (js1/s c)
  (pr #\?)
  (js1/s t)
  (pr #\:)
  (js1/s e)
  (pr #\)))

(def js-if args
  (pr #\()
  (js1/s (car args))
  (each 2a (pair (cdr args))
    (pr #\?)
    (js1/s (car 2a))
    (pr #\:)
    (js1/s (cadr 2a)))
  (pr #\)))

(def js-assign (var val)
  (js1/s var)
  (pr #\=)
  (js1/s val))

(def js-= args
  (between 2a (pair args) (pr #\,)
    (js1/s (car 2a))
    (pr #\=)
    (js1/s (cadr 2a))))

(def js-var vars
  (pr "var ")
  (between var vars (pr #\,)
    (js1/s var)))

(def js-var=1 (var val)
  (pr "var ")
  (js1/s var)
  (pr #\=)
  (js1/s val))

(def js-var= args
  (pr "var ")
  (between 2a (pair args) (pr #\,)
    (js1/s (car 2a))
    (pr #\=)
    (js1/s (cadr 2a))))

(def block (stmts)
  (pr #\{)
  (on s stmts
    (js1/s s)
    (pr #\;))
  (pr #\}))

(def js-do0 stmts
  (between s stmts (pr #\;)
    (js1/s s)))

(def js-for (v init end step . body)
  (pr "for" #\()
  (js `(var= ,v ,init)
      `(isnt ,v ,end))
  (js1/s step)                      ; separate because can't have semicolon
  (pr #\))
  (block body))

(def js-for-in (v h . body)
  (pr "for" #\()
  (js1/s v)
  (pr " in ")
  (js1/s h)
  (pr #\))
  (block body))

(def js1 (s)
  (if (caris s 'quote)        (apply js-quote (cdr s))
      (or (isa s 'char)  
          (isa s 'string))    (js-str/charesc s) 
      (atom s)               (pr s)
      (in (car s) '+ '-   
          '* '/ '>= '<=     
          '> '< '% '==
          '=== '!= '!==
          '&& '\|\| '\.)   (apply js-infix s)
      (caris s '{})        (apply js-obj (cdr s))
      (caris s '[])        (apply js-array (cdr s))
      (caris s 'dot)       (apply js-dot (cdr s))
      (caris s 'ref)       (apply js-ref (cdr s))
      (caris s 'fncall)    (apply js-fncall (cdr s))
      (caris s 'new)       (apply js-new (cdr s))
      (caris s 'typeof)    (apply js-typeof (cdr s))
      (caris s 'do0)       (apply js-do0 (cdr s))
      (caris s '?:)        (apply js-ternary (cdr s))
      (caris s 'if)        (apply js-if (cdr s))
      (caris s 'fn)        (apply js-fn (cdr s))
      (caris s '=)         (apply js-= (cdr s))
      (caris s 'var)       (apply js-var (cdr s))
      (caris s 'var=)      (apply js-var= (cdr s))
      (caris s 'for)       (apply js-for (cdr s))
      (caris s 'for-in)    (apply js-for-in (cdr s))
      (js-macs* (car s))   (apply (js-macs* (car s)) (cdr s))
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

;(def js1/s args
;  (between a (ssexpand-all args) (pr #\;)
;    (js1 a)))

; the no ssyntax version

(def js1/s args
  (between a args (pr #\;)
    (js1 a)))

(def js args
  (apply js1/s args)
  (prn #\;))

; macros

(= js-macs* (table))

(mac js-mac (name args . body)
  `(= (js-macs* ',name) (fn ,args (js1/s ,@body))))

(js-mac string args
  `(+ "" ,@args))

; let, various versions

(js-mac let (var val . body)
  `((fn (,var)
      ,@body)
    ,val))

; (js-mac let (var val . body)
;   `(\. (fn (,var)
;          ,@body)
;        (call this ,val)))

(js-mac let (var val . body)
  `(\. (fn ()
         (var= ,var ,val)
         ,@body)
       (call this)))

; mangles variables instead of calling
;  functions
; great for stack but not nestable yet
; uses uniqs now, should do s/x/_x/g
; see http://arclanguage.org/item?id=12952

(js-mac let! (var val . body)
  (w/uniq gvar
    `(do0
       (var= ,gvar ,val)
       ,@(tree-subst var gvar body))))

(js-mac with (parms . body)
  `(\. (fn ()
         (var= ,@parms)
         ,@body)
       (call this)))
