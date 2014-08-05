;// AGENT


(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

; ? l'ultimo passaggio, la fotografia, perch? ? atemporale.
; ? l'ultimo passaggio, la fotografia, perch? ? atemporale.
; qui dentro ci serve per capire quando e dove si muovono gli agenti umani: il resto resta sempre cosi
; il tempo non ha senso se non facciamo roba sofisticata tipo previsione di spostamenti.
; per lui il mondo ? cos? come l'ha percepito all'ultimo istante.eprc


(deftemplate K-cell  (slot pos-r) (slot pos-c) 
                     (slot contains (allowed-values Wall Person  Empty Parking Table Seat TB RB DD FD)))


(deftemplate K-agent
	(slot step)
  (slot time) 
	(slot pos-r) 
	(slot pos-c) 
	(slot direction) 
	(slot l-drink)
  (slot l-food)
  (slot l_d_waste)
  (slot l_f_waste)
)

(deftemplate K-table
	(slot step)
  (slot time)
  (slot pos-r)
  (slot pos-c)
	(slot table-id)
	(slot clean (allowed-values yes no))
	(slot l-drink)
  (slot l-food)
)
; step dell'ultima percezione esaminata
(deftemplate last-perc (slot step))

(deftemplate plane (multislot pos-start) (multislot pos-end) (multislot exec-astar-sol) (slot cost))
(deftemplate start-astar (slot pos-r) (slot pos-c))
(deftemplate run-plane-astar (multislot pos-start) (multislot pos-end))

(deftemplate distance-fd (multislot pos-start) (multislot pos-end) (slot distance))
(deftemplate distance-dd (multislot pos-start) (multislot pos-end) (slot distance))


(defrule  beginagent1
    (declare (salience 11))
    (status (step 0))
    (not (exec (step 0)))
    (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x)) 
=>
    (assert (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)
            
(defrule  beginagent2
    (declare (salience 11))
    (status (step 0))
    (not (exec (step 0)))
    (initial_agentposition (pos-r ?r) (pos-c ?c) (direction ?d))
=> 
    (assert (K-agent (step 0) (time 0) (pos-r ?r) (pos-c ?c) (direction ?d)
    (l-drink 0) (l-food 0) (l_d_waste no) (l_f_waste no)))
    ;All'inzio non ci sono percezioni quindi last-perc è impostata a -1.
    (assert (last-perc (step -1)))
)

(defrule  beginagent3
    (declare (salience 11))
    (status (step 0))
    (not (exec (step 0)))
    (Table (table-id ?tid) (pos-r ?r) (pos-c ?c) )
=>
    (assert (K-table (step 0) (time 0) (pos-r ?r) (pos-c ?c) (table-id ?tid) (clean yes) (l-drink 0) (l-food 0) ))
)

(defrule ask_act
         ?f <-   (status (step ?i))
    =>  (printout t crlf crlf)
        (printout t "action to be executed at step:" ?i)
        (printout t crlf crlf)
        (modify ?f (result no)))

(defrule exec_act
    (declare (salience 100))
    (status (step ?i))
    (exec (step ?i))
 => (focus MAIN))

; Regola per avviare la ricerca con ASTAR.
(defrule go-astar
  (declare (salience 10))
	(start-astar (pos-r ?r) (pos-c ?c))
	(K-agent (pos-r ?r1) (pos-c ?c1))
	(not (plane (pos-start ?r1 ?c1) (pos-end ?r ?c)))
=>
    (assert (goal-astar ?r ?c))
    (focus ASTAR)
)

; Regola per non ripetere astar su un percorso su cui è stato appena calcolato il piano.
(defrule clean-start-astar
    (declare (salience 5))				   
    ?f1<-(start-astar (pos-r ?r) (pos-c ?c))
		(plane (pos-start ?r1 ?c1) (pos-end ?r ?c))
=>
    (retract ?f1)
	  (assert (run-plane-astar (pos-start ?r1 ?c1) (pos-end ?r ?c)))
)

;regola per eseguire astar dopo che è stato asserito un fatto con distanza man. per il food dispenser
(defrule start-astar-fd
    (declare (salience 10))
    ?f1<-(distance-fd (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance ?))
     =>
    (retract ?f1)
		(assert (start-astar (pos-r ?rfo) (pos-c ?cfo)))
)

;per asserire che mi trovo in una cella adiacente (step = (- ?i 1), (K-cell (pos-r ?r) (pos-c ?c)
(defrule do-LoadFood
    (declare (salience 10))
   ;(distance-fd (pos-start ? ?) (pos-end ?rfo ?cfo) (distance ?))
   	 (start-astar (pos-r ?rfo) (pos-c ?cfo))
	 (K-agent (pos-r ?ra) (pos-c ?ca))
	 (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
	     (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	 )
=>
	 
	 ;(assert (GRANDE))
)

	
; alcune azioni per testare il sistema
; (assert (exec (step 0) (action Forward)))
; (assert (exec (step 1) (action Inform) (param1 T4) (param2 2) (param3 accepted)))
; (assert (exec (step 2) (action LoadDrink) (param1 7) (param2 7)))
; (assert (exec (step 3) (action LoadFood) (param1 7) (param2 5)))
; (assert (exec (step 4) (action Forward)))
; (assert (exec (step 5) (action DeliveryDrink) (param1 5) (param2 6)))
; (assert (exec (step 6) (action DeliveryFood) (param1 5) (param2 6)))
; (assert (exec (step 7) (action Inform) (param1 T3) (param2 20) (param3 delayed)))
; (assert (exec (step 8) (action Inform) (param1 T3) (param2 16) (param3 delayed)))
; (assert (exec (step 9) (action Turnleft)))
; (assert (exec (step 10) (action Turnleft)))
; (assert (exec (step 11) (action CleanTable) (param1 5) (param2 6)))
; (assert (exec (step 12) (action Forward)))
; (assert (exec (step 13) (action Forward)))
; (assert (exec (step 14) (action Release) (param1 8) (param2 7)))
; (assert (exec (step 15) (action EmptyFood) (param1 8) (param2 5)))
; (assert (exec (step 16) (action Release) (param1 8) (param2 7)))