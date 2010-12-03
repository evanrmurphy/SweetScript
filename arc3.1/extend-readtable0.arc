; http://awwx.ws/extend-readtable0

(def extend-readtable (c parser)
  (scheme
   (current-readtable
    (make-readtable (current-readtable)
                    c
                    'non-terminating-macro
                    (lambda (ch port src line col pos)
                      (parser port))))))
