;; REGOLA AGGIUNTA PER FAR FUNZIONARE L'INTERFACCIA

(defrule stop-on-env
   (declare (salience 210))
?f1 <-  (status (step ?i))
        (exec (step ?i)) =>
        (halt)) 
