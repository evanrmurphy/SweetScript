; inspired by http://awwx.ws/table-rw3

(def parse-array-items (port (o acc nil))
  ((scheme skip-whitespace) port)
  (if (is (peekc port) #\])
       (do (readc port) `(list ,@(rev acc)))
       (let x (read port)
         (= acc (cons x acc))
         (parse-array-items port acc))))

(extend-readtable #\[ parse-array-items)
