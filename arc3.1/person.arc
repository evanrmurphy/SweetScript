; sweet-script example
; hacking with ryan, 12/28/10

(js `(do


(def personUpdateStern ()
  (if (== this.laughter 0)
       (= this.stern true)
      (> this.laughter 5)
       (= this.stern))
  this.stern)

(def personUpdateLaughter ()
  (if (! this.stern)
       (+= this.laughter 10)
       (do (-- this.laughter)
           (if (< this.laughter -10)
                (+= this.laughter 10000))))
  this.stern)

(def person ()
  {laughter 0
   stern false
   updateStern personUpdateStern
   updateLaughter personUpdateLaughter})

(= evan (person)  ryan (person))


))
