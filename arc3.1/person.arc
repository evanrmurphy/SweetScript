; sweet-script example
; hacking with ryan, 12/28/10

(js `(do


(def personUpdateSternness ()
  (if (== this.laughter 0)
       (= this.sternness true)
      (> this.laughter 5)
       (= this.sternness))
  this.sternness)

(def personUpdateLaughter ()
  (if (! this.sternness)
       (+= this.laughter 10)
       (do (-- this.laughter)
           (if (< this.laughter -10)
                (+= this.laughter 10000))))
  this.sternness)

(def person ()
  {laughter '0
   sternness 'false
   updateSternness 'personUpdateSternness
   updateLaughter 'personUpdateLaughter})

(= evan (person)  ryan (person))


))
