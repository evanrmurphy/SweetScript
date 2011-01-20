; utils

(def caddr (xs) (car (cddr xs)))
(def cdddr (xs) (cdr (cddr xs)))
(def cadddr (xs) (cadr (cddr xs)))
(def cddddr (xs) (cadr (cddr xs)))

(defset caddr (x)
  (w/uniq g
    (list (list g x)
          `(caddr ,g)
          `(fn (val) (scar (cddr ,g) val)))))

(defset cdddr (x)
  (w/uniq g
    (list (list g x)
          `(cddr ,g)
          `(fn (val) (scdr (cddr ,g) val)))))

(defset cadddr (x)
  (w/uniq g
    (list (list g x)
          `(cadddr ,g)
          `(fn (val) (scar (cdddr ,g) val)))))

(defset cddddr (x)
  (w/uniq g
    (list (list g x)
          `(cddddr ,g)
          `(fn (val) (scdr (cdddr ,g) val)))))

(def zip args (apply map list args))

;

(def env ((o h (table)) (o e nil))
  (cons h e))

(= global-env* (env))

(def env-find (x (o e global-env*))
  (if (car.e x) e
      (cdr e)   (env-find x cdr.e)
                nil))

(def env-get (var (o e global-env*))
  (aif (env-find var e)
        (car.it var)
        nil))

; should this return the env instead of mutating it?
(def env-set (var val e)
  (aif (env-find var e)
        (= (car.it var) val)
        (= (car.e var) val)))

(def ival (x (o e global-env*))
  (if (isa x 'sym)        (env-get x e)
      (~acons x)          x
      (is car.x 'ival)    (apply ival cdr.x) ;(ival cadr.x e)
      (is car.x 'assign)  (env-set cadr.x (ival caddr.x e) e)
      (is car.x 'vau)     (fn args
                            (ival caddr.x (env (listtab:zip cadr.x args) e)))
                          (apply (ival car.x e) cdr.x)
                          ))
