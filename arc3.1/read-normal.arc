; Convert [] {} into regular symbols

; Note: works for special reader characters, not ssyntax

(mac read-normal (x)
  `(extend-readtable ,x
     (fn (port)
       (sym:string
         ,x
         (let c (peekc port)
           (unless (or (whitec  c) (ssyntax c) (in c #\( #\) ))
             (read port)))))))

(read-normal #\[)
(read-normal #\])
; (read-normal #\{)
; (read-normal #\})
