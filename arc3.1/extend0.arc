; http://awwx.ws/extend0

(mac extend (name arglist test . body)
  (w/uniq args
    `(let orig ,name
       (= ,name
          (fn ,args
            (aif (apply (fn ,arglist ,test) ,args)
                  (apply (fn ,arglist ,@body) ,args)
                  (apply orig ,args)))))))
