;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
;@@@@@@@@@@@ --------- PLANNER --------- @@@@@@@@@@@
;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

(deftemplate node (slot ident) (slot gcost) (slot fcost) (slot father) (slot pos-r)
                  (slot pos-c) (slot open) (slot direction))

(deftemplate newnode (slot ident) (slot gcost) (slot fcost) (slot father) (slot pos-r)
                  (slot pos-c) (slot direction))

; ############################# STATO INIZIALE #############################
; Verrà ridefinito in seguito con i valori del K-agent (dalla regola init-first-node)
; È definito -1 l'ident per permettere alla regola init-first-node di essere attivabile
; e di generare il nodo iniziale partendo dal K-agent
;(deffacts S0
;      (node (ident -1) (gcost 0) (fcost 0) (father NA) (pos-r 0) (pos-c 0) (direction north) (open yes)) 
;      (current 0)
;      (lastnode 0)
;      (open-worse 0)
;      (open-better 0)
;      (alreadyclosed 0)
;      (numberofnodes 0))

; Vecchia versione: ora il goal è dato in input
;(deffacts final
;      (planned-goal 9 4))


; Inizializza lo stato iniziale a partire da K-agent
(defrule init-first-node
(declare (salience 150)) ; assolutamente la prima regola ad essere eseguita
?ka <- (K-agent (pos-r ?r) (pos-c ?c) (direction ?d) )
(not (node)) ; non ci devono essere nodi definiti (quindi A star è all'inizio)
(something-to-plan) ; e qualcosa da pianificare (onde evitare loops di A star (nel senso del modulo))
=>
    (assert 
        (current 0)
        (lastnode 0)
        (open-worse 0)
        (open-better 0)
        (alreadyclosed 0)
        (numberofnodes 0)
        (node (ident 0) (gcost 0) (fcost 0) (father NA) (pos-r ?r) (pos-c ?c) (direction ?d) (open yes)))
)

(defrule achieved-goal
(declare (salience 100))
        (status (step ?i) (time ?t))
     (current ?id) ; Dato il corrente id
     (planned-goal ?r ?c) ; C'è questo goal
     (node (ident ?id) (pos-r ?r) (pos-c ?c) (gcost ?g)) ; Il nodo corrente è quello goal
        => (printout t " Esiste soluzione per goal (" ?r "," ?c ") con costo "  ?g crlf)
            (assert (printGUI (time ?t) (step ?i) (source "PLANNER") (verbosity 2) (text  "Solution exists for goal(%p1, %p2) with cost %p3") (param1 ?r) (param2 ?c) (param3 ?g)))      
           (assert (stampa ?id)) ; Parte la stampa degli operatori
           )

(defrule stampaSol
(declare (salience 101))
?f<-(stampa ?id)
    (status (step ?i) (time ?t))
    (node (ident ?id) (father ?anc&~NA))  
    (plan-exec ?anc ?id ?oper ?r ?c)
=> (printout t " Pianificata azione " ?oper " da stato (" ?r "," ?c ") " crlf)
    (assert (printGUI (time ?t) (step ?i) (source "PLANNER") (verbosity 2) (text  "Planned action %p3 from cell  (%p1, %p2)") (param1 ?r) (param2 ?c) (param3 ?oper)))      
    (assert (planned-action ?id ?oper ?r ?c)) ; Fatti che l'agente leggerà per andare ad eseguire il piano
   (assert (stampa ?anc))
   (retract ?f)
)

(defrule print-fine
(declare (salience 102))
    (status (step ?i) (time ?t))
       (stampa ?id)
       (node (ident ?id) (father ?anc&NA))
       (open-worse ?worse)
       (open-better ?better)
       (alreadyclosed ?closed)
       (numberofnodes ?n )  
=> (printout t " stati espansi " ?n crlf)
   (printout t " stati generati già in closed " ?closed crlf)
   (printout t " stati generati già in open (open-worse) " ?worse crlf)
   (printout t " stati generati già in open (open-better) " ?better crlf)   
   (assert (printGUI (time ?t) (step ?i) (source "PLANNER") (verbosity 2)  (text  "Stati espansi: %p1") (param1 ?n)))      
    (assert (printGUI (time ?t) (step ?i) (source "PLANNER") (verbosity 2) (text  "Stati generati già in closed: %p1")  (param1 ?closed)))  
    (assert (printGUI (time ?t) (step ?i) (source "PLANNER") (verbosity 2) (text  "Stati generati già in open (open-worse e open-better): %p1 e %p2") (param1 ?worse) (param2 ?better))) 
    (focus PLAN-DEL) ; Va in DEL
)


; ######################### FORWARD ########################
; Dice che up è applicabile con ?r e ?c
(defrule forward-north-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction north) (open yes))
        (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains Empty|Parking)) ; devo verificare che non vi siano
   => (assert (apply ?curr forward-north ?r ?c)))


; Esegue effettivamente la up
(defrule forward-north-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-north ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ;ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r (+ ?r 1)) (pos-c ?c) (direction north) ;vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x (+ ?r 1))) (abs (- ?y ?c)) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))


; Dice che up è applicabile con ?r e ?c
(defrule forward-south-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction south) (open yes))
        (K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains Empty|Parking)) ; devo verificare che non vi siano
   => (assert (apply ?curr forward-south ?r ?c)))


; Esegue effettivamente la up
(defrule forward-south-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-south ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ; ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r (- ?r 1)) (pos-c ?c) (direction south);vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x (- ?r 1))) (abs (- ?y ?c)) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))

; Dice che up è applicabile con ?r e ?c
(defrule forward-east-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction east) (open yes))
        (K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains Empty|Parking)) ; devo verificare che non vi siano cose dentro
   => (assert (apply ?curr forward-east ?r ?c)))


; Esegue effettivamente la up
(defrule forward-east-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-east ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ; ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r ?r) (pos-c (+ ?c 1)) (direction east);vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y (+ ?c 1))) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))


; Dice che up è applicabile con ?r e ?c
(defrule forward-west-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction west) (open yes))
        (K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains Empty|Parking)) ; devo verificare che non vi siano
   => (assert (apply ?curr forward-west ?r ?c)))


; Esegue effettivamente la up
(defrule forward-west-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n) ;ultimo nodo
 ?f1<-  (apply ?curr forward-west ?r ?c) ;ci vuole l'apply
        (node (ident ?curr) (gcost ?g)) ;prende il nodo corrente
        (planned-goal ?x ?y) ; ci serve per calcolare h (la funzione di Manhattan)
   =>   (assert (plan-exec ?curr (+ ?n 1) Forward ?r ?c) ; Azione definitiva, forward
        (newnode (ident (+ ?n 1)) (pos-r ?r) (pos-c (- ?c 1)) (direction west);vado su
            (gcost (+ ?g 2)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y (- ?c 1))) ?g 2)) ;identifico il nodo come n+1, g = g+1, f = h+g
        ; La h è calcolata on the fly
        (father ?curr))) 
        (retract ?f1)
        (focus PLAN-NEW))


; ############### TURNLEFT #############
(defrule turnleft-north-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction north) (open yes))
   => (assert (apply ?curr turnleft-north ?r ?c))
              )

(defrule turnleft-north-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-north ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction west)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1))     ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnleft-south-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction south) (open yes))
   => (assert (apply ?curr turnleft-south ?r ?c))
              )

(defrule turnleft-south-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-south ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction east)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnleft-east-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction east) (open yes))
   => (assert (apply ?curr turnleft-east ?r ?c)))

(defrule turnleft-east-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-east ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction north)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnleft-west-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction west) (open yes))
   => (assert (apply ?curr turnleft-west ?r ?c))
              )

(defrule turnleft-west-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnleft-west ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 2) Turnleft ?r ?c)
              (newnode (ident (+ ?n 2)) (pos-r ?r) (pos-c ?c) (direction south)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))


; ############### TURNRIGHT #############
(defrule turnright-north-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction north) (open yes))
   => (assert (apply ?curr turnright-north ?r ?c)))

(defrule turnright-north-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-north ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction east)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnright-south-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction south) (open yes))
   => (assert (apply ?curr turnright-south ?r ?c)))

(defrule turnright-south-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-south ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction west)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnright-east-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction east) (open yes))
   => (assert (apply ?curr turnright-east ?r ?c)))

(defrule turnright-east-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-east ?r ?c)
        (node (ident ?curr) (gcost ?g) )
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction south)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

(defrule turnright-west-apply
        (declare (salience 50))
        (current ?curr)
        (node (ident ?curr) (pos-r ?r) (pos-c ?c) (direction west) (open yes))
   => (assert (apply ?curr turnright-west ?r ?c)))

(defrule turnright-west-exec
        (declare (salience 50))
        (current ?curr)
        (lastnode ?n)
 ?f1<-  (apply ?curr turnright-west ?r ?c)
        (node (ident ?curr) (gcost ?g))
        (planned-goal ?x ?y)
   => (assert (plan-exec ?curr (+ ?n 3) Turnright ?r ?c)
              (newnode (ident (+ ?n 3)) (pos-r ?r) (pos-c ?c) (direction north)
                       (gcost (+ ?g 1)) (fcost (+ (abs (- ?x ?r)) (abs (- ?y ?c)) ?g 1)) ;la stessa f di prima, ma somma di 1 (perché la g è aumentata di 1)
                       (father ?curr)))
      (retract ?f1)
      (focus PLAN-NEW))

; Ne cerca uno nuovo (perché il branching di ?curr è stato tutto espletato)
(defrule change-current
         (declare (salience 49)) ; Salience leggermente più bassa: eseguita quando non c'è altro di applicabile (una azione)
?f1 <-   (current ?curr)
?f2 <-   (node (ident ?curr)) ;nodo corrente
         (node (ident ?best&:(neq ?best ?curr)) (fcost ?bestcost) (open yes)) ; Scelgo un nodo open tale che  
         (not (node (ident ?id&:(neq ?id ?curr)) (fcost ?gg&:(< ?gg ?bestcost)) (open yes))); non ne esista uno diverso da quello di sopra, in open e tale per cui ha costo migliore di quello di prima
?f3 <-   (lastnode ?last) 
   =>    (assert (current ?best) (lastnode (+ ?last 4))) ; Il nuovo corrente non è più quello corrente ma best (un nuovo id)
         (retract ?f1 ?f3)
         (modify ?f2 (open no))) 

; La strategia termina quando la lista open è vuota
(defrule close-empty
         (declare (salience 49))
?f1 <-   (current ?curr)
?f2 <-   (node (ident ?curr))
         (not (node (ident ?id&:(neq ?id ?curr))  (open yes)))
     => 
         (retract ?f1)
         (modify ?f2 (open no))
         (printout t " fail (last  node expanded " ?curr ")" crlf)
         (halt))       

; ############################################# 
; Modulo PLAN-NEW: NECESSARIO PER IL PLANNER
; ############################################
(defmodule PLAN-NEW (import PLANNER ?ALL) (export ?ALL))

; Il newnode è un doppione di un nodo già chiuso
(defrule check-closed
(declare (salience 50)) 
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d)) ;se ho generato un nodo per la posizione r e c orientato d
           (node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (open no)) ;c'è un nodo che ha quello stato ed è già in closed
 ?f2 <-    (alreadyclosed ?a) ; contatore di nodi chiusi
    =>
           (assert (alreadyclosed (+ ?a 1))) ; contatore di nodi chiusi
           (retract ?f1) ;retracto e butto via, tanto l'avevo già chiuso
           (retract ?f2)
           (pop-focus))

; Cancella nodo nuovo che sia peggiore di uno già nella coda
(defrule check-open-worse
(declare (salience 50)) 
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (father ?anc)) ;il nuovo nodo
           (node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes)) ;ma ne esiste un altro, sempre in open, che ha già costo migliore di quello appena aperto
           (test (or (> ?g ?g-old) (= ?g-old ?g)))
 ?f2 <-    (open-worse ?a)
    =>
           (assert (open-worse (+ ?a 1))) ;butto via
           (retract ?f1)
           (retract ?f2)
           (pop-focus))

; Cancella nodo vecchio in coda che sia peggiore di uno appena trovato
(defrule check-open-better
(declare (salience 50)) 
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc))
 ?f2 <-    (node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes))
           (test (<  ?g ?g-old))
 ?f3 <-    (open-better ?a)
    =>     (assert (node (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc) (open yes)))
           (assert (open-better (+ ?a 1)))
           (retract ?f1 ?f2 ?f3)
           (pop-focus))

; Se nessuna delle precedenti è eseguito, lo metto semplicemente come nuovo nodo (newnode diventa un nodo a tutti gli effetti)
(defrule add-open
       (declare (salience 49))
 ?f1 <-    (newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f)(father ?anc))
 ?f2 <-    (numberofnodes ?a)
    =>     (assert (node (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f)(father ?anc) (open yes)))
           (assert (numberofnodes (+ ?a 1)))
           (retract ?f1 ?f2)
           (pop-focus))


; ############################################# 
; Modulo PLAN-DEL: NECESSARIO PER IL PLANNER (cancellare)
; ############################################
(defmodule PLAN-DEL (import PLANNER ?ALL))

; Rimuove prima di tutto i node
(defrule remove-node-facts
     (declare (salience 1))
    ?f <- (node) ; qualsiasi nodo tranne quello con ident -1 (che genereremo successivamente)
    => (retract ?f)
) 

; Poi rimuove i plan exec
(defrule clean-plan-exec-facts
     (declare (salience 1))    
    ?f <- (plan-exec $?)
    => (retract ?f)
)

; Poi ristabilisce la situazione per il prossimo planning
(defrule delete-general
    ?f <- (current $?)
    ?f2 <- (lastnode $?)
    ?f3 <- (open-worse $?)
    ?f4 <- (open-better $?)
    ?f5 <- (alreadyclosed $?)
    ?f6 <- (numberofnodes $?)
    ?f7 <- (stampa $?)
    => (retract ?f) (retract ?f2) (retract ?f3) (retract ?f4) (retract ?f5) (retract ?f6) (retract ?f7)
)

; Rimuove il goal
(defrule remove-goal-fact
    ?f <- (planned-goal $?)
    => (retract ?f)
) 

(defrule back-to-planner
    (declare (salience -1))
    ?f <- (something-to-plan)
    =>
    (retract ?f) ; Fatto che informa l'agente in merito al dover eseguire un piano (che è stato preparato)
    (pop-focus) ; Torniamo al planner
    (pop-focus) ; Torniamo all'agente (facendo una POP)
)



