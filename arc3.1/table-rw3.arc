; http://awwx.ws/table-rw3
; modified!

(def parse-table-items (port (o acc (table)))
  ((scheme skip-whitespace) port)
  (if (is (peekc port) #\})
       (do (readc port) acc)
       (with (k (read port)
              v (read port))
         (= (acc k) v)
         (parse-table-items port acc))))

(extend-readtable #\{ parse-table-items)

; need the errsafe on type tests because (type x) croaks on
; non-Arc types

(extend ac-literal (x) (errsafe:isa x 'table)
  scheme-t)
