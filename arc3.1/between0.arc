(mac between (var expr within . body)
  (w/uniq first
    `(let ,first t
       (each ,var ,expr
         (unless ,first ,within)
         (wipe ,first)
         ,@body))))
