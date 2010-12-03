; Convert [] {} into regular symbols

(extend-readtable #\[
  (fn (port)
    (sym:string
      #\[
      (unless (whitec (peekc port))
        (read port)))))

(extend-readtable #\]
  (fn (port)
    (sym:string
      #\]
      (unless (whitec (peekc port))
        (read port)))))

(extend-readtable #\{
  (fn (port)
    (sym:string
      #\{
      (unless (whitec (peekc port))
        (read port)))))

(extend-readtable #\}
  (fn (port)
    (sym:string
      #\}
      (unless (whitec (peekc port))
        (read port)))))
