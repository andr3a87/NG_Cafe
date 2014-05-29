;// AGENT


(defmodule AGENT (import MAIN ?ALL)(export ?ALL))

; � l'ultimo passaggio, la fotografia, perch� � atemporale.
; � l'ultimo passaggio, la fotografia, perch� � atemporale.
; qui dentro ci serve per capire quando e dove si muovono gli agenti umani: il resto resta sempre cosi
; il tempo non ha senso se non facciamo roba sofisticata tipo previsione di spostamenti.
; per lui il mondo � cos� come l'ha percepito all'ultimo istante.eprc


(deftemplate K-cell  (slot pos-r) (slot pos-c) 
                   (slot contains (allowed-values Wall Person  Empty Parking Table Seat TrashBasket
                                                      RecyclableBasket DrinkDispenser FoodDispenser)))



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

(deftemplate inform
	(slot request-id)
    (slot table) 
	(slot answer) 
	
)
        
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
    (status (step ?i))
    (exec (step ?i))
 => (focus MAIN))

; PERCEZIONI PER IL WEST TRASFORMATE SULLE K-CELL
(defrule k-percept-west

	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision 
        (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
        (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
    )
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

    ?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (K-cell (pos-r ?r)  	(pos-c =(- ?c 1)))
	?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
	?f4 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f5 <- (K-cell (pos-r ?r)  	(pos-c ?c) )
	?f6 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) )
	?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))	
	?f8 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))	
	?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))

=> 
    (modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west))
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)

; PERCEZIONI PER IL EAST TRASFORMATE SULLE K-CELL
(defrule k-percept-east
	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision 
        (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
	    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
	)
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

	?f1 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))
	?f2 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))
	?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f5 <- (K-cell (pos-r ?r)  	(pos-c ?c))
	?f6 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))	
	?f8 <- (K-cell (pos-r ?r)	(pos-c =(- ?c 1)))	
	?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
=> 
    (modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east))
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)


; PERCEZIONI PER IL SOUTH TRASFORMATE SULLE K-CELL
(defrule k-percept-south
    
	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision 
        (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
	    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)

	)
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

	?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f4 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))
	?f5 <- (K-cell (pos-r ?r)  	(pos-c ?c))
	?f6 <- (K-cell (pos-r ?r)  	(pos-c =(- ?c 1)))
	?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f8 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
=> 
	(modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south))
    (modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)

; PERCEZIONI PER IL NORTH TRASFORMATE SULLE K-CELL
(defrule k-percept-north

	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s))
	(test (> ?s ?old-s))
	(perc-vision 
        (time ?t) (step ?s) (pos-r ?r) (pos-c ?c) (direction north) 
	    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
	)
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

    ?f1 <- (K-cell (pos-r =(+ ?r 1))	(pos-c =(- ?c 1)))
	?f2 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (K-cell (pos-r ?r) 	(pos-c =(- ?c 1)))
	?f5 <- (K-cell (pos-r ?r) 	(pos-c ?c))
	?f6 <- (K-cell (pos-r ?r) 	(pos-c =(+ ?c 1)))
	?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f8 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    => 
	(modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north))
    (modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))

)

(defrule answer-msg-order
	?f1<-(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
=>
	(assert (inform (request-id ?f1) (table ?sen) (answer accepted)))
	
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