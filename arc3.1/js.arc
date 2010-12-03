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

(def cariso (x val) 
  (and (acons x) (iso (car x) val)))

(mac tosym body
  `(sym:tostring ,@body))

(mac lastcdr (xs (o n 1))
  `(nthcdr (- (len ,xs) n) ,xs))

(def butlast (xs)
  (firstn (- len.xs 1) xs))

; '(a b c d . e) => '(a b c d e)

(def nil-terminate (xs)
  (if no.xs
      nil
      (and cdr.xs (atom cdr.xs))
      (cons car.xs (cons cdr.xs nil))
      (cons car.xs (nil-terminate cdr.xs))))

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
      number.x
       pr.x
      (js-w/qs js1/s.x)))

(def js-charesc (c)
  (case c #\newline (pr "\\n")
          #\tab     (pr "\\t")
          #\return  (pr "\\r")
          #\\       (pr "\\\\")
          #\'       (js-q)
                    pr.c))

; an eachif would make conditional unnecessary

(def js-str/charesc (c/s)
  (js-w/qs
    (if (isa c/s 'char)    (js-charesc c/s)
        (isa c/s 'string)  (each c c/s
                             (js-charesc c)))))

(def js-infix (op . args)
  (pr #\()
  (between a args pr.op
    js1/s.a)
  (pr #\)))

(def js-obj args
  (pr #\{)
  (between 2a pair.args (pr #\,)
    (js1/s car.2a)
    (pr #\:)
    (js1/s cadr.2a))
  (pr #\}))

(def js-array args
  (pr #\[)
  (between a args (pr #\,)
    js1/s.a)
  (pr #\]))

;=== reserved words (currently don't check for them) ===;
;abstract
;boolean break byte
;case catch char class const continue
;debugger default delete do double
;else enum export extends
;false final finally float for function
;goto
;if implements import in instanceof int interface
;long
;native new null
;package private protected public
;return
;short static super switch synchronized
;this throw throws transient true try typeof
;var volatile void
;while with

;(def js-goodname (s)
;  (and (letter s.0)
;       (all [or alphadig (is _ #\_)] s)))
;
;(def js-dotref (h k)
;  js1/s.h
;  (pr #\.)
;  js1/s.k)
;
;(def js-br-ref (h k)
;  js1/s.h
;  (pr #\[)
;  js1/s.k
;  (pr #\]))
;
;(def js-objref (h k)
;  (if (js-goodname (tostring (js1/s cdr.k)))
;      (apply js-dotref h cdr.k)
;      (js-br-ref h k)))

(def js-objref (h k)
  js1/s.h
  (pr #\[)
  js1/s.k
  (pr #\]))

(def arglist (xs)
  (pr #\()
  (between x xs (pr #\,)
    js1/s.x) 
  (pr #\)))

(def js-fncall (f . args)
  js1/s.f
  arglist.args)

; x!y => (x 'y) => (fncall x 'y)
; x.`y => (x `y) => (objref x 'y)

(def js-call1 (x arg)
  (if (and acons.arg (is car.arg 'quasiquote)) 
      (js-objref x (cons 'quote cdr.arg))
      (js-fncall x arg)))

(def js-call (x . arg/s)
  (if single.arg/s
      (apply js-call1 x arg/s)
      (apply js-fncall x arg/s)))

; pseudo-setforms
; should be such that (car undefined) => nil

(def js-car (xs)
  (js-objref xs '(quote car)))

(def js-cdr (xs)
  (js-objref xs '(quote cdr)))

(def js-listref (xs i)
  (pr "car")
  (pr #\()
  (js-fncall 'nthcdr i xs)
  (pr #\)))

(def js-new (C . args)
  (pr "new ")
  (js1/s `(,C ,@args)))

(def js-typeof args
  (pr "typeof ")
  (each a args
    js1/s.a))

(def retblock (stmts)
  (pr #\{)
  (on s stmts
    (if (is index (- len.stmts 1))
        (pr "return "))
    js1/s.s
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
  (if no.args
      (do arglist.nil
          retblock.body)
      atom.args            ; lone rest parm
      (do arglist.nil
          (retblock
            (cons `(var= ,args (arraylist arguments))
                  body)))
      optional.args
      (do (arglist
            (accum acc
              (each a args
                (if optional1.a
                    (acc cadr.a)
                    (acc a)))))
          (retblock
            (accum a
              (each o (nthcdr (pos optional1 args) args)
                (a `(unless ,cadr.o
                      (assign ,cadr.o ,(cadr:cdr o)))))
              (apply a body))))
      dotted.args          ; dotted rest parm
      (let args1 nil-terminate.args
        (arglist butlast.args1)
        (retblock
          (cons `(var= ,(last args1)
                       (nthcdr ,(- len.args1 1) (arraylist arguments)))
                body)))
      (do arglist.args
          retblock.body))
  (pr #\)))

(def js-if args
  (pr #\()
  (js1/s car.args)
  (each 2a (pair cdr.args)
    (pr #\?)
    (js1/s car.2a)
    (pr #\:)
    ;(pr:js1/s cadr.2a) ; why or/when fails?
    (js1/s cadr.2a))
  (pr #\)))

(def js-assign (var val)
  js1/s.var
  (pr #\=)
  js1/s.val)

(def js-var= (var val)
  (pr "var ")
  js1/s.var
  (pr #\=)
  js1/s.val)

(def doblock (stmts)
  (pr #\{)
  (on s stmts
    js1/s.s
    (pr #\;))
  (pr #\}))

(def js-for (v init end step . body)
  (pr "for" #\()
  (js `(var= ,v ,init)
      `(isnt ,v ,end))
  js1/s.step  ; separate bc can't have semicolon
  (pr #\))
  doblock.body)

(def js-forin (v h . body)
  (pr "for" #\()
  js1/s.v
  (pr " in ")
  js1/s.h
  (pr #\))
  doblock.body)

(= js-macs* (table))

; should ssexpand
(mac js-mac (name args . body)
  `(= (js-macs* ',name) (fn ,args (js1/s ,@body))))

(js-mac string args
  `(+ "" ,@args))

; can be def or must be mac?
; prob needs to be mac for function/object distinction
;  else put type checking in get

(js-mac get (arg) `[_ ,arg])

; problem with get: "ReferenceError: Invalid left-hand side in assignment"
; maybe safeassign can help?

(js-mac safeassign (var val)
  (w/uniq temp
   `(let ,temp ,var
      (= ,temp ,val
         ,var ,temp))))

(js-mac def (name args . body)
  `(assign ,name (fn ,args ,@body)))

(js-mac mod args
  `(% ,@args))

(js-mac is args
  `(=== ,@args))

(js-mac do args
  `(((fn () ,@args) `call) this))

(js-mac caar (xs) `(car (car ,xs)))
(js-mac cadr (xs) `(car (cdr ,xs)))
(js-mac cddr (xs) `(cdr (cdr ,xs)))

(js-mac and args
  (if args
      (if (cdr args)
          `(if ,(car args) (and ,@(cdr args)))
          (car args))
      't))

(js-mac with (parms . body)
  `(((fn ,(map1 car (pair parms))
       ,@body)
     `call)
    this ,@(map1 cadr (pair parms))))

(js-mac let (var val . body)
  `(with (,var ,val) ,@body))

(js-mac withs (parms . body)
  (if (no parms) 
      `(do ,@body)
      `(let ,(car parms) ,(cadr parms) 
         (withs ,(cddr parms) ,@body))))

(js-mac rfn (name parms . body)
  `(let ,name nil
     (assign ,name (fn ,parms ,@body))))

(js-mac afn (parms . body)
  `(let self nil
     (assign self (fn ,parms ,@body))))

(js-mac compose args
  (let g (uniq)
    `(fn ,g
       ,((afn (fs)
           (if (cdr fs)
               (list (car fs) (self (cdr fs)))
               `(apply ,(if (car fs) (car fs) 'idfn) ,g)))
         args))))

(js-mac complement (f)
  (let g (uniq)
    `(fn ,g (no (apply ,f ,g)))))

; not working with current js-if

;(js-mac or args
;  (and args
;       (w/uniq g
;         `(let ,g ,(car args)
;            (if ,g ,g (or ,@(cdr args)))))))

(js-mac or args
  `(\|\| ,@args))

(js-mac in (x . choices)
  (w/uniq g
    `(let ,g ,x
       (or ,@(map1 (fn (c) `(is ,g ,c)) choices)))))

(js-mac when (test . body)
  `(if ,test (do ,@body)))

(js-mac unless (test . body)
  `(if (no ,test) (do ,@body)))

(js-mac while (test . body)
  (w/uniq (gf gp)
    `((rfn ,gf (,gp)
        (when ,gp ,@body (,gf ,test)))
      ,test)))

; requires map

;(js-mac defs args
;  `(do ,@(map (fn (_) cons 'def _) (tuples args 3)))) ; [cons 'def _]

(js-mac loop (start test update . body)
  (w/uniq (gfn gparm)
    `(do ,start
         ((rfn ,gfn (,gparm) 
            (if ,gparm
                (do ,@body ,update (,gfn ,test))))
          ,test))))

(js-mac for (v init max . body)
  (w/uniq (gi gm)
    `(with (,v nil ,gi ,init ,gm (+ ,max 1))
       (loop (assign ,v ,gi) (< ,v ,gm) (assign ,v (+ ,v 1))
         ,@body))))

(js-mac down (v init min . body)
  (w/uniq (gi gm)
    `(with (,v nil ,gi ,init ,gm (- ,min 1))
       (loop (assign ,v ,gi) (> ,v ,gm) (assign ,v (- ,v 1))
         ,@body))))

(js-mac repeat (n . body)
  `(for ,(uniq) 1 ,n ,@body))

; doesn't work when var isa cons?

(js-mac each (var expr . body)
  (w/uniq (gseq gf gv)
    `(let ,gseq ,expr
       (if (alist ,gseq)
            ((rfn ,gf (,gv)
               (when (acons ,gv)
                 (let ,var (car ,gv) ,@body)
                 (,gf (cdr ,gv))))
             ,gseq)
           (isa ,gseq 'table)
            (maptable (fn ,var ,@body)
              ,gseq)
           (for ,gv 0 (- (len ,gseq) 1)
             (let ,var (,gseq ,gv) ,@body))))))

; correct for all cases?

(js-mac = args
  `(do ,@(accum a
           (each (var val) pair.args
             (a `(assign ,var ,val))))))


(js-mac between (var expr within . body)
  (w/uniq first
    `(let ,first t
       (each ,var ,expr
         (unless ,first ,within)
         (wipe ,first)
         ,@body))))

(js-mac whilet (var test . body)
  (w/uniq (gf gp)
    `((rfn ,gf (,gp)
        (let ,var ,gp
          (when ,var ,@body (,gf ,test))))
      ,test)))

(js-mac do1 args
  (w/uniq g
    `(let ,g ,(car args)
       ,@(cdr args)
       ,g)))

(js-mac caselet (var expr . args)
  (let ex (afn (args)
            (if (no (cdr args)) 
                (car args)
                `(if (is ,var ',(car args))
                     ,(cadr args)
                     ,(self (cddr args)))))
    `(let ,var ,expr ,(ex args))))

(js-mac case (expr . args)
  `(caselet ,(uniq) ,expr ,@args))

; dramatic simplifications but maybe ok

;(js-mac push (x place)
;  `(if (,place `insertBefore)
;       ((,place `insertBefore) ,x (firstkid ,place))
;       (= ,place (cons ,x ,place))))

(js-mac push (x place)
  `(= ,place (cons ,x ,place)))

(js-mac swap (place1 place2)
  (w/uniq gtemp
    `(let ,gtemp ,place1
       (= ,place1 ,place2
          ,place2 ,gtemp))))

;(js-mac pop (place)
;  (w/uniq gx
;    `(if (,place `removeChild)
;          ((,place `removeChild) (firstkid ,place))
;         (let ,gx (car ,place)
;           (= ,place (cdr ,place))
;           ,gx))))

(js-mac pop (place)
  (w/uniq gx
    `(let ,gx (car ,place)
       (= ,place (cdr ,place))
       ,gx)))

(js-mac ++ (place (o i 1))
  `(= ,place (+ ,place ,i)))

(js-mac -- (place (o i 1))
  `(= ,place (- ,place ,i)))

(js-mac wipe args
  `(do ,@(accum acc
           (each a args
             (acc `(= ,a nil))))))

(js-mac set args
  `(do ,@(accum acc
           (each a args
             (acc `(= ,a t))))))

(js-mac iflet (var expr then . rest)
  (w/uniq gv
    `(let ,gv ,expr
       (if ,gv (let ,var ,gv ,then) ,@rest))))

(js-mac whenlet (var expr . body)
  `(iflet ,var ,expr (do ,@body)))

; aif, awhen and aand not tested

(js-mac aif (expr . body)
  `(let it ,expr
     (if it
         ,@(if (cddr body)
               `(,(car body) (aif ,@(cdr body)))
               body))))

(js-mac awhen (expr . body)
  `(let it ,expr (if it (do ,@body))))

(js-mac aand args
  (if (no args)
       't 
      (no (cdr args))
       (car args)
      `(let it ,(car args) (and it (aand ,@(cdr args))))))

(js-mac accum (accfn . body)
  (w/uniq gacc
    `(withs (,gacc nil ,accfn [push _ ,gacc])
       ,@body
       (rev ,gacc))))

(js-mac drain (expr (o eof nil))
  (w/uniq (gacc gdone gres)
    `(with (,gacc nil ,gdone nil)
      (while (no ,gdone)
        (let ,gres ,expr
          (if (is ,gres ,eof)
              (= ,gdone t)
              (push ,gres ,gacc))))
      (rev ,gacc))))

(js-mac whiler (var expr endval . body)
  (w/uniq gf
    `(withs (,var nil ,gf (testify ,endval))
       (while (no (,gf (= ,var ,expr)))
              ,@body))))

(js-mac check (x test (o alt))
  (w/uniq gx
    `(let ,gx ,x
       (if (,test ,gx) ,gx ,alt))))

(js-mac forlen (var s . body)
  `(for ,var 0 (- (len ,s) 1) ,@body))

(js-mac downlen (var s . body)
  `(down ,var (- (len ,s) 1) 0 ,@body))

(js-mac on (var s . body)
  (if (is var 'index)
      (err "Can't use index as first arg to on.")
      (w/uniq gs
        `(let ,gs ,s
           (forlen index ,gs
             (let ,var (listref ,gs index)  ; (,gs index)
               ,@body))))))

(js-mac nor args `(no (or ,@args))) 

(def caaris (x val) 
  (and (acons x) (acons car.x) (is (caar x) val)))

(def js1 (s)
  (if (caris s 'quote)        (apply js-quote cdr.s)
      (or (isa s 'char)  
          (isa s 'string))    (js-str/charesc s) 
          atom.s               pr.s
          (in car.s '+ '-   
              '* '/ '>= '<=     
              '> '< '% '===     
              '&& '\|\| '\.)   (apply js-infix s)
          (caris s 'car)       (apply js-car cdr.s)
          (caris s 'cdr)       (apply js-cdr cdr.s)
          (caris s 'obj)       (apply js-obj cdr.s)
          (caris s 'array)     (apply js-array cdr.s)
          (caris s 'objref)    (apply js-objref cdr.s)
          (caris s 'fncall)    (apply js-fncall cdr.s)
          (caris s 'listref)   (apply js-listref cdr.s)
          (caris s 'new)       (apply js-new cdr.s)
          (caris s 'typeof)    (apply js-typeof cdr.s)
          (caris s 'if)        (apply js-if cdr.s)
          (caris s 'fn)        (apply js-fn cdr.s)
          (caris s 'assign)    (apply js-assign cdr.s)
          (caris s 'var=)      (apply js-var= cdr.s)
          (caris s 'jsfor)     (apply js-for cdr.s)
          (caris s 'jsforin)   (apply js-forin cdr.s)
          (js-macs* car.s)     (apply (js-macs* car.s) cdr.s)
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
  (between a ssexpand-all.args (pr #\;)
    js1.a))

(def js args
  (apply js1/s args)
  (pr #\;))

(defop arc.js ()
  (js `(assign nil false)
      `(assign t true)
      `(def cons (car cdr)
         (obj car car
              cdr cdr
              type 'cons
              toString (fn ()
                         (+ "("   this.`car " . " this.`cdr ")"))))
      ; car and cdr macs but fns too for compose
      `(def car (xs) xs.`car)
      `(def cdr (xs) xs.`cdr)
      `(def table () (obj))
      `(def type (x)
         (if no.x                        'sym
             x.`type                     'cons
             (is typeof.x 'function)     'fn
             (is typeof.x 'object)
              ;(if (is x.`constructor 'Array)
              ;     'array
                  'table
              ;    )
             (and (is typeof.x 'string)
                  (is x.`length 1))      'char
                                         typeof.x))
      `(def isa (x y) (is (type x) y))
      `(def no (x) (or (is x nil)
                       (is x false)
                       (is x null)
                       (is x undefined)
                       ;(is x.`length 0)
                       ))
      `(def isnt (x y) (no (is x y)))

      `(def acons (x) (is (type x) 'cons))
      `(def atom (x) (no (acons x)))
      `(def len (seq)
         (if (no seq)
             0
             (acons seq)
             ((afn (xs n)
                (if (no xs)
                    n
                    (self (cdr xs) (+ n 1))))
              seq 0)
             seq.`length))
      `(def arraylist (xs)
         (var= acc nil)
         (jsfor i len.xs 0 (-- i)
           (assign acc (cons (objref xs (- i 1)) acc)))
         acc)
      `(def listarray (xs)
         ((afn (xs a)
            (if (no (cdr xs))
                (a.`concat (car xs))
                (self (cdr xs) (a.`concat (car xs)))))
          xs (array)))
      ; args should be rest parm, usually not needed though
      `(def apply (f args)
         (f.`apply this (listarray args)))
      `(def copylist (xs)
         (if (no xs) 
             nil 
             (cons (car xs) (copylist (cdr xs)))))
      `(def list args (copylist args))
      `(def idfn (x) x)
      `(def map1 (f xs)
         (if (no xs) 
             nil
             (cons (f (car xs)) (map1 f (cdr xs)))))
      `(def maptable (f h)
         (jsforin k h
           (let v (objref h k)
             (f k v)))
         h)
      `(def pair (xs (o f list))
         (if (no xs)
              nil
             (no (cdr xs))
              (list (list (car xs)))
             (cons (f (car xs) (cadr xs))
                   (pair (cddr xs) f))))
      `(def assoc (key al)
         (if (atom al)
             nil
             (and (acons (car al)) (is (caar al) key))
             (car al)
             (assoc key (cdr al))))
      `(def alref (al key) (cadr (assoc key al)))
      ; TypeError: Cannot read property 'cdr' of undefined
      ; RangeError: Maximum call stack size exceeded
      ; still not tested?
      `(def join args
         (if (no args)
             nil
             (let a (car args) 
               (if (no a) 
                   (apply join (cdr args))
                   (cons (car a) (apply join (cdr a) (cdr args)))))))
      `(def rev (xs) 
         ((afn (xs acc)
            (if (no xs)
                acc
                (self (cdr xs) (cons (car xs) acc))))
          xs nil))
      `(def alist (x) (or (no x) (is (type x) 'cons)))
      ; (empty (table)) should be true but it's false
      `(def empty (seq) 
         (or (no seq) 
             (and (or (is (type seq) 'string)
                      (is (type seq) 'table)
                      ;(is (type seq) 'array)
                      )
                  (is (len seq) 0))))
      `(def reclist (f xs)
         (and xs (or (f xs) (reclist f (cdr xs)))))
      ;`(def recstring (test s (o start 0))
      ;  ((afn (i)
      ;     (and (< i (len s)) ; &lt;
      ;          (or (test i)
      ;              (self (+ i 1)))))
      ;   start))
      `(def testify (x)
         (if (isa x 'fn) x [is _ x]))
      ; not working 
      `(def some (test seq)
        (let f (testify test)
          (if (alist seq)
              (reclist (f:car) seq)
              ;(recstring (f:seq) seq)
              )))
      `(def mem (test seq)
         (let f (testify test)
           (reclist [if (f:car _) _] seq)))
      `(def firstn (n xs)
         (if (no n)            xs
             (and (> n 0) xs)  (cons (car xs) (firstn (- n 1) (cdr xs)))
             nil))
      `(def nthcdr (n xs)
         (if (no n)  xs
             (> n 0) (nthcdr (- n 1) (cdr xs))
             xs))
      `(def tuples (xs (o n 2))
         (if (no xs)
             nil
             (cons (firstn n xs)
                   (tuples (nthcdr n xs) n))))
      `(def caris (x val) 
         (and (acons x) (is (car x) val)))
      `(def last (xs)
         (if (cdr xs)
             (last (cdr xs))
             (car xs)))
      `(def rem (test seq)
         (let f (testify test)
           (if (alist seq)
               ((afn (s)
                  (if (no s)       nil
                      (f (car s))  (self (cdr s))
                      (cons (car s) (self (cdr s)))))
                seq)
               ;(coerce (rem test (coerce seq 'cons)) 'string)
               )))
      `(def keep (test seq) 
        (rem (complement (testify test)) seq))
      `(def trues (f xs)
         (and xs
              (let fx (f (car xs))
                (if fx
                    (cons fx (trues f (cdr xs)))
                    (trues f (cdr xs))))))
      `(def flat x
         ((afn (x acc)
            (if (no x)   acc
                (atom x) (cons x acc)
                (self (car x) (self (cdr x) acc))))
          x nil))
      `(def even (n) (is (mod n 2) 0))
      `(def odd (n) (no (even n)))
      ; not tested
      `(def best (f seq)
        (if (no seq)
            nil
            (let wins (car seq)
              (each elt (cdr seq)
                (if (f elt wins) (= wins elt)))
              wins)))
      `(def gt args
         (or (no args)
             (no (cdr args))
             (and (> (car args) (cadr args))
                  (apply gt (cdr args)))))
      `(def lt args
         (or (no args)
             (no (cdr args))
             (and (< (car args) (cadr args))
                  (apply lt (cdr args)))))
      `(def lte args
         (or (no args)
             (no (cdr args))
             (and (no (> (car args) (cadr args)))
                  (apply lte (cdr args)))))
      `(def gte args
        (or (no args)
            (no (cdr args))
            (and (no (< (car args) (cadr args)))
                 (apply gte (cdr args)))))
      `(def max args (best gt args))  ; >
      `(def min args (best lt args))  ; <
      `(def most (f seq) 
         (unless (no seq)
           (withs (wins (car seq) topscore (f wins))
             (each elt (cdr seq)
               (let score (f elt)
                 (if (> score topscore) (= wins elt topscore score))))
             wins)))
      `(def whitec (c)
         (in c #\space #\newline #\tab #\return))
      `(def nonwhite (c) (no (whitec c)))
      ;`(def letter (c) (or (<= #\a c #\z) (<= #\A c #\Z)))
      `(def letter (c)
         (in c #\a #\b #\c #\d #\e #\f #\g #\h #\i #\j #\k #\l
               #\m #\n #\o #\p #\q #\r #\s #\t #\u #\v #\w #\x
               #\y #\z #\A #\B #\C #\D #\E #\F #\G #\H #\I #\J
               #\K #\L #\M #\N #\O #\P #\Q #\R #\S #\T #\U #\V
               #\W #\X #\Y #\Z))
      ;`(def digit (c) (<= #\0 c #\9))
      `(def digit (c)
         (in c #\1 #\2 #\3 #\4 #\5 #\6 #\7 #\8 #\9))
      `(def alphadig (c) (or (letter c) (digit c)))
      `(def punc (c)
         (in c #\. #\, #\; #\: #\! #\?))
      `(def sum (f xs)
         (let n 0
           (each x xs (++ n (f x)))
           n))
      `(def treewise (f base tree)
         (if (atom tree)
             (base tree)
             (f (treewise f base (car tree)) 
                (treewise f base (cdr tree)))))
      `(def carif (x) (if (atom x) x (car x)))
      `(def tree_subst (old new_ tree)
         (if (is tree old)
              new_
             (atom tree)
              tree
             (cons (tree-subst old new_ (car tree))
                   (tree-subst old new_ (cdr tree)))))
      `(def ontree (f tree)
         (f tree)
         (unless (atom tree)
           (ontree f (car tree))
           (ontree f (cdr tree))))
      `(def dotted (x)
         (if (atom x)
             nil
             (and (cdr x) (or (atom (cdr x))
                              (dotted (cdr x))))))
     ; kv instead of (k v) because no destructuring bind
     `(def keys (h) 
        (accum a (each kv h (a car.kv))))
     `(def vals (h) 
        (accum a (each kv h (a cadr.kv))))
     `(def tablist (h)
        (accum a (maptable (fn args (a args)) h)))
     `(def listtab (al)
        (let h (table)
          (map1 (fn (kv)
                 (= (objref h car.kv) cadr.kv))
               al)
          h))
     ;`(def copy (x . args)
     ;   (let x2 (case (type x)
     ;             sym    x
     ;             cons   (copylist x) ; (apply (fn args args) x)
     ;             string (let new (newstring (len x))
     ;                      (forlen i x
     ;                              (= (new i) (x i)))
     ;                      new)
     ;             table  (let new (table)
     ;                      (each (k v) x 
     ;                        (= (new k) v))
     ;                      new)
     ;             (err "Can't copy " x))
     ;     (map (fn ((k v)) (= (x2 k) v))
     ;          (pair args))
     ;     x2))

     ; nope
     ;`(def get (index)
     ;   (fn (_) (if (isa _ 'fn) _.index
     ;               (isa _ 'table) _.`index)))
     ))

;(js-mac tag (spec . body)
;  (if atom.spec
;      `(fncall createElt ,spec)
;       (w/uniq elt
;         `(let ,elt (createElt (car ',spec))
;            (each as (pair (cdr ,spec))
;              (= (objref ,elt (car as)) (cadr as)))
;            (= (,elt 'innerHTML) ,@body)))))

;(js-mac kids (node) `(,node `children))
(js-mac kids (node) `(,node `childNodes))
(js-mac firstkid (node) `(,node `firstChild))
(js-mac lastkid (node) `(,node `lastChild))
(js-mac nextsib (node) `(,node `nextSibling))
(js-mac prevsib (node) `(,node `previousSibling))
(js-mac nkidelts (node) `(,node `childElementCount))
(js-mac firstkidelt (node) `(,node `firstElementChild))
(js-mac lastkidelt (node) `(,node `lastElementChild))
(js-mac nextsibelt (node) `(,node `nextElementSibling))
(js-mac prevsibelt (node) `(,node `previousElementSibling))
(js-mac par (node) `(,node `parentElement))

; http://www.quirksmode.org/dom/w3c_html.html
(js-mac id (elt) `(,elt `id))
(js-mac class (elt) `(,elt `className))
(js-mac inner (elt) `(,elt `innerHTML))
;(js-mac outer (elt) `(,elt `outerHTML))
;(js-mac ihtml (elt) `(,elt `innerHTML))
;(js-mac ohtml (elt) `(,elt `outerHTML))
;(js-mac itext (elt) `(,elt `innerText))
;(js-mac otext (elt) `(,elt `outerText))
(js-mac textof (elt) `(,elt `textContent))
(js-mac title (elt) `(,elt `title))

; http://www.quirksmode.org/dom/w3c_css.html
(js-mac style (elt) `(,elt `style))

(js-mac eachkid1 (var node . body)
  (w/uniq gi
   `(forlen ,gi (kids ,node)
      (let ,var (objref (kids ,node) ,gi)
        ,@body))))

(js-mac eachkid (var node . body)
  `(if (~empty (kids ,node))
       (eachkid1 ,var ,node ,@body)))

; missing (err "Can't use index as first arg to on.")
(js-mac onkid1 (var node . body)
  `(forlen index (kids ,node)
     (let ,var (objref (kids ,node) index)
       ,@body)))

(js-mac onkid (var node . body)
  `(if (~empty (kids ,node))
       (onkid1 ,var ,node ,@body)))

(js-mac betweenkid (var expr within . body)
  (w/uniq first
    `(let ,first t
       (eachkid ,var ,expr
         (unless ,first ,within)
         (wipe ,first)
         ,@body))))

; recursive/treewise
; needs better name?
(js-mac eachnode (var top . body)
  (w/uniq gt
   `((afn (,gt)
       (eachkid ,var ,gt
         (self ,var)
         ,@body))
     ,top)))

(js-mac eachleaf (var top . body)
  `(eachnode ,var ,top
     (if (aleaf ,var)
         ,@body)))

; not all showing up at http://localhost:8080/utils.js?
(defop utils.js ()
  (js ; better name?
    `(def beget (h)
       (let F (fn ())
         (= F.`prototype h)
         (new F)))
      `(= doc document
          ;body doc.`body   ; can't do this
          doc.`elt        doc.`createElement
          doc.`text       doc.`createTextNode
          doc.`attr       doc.`createAttribute  ; working?
          doc.`byId       doc.`getElementById
          doc.`byClass    doc.`getElementsByClassName
          doc.`byTag      doc.`getElementsByTagName
          Node.`prototype.`appendkid
           Node.`prototype.`appendChild
          Node.`prototype.`clone  ;these not tested
           Node.`prototype.`cloneNode
          Node.`prototype.`pushkid
           Node.`prototype.`insertBefore
          Node.`prototype.`popkid
           Node.`prototype.`removeChild
          Node.`prototype.`removekid
           Node.`prototype.`removeChild
          Node.`prototype.`replacekid
           Node.`prototype.`replaceChild
          Node.`prototype.`haskids
           Node.`prototype.`hasChildNodes
          Element.`prototype.`getattr
           Element.`prototype.`getAttribute
          Element.`prototype.`setattr
           Element.`prototype.`setAttribute
         Element.`prototype.`setattrnode  ;working?
           Element.`prototype.`setAttributeNode
         Element.`prototype.`removeattr
          Element.`prototype.`removeAttribute
          )

      `(def byId (id) doc.`byId.id)
      `(def byid (id) doc.`byId.id)
      `(def byclass (class) doc.`byClass.class)
      `(def bytag (tag) doc.`byTag.tag)
      ;`(def createElt (spec)
      ;   (doc.`createElement spec))
      `(def aleaf (node) (empty kids.node))
      `(def elt (spec . attrs)
         (let elt (doc.`createElement spec)
           (each as pair.attrs
             (elt.`setAttribute car.as cadr.as))
           elt))
      `(def text (s)
         (doc.`createTextNode s))
      `(def copyelt (elt)
         (elt.`cloneNode))
      `(def replace (oldelt newelt)
         (par.oldelt.`replacekid newelt oldelt))
      `(def remove (elt)
         (par.elt.`removekid elt))
      ; works? better name?
      `(def domwise (f)
         ((afn (f dom)
           (if (no dom)
                nil
               (no kids.dom)
                (f dom)
               (do (self f (car (arraylist kids.dom))) 
                   (self f (cdr (arraylist kids.dom))))))
          f doc.`body))
      
      ;`(def pushelt (elt place)
      ;   (place.`insertBefore elt firstkid.place))
      ;`(def popelt (place)
      ;   (rmelt firstkid.place))
      ))

(defop arc2js () 
  (html
    (head
      (scriptsrc "arc.js")
      (scriptsrc "utils.js")
      (scriptsrc "jquery-1.4.2.min.js")
      (script:js
        `($.doc.`ready (fn ()
           (= byid!compilebut.`onclick
              (fn ()
                ($.`ajax
                  (obj data      (obj arc byid!arcbox.`value)
                       url       ,(flink
                                    (fn (req)
                                      (apply js (readall (arg req "arc")))))
                       success   (fn (msg)
                                   (= (inner byid!jsbox) msg))))
                nil))))))
    (body
      ;(h2:pr "Compile Arc to Javascript")
      (h2:pr "Try ArcScript")
      (h3:pr "Enter Arc here")
      (tag (textarea id 'arcbox))
      (gentag input type 'submit id 'compilebut value "Compile")
      (h3:pr "Javascript appears here")
      (tag (textarea id 'jsbox))
      (tag p (pr "Some of the Javascript that can result is defined in ")
             (link "http://evanrmurphy.com/arc.js")
             (pr ", so include that file in your html if you want it to run properly.")))))

(mac jspage body
 `(html
    (head
      (scriptsrc "arc.js")
      (scriptsrc "utils.js")
    (body
      ,@body))))

(mac jsonpage body
 `(html
    (head
      (scriptsrc "arc.js")
      (scriptsrc "utils.js")
      (scriptsrc "json.js"))
    (body
      ,@body)))


