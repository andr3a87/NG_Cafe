;// __________________________________________________________________________________________
;// REGOLE PER INTERPRETARE LE PERCEZIONI VISIVE (N, S, E, O)
;// ¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯

; Le percezioni modificano le K-cell (agente orientato west)
(defrule k-percept-west
  (declare (salience 100))
    (status (step ?s))
    ?ka <- (K-agent) ; recupera il K-agent
    ?fs <- (last-perc (step ?old-s))
    (test (> ?s ?old-s))
    (perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west)
    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9))

    ?f1 <- (K-cell (pos-r =(- ?r 1))  (pos-c =(- ?c 1)))
    ?f2 <- (K-cell (pos-r ?r)         (pos-c =(- ?c 1)))
    ?f3 <- (K-cell (pos-r =(+ ?r 1))  (pos-c =(- ?c 1)))
    ?f4 <- (K-cell (pos-r =(- ?r 1))  (pos-c ?c))
    ?f5 <- (K-cell (pos-r ?r)         (pos-c ?c) )
    ?f6 <- (K-cell (pos-r =(+ ?r 1))  (pos-c ?c) )
    ?f7 <- (K-cell (pos-r =(- ?r 1))  (pos-c =(+ ?c 1)))
    ?f8 <- (K-cell (pos-r ?r)         (pos-c =(+ ?c 1)))
    ?f9 <- (K-cell (pos-r =(+ ?r 1))  (pos-c =(+ ?c 1)))
=>
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west)) ; Modifica il K-agent
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


; Le percezioni modificano le K-cell (agente orientato east)
(defrule k-percept-east
  (declare (salience 100))
    (status (step ?s))
    ?ka <- (K-agent)
    ?fs <- (last-perc (step ?old-s))
    (test (> ?s ?old-s))
    (perc-vision (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east)
    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9))

    ?f1 <- (K-cell (pos-r =(+ ?r 1))  (pos-c =(+ ?c 1)))
    ?f2 <- (K-cell (pos-r ?r)         (pos-c =(+ ?c 1)))
    ?f3 <- (K-cell (pos-r =(- ?r 1))  (pos-c =(+ ?c 1)))
    ?f4 <- (K-cell (pos-r =(+ ?r 1))  (pos-c ?c))
    ?f5 <- (K-cell (pos-r ?r)         (pos-c ?c))
    ?f6 <- (K-cell (pos-r =(- ?r 1))  (pos-c ?c))
    ?f7 <- (K-cell (pos-r =(+ ?r 1))  (pos-c =(- ?c 1)))
    ?f8 <- (K-cell (pos-r ?r)         (pos-c =(- ?c 1)))
    ?f9 <- (K-cell (pos-r =(- ?r 1))  (pos-c =(- ?c 1)))
=>
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east)) ; Modifica il K-agent
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
  (declare (salience 100))
    (status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
    ?fs <- (last-perc (step ?old-s)(type movement))
    (test (> ?s ?old-s))
    (perc-vision
    (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south)
        (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
        (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
        (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)

    )
    ?ka <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

    ?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f2 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (K-cell (pos-r ?r)       (pos-c =(+ ?c 1)))
    ?f5 <- (K-cell (pos-r ?r)       (pos-c ?c))
    ?f6 <- (K-cell (pos-r ?r)       (pos-c =(- ?c 1)))
    ?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
    ?f8 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
=>
    (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south))
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
  (declare (salience 100))
    (status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
    ?fs <- (last-perc (step ?old-s) (type movement))
    (test (> ?s ?old-s))
    (perc-vision
            (time ?t) (step ?s) (pos-r ?r) (pos-c ?c) (direction north)
            (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
            (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
            (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
    )
    ?ka <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

    ?f1 <- (K-cell (pos-r =(+ ?r 1))    (pos-c =(- ?c 1)))
    ?f2 <- (K-cell (pos-r =(+ ?r 1))    (pos-c ?c))
    ?f3 <- (K-cell (pos-r =(+ ?r 1))    (pos-c =(+ ?c 1)))
    ?f4 <- (K-cell (pos-r ?r)           (pos-c =(- ?c 1)))
    ?f5 <- (K-cell (pos-r ?r)           (pos-c ?c))
    ?f6 <- (K-cell (pos-r ?r)           (pos-c =(+ ?c 1)))
    ?f7 <- (K-cell (pos-r =(- ?r 1))    (pos-c =(- ?c 1)))
    ?f8 <- (K-cell (pos-r =(- ?r 1))    (pos-c ?c))
    ?f9 <- (K-cell (pos-r =(- ?r 1))    (pos-c =(+ ?c 1)))
=>
  (modify ?ka (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north))
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

;; =======================
;; Percept LOAD / DELIVERY
;; =======================

(defrule k-percept-load-food
  (declare(salience 100))
    (perc-load (time ?t) (step ?s) (load yes))
    ?fs <- (last-perc (step ?old-s) (type load))
    (test (> ?s ?old-s) )
    ; modifica l'angete
    ?f1<-(K-agent (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
    (exec (step =(- ?s 1))(action LoadFood))
  =>
    ; modifica l'agente
    (modify ?f1(l-food(+ ?lf 1)))
    ; modifica last-perc
    (modify ?fs (step ?s))
)

(defrule k-percept-load-drink
  (declare(salience 100))
  (perc-load (time ?t) (step ?s) (load yes))
  ?fs <- (last-perc (step ?old-s) (type load))
  (test (> ?s ?old-s))
  ?f1<-(K-agent (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (exec (step =(- ?s 1))(action LoadDrink))
=>
  ; modifica l'agente
  (modify ?f1(l-drink(+ ?ld 1)))
  ; modifica last-perc
  (modify ?fs (step ?s))
)

;
; DELIVERIES TO TABLE
;

(defrule k-percept-delivery-food
  (declare(salience 100))
  (perc-load (time ?t) (step ?s) (load yes))
  ?fs <- (last-perc (step ?old-s) (type load))
  (test (> ?s ?old-s) )
  ?f1<-(K-agent (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (exec (step =(- ?s 1)) (action DeliveryFood) (param1 ?rfo) (param2 ?cfo))
  ?f2<-(K-table (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (l-food ?klf))
=>
  (modify ?f1(l-food(- ?lf 1)))
  (modify ?fs (step ?s))
  ; modifica tavolo, aggiungiamo un food al tavolo
  (modify ?f2 (step ?s) (time ?t) (l-food (+ ?klf 1)) (clean no))
)

(defrule k-percept-delivery-drink
  (declare(salience 100))
  (perc-load (time ?t) (step ?s) (load yes))
  ?fs <- (last-perc (step ?old-s) (type load))
  (test (> ?s ?old-s))
  ?f1<-(K-agent (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (exec (step =(- ?s 1))(action DeliveryDrink) (param1 ?rfo) (param2 ?cfo))
  ?f2<-(K-table (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (l-drink ?kld))
=>
  (modify ?f1(l-drink(- ?ld 1)))
  (modify ?fs (step ?s))
  ; modifica tavolo, aggiungiamo un drink al tavolo
  (modify ?f2 (step ?s) (time ?t) (l-drink (+ ?kld 1)) (clean no))
)

; permette di
(defrule k-percept-delivery-final-food
  (declare(salience 100))
  ; perception
  (perc-load (time ?t) (step ?s) (load no))
  ?fs <- (last-perc (step ?old-s) (type load))
  (test (> ?s ?old-s))
  ; k-agent
  ?f1<-(K-agent (l-food ?lf) (l_d_waste no) (l_f_waste no))
  (test (= ?lf 1))

  (exec (step =(- ?s 1))(action DeliveryFood) (param1 ?rfo) (param2 ?cfo))
  ; k-table
  ?f2<-(K-table (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (l-food ?klf))
  =>
  ; modifica l'agente
  (modify ?f1 (l-food 0))
  (modify ?fs (step ?s))
  ; modifica tavolo, aggiungiamo il food
  (modify ?f2 (step ?s) (time ?t) (l-food (+ ?klf 1)) (clean no))
)

(defrule k-percept-delivery-final-drink
  (declare(salience 100))
  (perc-load (time ?t) (step ?s) (load no))
  ?fs <- (last-perc (step ?old-s) (type load))
  (test (> ?s ?old-s))

  ; controllo che l'agente abbia esattamente un drink
  ?f1<-(K-agent (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (test (= ?ld 1))

  (exec (step =(- ?s 1))(action DeliveryDrink) (param1 ?rfo) (param2 ?cfo))
  ; k-table
  ?f2<-(K-table (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (l-drink ?kld))
  =>
  ; modifica l'agente
  (modify ?f1 (l-drink 0))
  (modify ?fs (step ?s))
  ; modifica tavolo, aggiungiamo il drink
  (modify ?f2 (step ?s) (time ?t) (l-drink (+ ?kld 1)) (clean no))
)

;; =======================
;; Percept CLEAN / RELEASE / EMPTYFOOD
;; =======================

(defrule k-percept-clean-table_1
  (declare(salience 100))
  (status (step ?current))
  (exec (step =(- ?current 1))(action CleanTable) (param1 ?rfo) (param2 ?cfo))
  ?f1 <- (K-agent (l-drink ?a-ld) (l-food ?a-lf))
  (test (= (+ ?a-ld ?a-lf) 0))
  ?f2 <- (K-table (l-drink ?t-ld&:(> ?t-ld 0)) (l-food 0) (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (clean no))
=>
  (modify ?f2 (l-drink 0) (clean yes))
  (modify ?f1 (l_d_waste yes))
)

(defrule k-percept-clean-table_2
  (declare(salience 100))
  (status (step ?current))
  (exec (step =(- ?current 1))(action CleanTable) (param1 ?rfo) (param2 ?cfo))

  ?f1 <- (K-agent (l-drink ?a-ld) (l-food ?a-lf))
  (test (= (+ ?a-ld ?a-lf) 0))

  ?f2 <- (K-table (l-food ?t-lf&:(> ?t-lf 0)) (l-drink 0) (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (clean no))
=>
  (modify ?f2 (l-food 0) (clean yes))
  (modify ?f1 (l_f_waste yes))
)

(defrule k-percept-clean-table_3
  (declare(salience 100))
  (status (step ?current))
  (exec (step =(- ?current 1))(action CleanTable) (param1 ?rfo) (param2 ?cfo))

  ?f1 <- (K-agent (l-drink ?a-ld) (l-food ?a-lf))
  (test (= (+ ?a-ld ?a-lf) 0))

  ?f2 <- (K-table (table-id ?tid) (pos-r ?rfo) (pos-c ?cfo) (clean no))
=>
  (modify ?f2 (clean yes) (l-food 0) (l-drink 0))
  (modify ?f1 (l_d_waste yes) (l_f_waste yes))
)

(defrule k-percept-release
  (declare(salience 100))
  (status (step ?current))
  (exec (step =(- ?current 1))(action Release) (param1 ?rfo) (param2 ?cfo))

  ?f1 <- (K-agent (l_d_waste yes))
=>
  (modify ?f1 (l_d_waste no))
)

(defrule k-percept-empty-food
  (declare(salience 100))
  (status (step ?current))
  (exec (step =(- ?current 1))(action EmptyFood) (param1 ?rfo) (param2 ?cfo))

  ?f1 <- (K-agent (l_f_waste yes))
=>
  (modify ?f1 (l_f_waste no))
)
