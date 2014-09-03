;// AGENT

(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

; è l'ultimo passaggio, la fotografia, perchè è atemporale.
; è l'ultimo passaggio, la fotografia, perchè è atemporale.
; qui dentro ci serve per capire quando e dove si muovono gli agenti umani: il resto resta sempre cosi
; il tempo non ha senso se non facciamo roba sofisticata tipo previsione di spostamenti.
; per lui il mondo è così come l'ha percepito all'ultimo istante perc

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
(deftemplate last-perc (slot step) (slot type (allowed-values movement load)))
;(deftemplate last-perc-load (slot step))

(deftemplate plane (multislot pos-start) (multislot pos-end) (multislot exec-astar-sol) (slot cost))
(deftemplate start-astar (slot type) (slot pos-r) (slot pos-c))
(deftemplate run-plane-astar (multislot pos-start) (multislot pos-end))

; memorizza la quantità di roba che l'agente deve caricare o scaricare
(deftemplate agent-truckload-counter (slot type)(slot qty))

(deftemplate distance-fd (multislot pos-start) (multislot pos-end) (slot distance))
(deftemplate distance-dd (multislot pos-start) (multislot pos-end) (slot distance))

; copia le prior cell sulla struttura K-cell
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
    (assert (last-perc (step -1) (type movement)))
    (assert (last-perc (step -1) (type load)))
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

; Regola per avviare la ricerca con ASTAR se non è stato calcolato un piano.
(defrule go-astar
  (declare (salience 15))
	(start-astar (type food|drink|del_food|del_drink) (pos-r ?r) (pos-c ?c))

	(K-agent (pos-r ?r1) (pos-c ?c1))
	(not (plane (pos-start ?r1 ?c1) (pos-end ?r ?c)))
=>
    (assert (goal-astar ?r ?c))
    (focus ASTAR)
)

; Regola per non ripetere astar su un percorso su cui è stato appena calcolato il piano e per eseguire un piano
(defrule clean-start-astar
    (declare (salience 15))
    ?f1<-(start-astar (pos-r ?r) (pos-c ?c))
		(plane (pos-start ?r1 ?c1) (pos-end ?r ?c))
=>
    (retract ?f1)
	  (assert (run-plane-astar (pos-start ?r1 ?c1) (pos-end ?r ?c)))
)

;regola per eseguire astar dopo che è stato asserito un fatto con distanza man. per il food dispenser
;aggiunto il contatore che servirà per eseguire le load fintanto che devo caricare food
(defrule start-astar-fd
    (declare (salience 10))
    ?f1<-(distance-fd (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance ?))
    (msg-to-agent (step ?s) (food-order ?fo))
     =>
    (retract ?f1)
		(assert (start-astar (type food) (pos-r ?rfo) (pos-c ?cfo)))
		(assert (agent-truckload-counter (type loadFood)(qty ?fo)))
)

;regola per caricare il cibo
;dopo che è stata eseguità la modify ritratto il fatto start-astar per non far ri-eseguire la do-Load
(defrule do-LoadFood
    (declare (salience 10))
   ;(distance-fd (pos-start ? ?) (pos-end ?rfo ?cfo) (distance ?))
   	(msg-to-agent (step ?s) (food-order ?fo))
	?f2<-(agent-truckload-counter (type loadFood)(qty ?q))
	(test (> ?q 0))
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
   	 (FoodDispenser (FD-id FD1) (pos-r ?rfo) (pos-c ?cfo))
	 (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
	     (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	 )
	 ;(not (exec (step =(- ?ks 1))(action LoadFood)(param1 ?rfo)(param2 ?cfo)))
=>
	 (modify ?f2 (qty (- ?q 1)))
	 (assert (exec (step ?ks) (action LoadFood) (param1 ?rfo) (param2 ?cfo)))
)

;regola per eseguire astar dopo che è stato asserito un fatto con distanza man. per il drink dispenser
;aggiunto il contatore che servirà per eseguire le load fintanto che devo caricare drink
(defrule start-astar-dd
    (declare (salience 10))
    ?f1<-(distance-dd (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance ?))
    (msg-to-agent (step ?s) (drink-order ?do))
     =>
    (retract ?f1)
		(assert (start-astar (type drink) (pos-r ?rfo) (pos-c ?cfo)))
		(assert (agent-truckload-counter (type loadDrink)(qty ?do)))
)

;come do-loadFood con l'unica differenza che qui carica le bevande
(defrule do-LoadDrink
    (declare (salience 10))
   ;(distance-dd (pos-start ? ?) (pos-end ?rfo ?cfo) (distance ?))
   	 (msg-to-agent (step ?s) (drink-order ?do))
   	 ?f2<-(agent-truckload-counter (type loadDrink)(qty ?q))
   	 (test (> ?q 0))
	 (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	 (test (< (+ ?lf ?ld) 4))
   	 (DrinkDispenser (DD-id DD1) (pos-r ?rfo) (pos-c ?cfo))
	 (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
	     (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	 )
	 ;(not (exec (step =(- ?ks 1))(action LoadFood)(param1 ?rfo)(param2 ?cfo)))
=>
	 (modify ?f2 (qty (- ?q 1)))
	 (assert (exec (step ?ks) (action LoadDrink) (param1 ?rfo) (param2 ?cfo)))
)

(defrule start-astar-delivery_f
    (declare (salience 5))
    (msg-to-agent (sender ?t))
    (Table (table-id ?t) (pos-r ?rfo) (pos-c ?cfo))

     =>
	(assert (start-astar (type del_food) (pos-r ?rfo) (pos-c ?cfo)))
	(assert (do-deliveryf))
)

(defrule do-DeliveryFood
    (declare (salience 5))
   	 (msg-to-agent (step ?s) (sender ?t) (food-order ?fo))
   	 (Table (table-id ?t) (pos-r ?rfo) (pos-c ?cfo))
   	 ?f1<-(plan-executed)
   	 ?f2<-(do-deliveryf)
	 (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld))
	 (test (> ?lf 0))
	 (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
	     (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	 )
	 (not (exec (step =(- ?ks 1))(action DeliveryFood)(param1 ?rfo)(param2 ?cfo)))
=>
	 (retract ?f1)
	 (retract ?f2)
	 (assert (exec (step ?ks) (action DeliveryFood) (param1 ?rfo) (param2 ?cfo)))
)

(defrule start-astar-delivery_d
    (declare (salience 5))
    (msg-to-agent (sender ?t))
    (Table (table-id ?t) (pos-r ?rfo) (pos-c ?cfo))

     =>
	(assert (start-astar (type del_drink) (pos-r ?rfo) (pos-c ?cfo)))
	(assert (do-deliveryd))
)

(defrule do-DeliveryDrink
    (declare (salience 5))
   	 (msg-to-agent (step ?s) (sender ?t) (food-order ?fo))
   	 (Table (table-id ?t) (pos-r ?rfo) (pos-c ?cfo))
   	 ?f1<-(plan-executed)
   	 ?f2<-(do-deliveryd)
	 (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld))
	 (test (> ?ld 0))
	 (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
	     (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	     (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
	 )
=>
	 (retract ?f1)
	 (retract ?f2)
	 (assert (exec (step ?ks) (action DeliveryFood) (param1 ?rfo) (param2 ?cfo)))
)

; rimuove il counter degli oggetti da caricare / scaricare nel caso l'agente abbia finito il suo lavoro (ossia il counter è a 0, gli oggetti sono stati spostati tutti)
(defrule clean-truckload-counter
  (declare (salience 10))
  ?f1 <- (agent-truckload-counter (type ?t)(qty ?do))
  (test (= ?do 0))
  =>
  (retract ?f1)
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
