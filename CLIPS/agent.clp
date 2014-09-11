;// AGENT

(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

; è l'ultimo passaggio, la fotografia, perchè è atemporale.
; qui dentro ci serve per capire quando e dove si muovono gli agenti umani: il resto resta sempre cosi
; il tempo non ha senso se non facciamo roba sofisticata tipo previsione di spostamenti.
; per lui il mondo è così come l'ha percepito all'ultimo istante perc
(deftemplate K-cell  (slot pos-r) (slot pos-c)
                     (slot contains (allowed-values Wall Person Empty Parking Table Seat TB RB DD FD)))

(deftemplate K-agent
  (slot step)         ; step in cui il K-agent è stato modificato
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
(deftemplate start-astar (slot pos-r) (slot pos-c))
(deftemplate run-plane-astar (multislot pos-start) (multislot pos-end) (slot phase))

(deftemplate exec-order
  (slot step)   ;// l'environment incrementa il passo
  (slot action  (allowed-values Finish Inform))
  (slot param1)
  (slot param2)
  (slot param3)
)

; fl = food to load, dl = drink to load
; k-order-status
(deftemplate strategy-service-table
  (slot step)
  (slot table-id)
  (slot phase)
  (multislot pos-best-dispenser)
  (slot fl)
  (slot dl)
  (slot action)
)

(deftemplate last-intention (slot step))

(deftemplate strategy-distance-dispenser (multislot pos-start) (multislot pos-end) (slot distance) (slot type (allowed-values food drink trash-food trash-drink)))
(deftemplate strategy-best-dispenser (multislot pos-dispenser) (slot type (allowed-values DD FD RB TB)))
(deftemplate best-dispenser (slot distance) (multislot pos-best-dispenser))

; copia le prior cell sulla struttura K-cell
(defrule  beginagent1
  (declare (salience 11))
  (status (step 0))
  (not (exec (step 0)))
  (prior-cell (pos-r ?r) (pos-c ?c) (contains ?x))
=>
  (assert (K-cell (pos-r ?r) (pos-c ?c) (contains ?x)))
)

(defrule beginagent2
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
  (assert (last-intention (step -1)))
  (assert (worst-dispenser 1000))
)

;
; Copia la strutture Table su K-table
;
(defrule beginagent3
  (declare (salience 11))
  (status (step 0))
  (not (exec (step 0)))
  (Table (table-id ?tid) (pos-r ?r) (pos-c ?c) )
=>
  (assert (K-table (step 0) (time 0) (pos-r ?r) (pos-c ?c) (table-id ?tid) (clean yes) (l-drink 0) (l-food 0) ))
)

(defrule ask_act
  ?f <-   (status (step ?i))
=>
  (printout t crlf crlf)
  (printout t "action to be executed at step:" ?i)
  (printout t crlf crlf)
  (modify ?f (result no))
)

(defrule exec_act
  (declare (salience 100))
  (status (step ?i))
  (exec (step ?i))
=>
  (focus MAIN))

; Regola per avviare la ricerca con ASTAR se non è stato calcolato un piano per arrivare in una determinata posizione.
(defrule go-astar
    (declare (salience 15))
    (start-astar (pos-r ?r) (pos-c ?c))
    (K-agent (pos-r ?r1) (pos-c ?c1))
    (not (plane (pos-start ?r1 ?c1 ?d) (pos-end ?r ?c)))
=>
    (assert (goal-astar ?r ?c))
    (focus ASTAR)
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
