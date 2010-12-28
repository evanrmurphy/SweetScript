; http://awwx.ws/table-rw3
; modified!

(def parse-table-items (port (o acc nil))
  ((scheme skip-whitespace) port)
  (if (is (peekc port) #\})
       (do (readc port) `(obj ,@(rev acc)))
       (let x (read port)
         (push x acc)
         (parse-table-items port acc))))

(extend-readtable #\{ parse-table-items)
