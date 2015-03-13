(defmodule UPDATE-DISTPATH (import AGENT ?ALL) (export ?ALL))

;
(defrule calc-order-distpath
  (declare (salience 140))
  ?flag<-(update-order-distpath ?table ?step)
  ?order<-
=>
  (if ()
    then
      ()
  )
)