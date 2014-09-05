;strategia FIFO un tavolo alla volta

;Regole per rispondere alla richiesta ordini da parte dei tavoli.
;Attiva quando ricevo un ordine da un tavolo Inform con accepted
(defrule answer-msg-order1
	(declare (salience 100))
	(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (pos-r ?r)(pos-c ?c)(table-id ?sen) (clean yes))
=>
	(assert (exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
)

;Attiva quando ricevo un ordine da un tavolo sporco che per specifica assumiamo abbia inviato precedentemente una finish. Inform con delayed
(defrule answer-msg-order2
	(declare (salience 100))
	(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (table-id ?sen) (clean no))
=>
  (assert (exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed)))
)

;
; FASE 1 della Strategia: Ricerca di un tavolo da servire.
;

;Se ho inviato delle Inform con accepted, e non sto servendo nessun tavolo, allora devo prendermi l'impegno di servire un tavolo. Quale? Strategia FIFO
(defrule strategy-start-search-service-table
	(declare (salience 70))
	(exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))

  ; @TODO cambiare per gestire più tavoli
	(not (strategy-service-table (table-id ?id) (phase ?ph)))
	(last-intention (step ?s1))
	(test (> ?s ?s1))
=>
	(assert (strategy-service-table (step -1) (table-id -1) (phase 1)))
)

;Individua il tavolo da servire secondo la strategia FIFO
;Effettua una ricerca all'indietro all'interno dei fatti exec per trovare il tavolo, in ordine di tempo più vecchio, che ha effettuato un'ordinazione non ancora servita.
(defrule strategy-search-table-to-serve
	(status (step ?current))
	?f <- (strategy-service-table (step ?as) (table-id ?) (phase 1))
	(exec (step ?s2&:(< ?s2 ?current)) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
	(last-intention (step ?s1))
	(test (> ?s2 ?s1))
	(test (> ?s2 ?as)) ; da controllare, forse ridondante, il discorso dell & potrebbe già selezionare la più piccolare
	(msg-to-agent (request-time ?t) (step ?s2) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
=>
	(modify ?f (step ?s2) (table-id ?sen) (fl ?fo) (dl ?do))
)

;Trovato il tavolo, passo alla fase due della strategia.
;Questa regola mi serve per indicare il fatto che non vi sono ordinazioni più vecchie di quella trovata non ancora servita. Blocca la ricerca.
(defrule strategy-found-table-to-serve
	(last-intention (step ?s1))
	?f <- (strategy-service-table (table-id ?id) (phase 1))
	(not (exec (step ?s2&:(< ?s2 ?s1)) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
=>
	(modify ?f (table-id ?id) (phase 2))
)

;
; FASE 2 della Strategia: Individuare il dispenser più vicino
;

;
(defrule strategy-initialize-phase2
	(declare (salience 75))
	(strategy-service-table (table-id ?id) (phase 2))
=>
	(assert (best-dispenser (distance 100000) (pos-best-dispenser null null)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun food-dispenser
(defrule distance-manhattan-fo
	(declare (salience 70))
	(strategy-service-table (table-id ?id) (phase 2) (fl ?fl))
	(test (> ?fl 0))
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(K-cell (pos-r ?rfo) (pos-c ?cfo) (contains FD))
	=>
	(assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type food)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun drink-dispenser
(defrule distance-manhattan-do
	(declare (salience 70))
	(strategy-service-table (table-id ?id) (phase 2) (dl ?dl))
	(test (> ?dl 0))
	(K-agent (pos-r ?ra)(pos-c ?ca))
	(K-cell (pos-r ?rdo) (pos-c ?cdo) (contains DD))
	=>
	(assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance (+ (abs(- ?ra ?rdo)) (abs(- ?ca ?cdo)))) (type drink)))
)

;Regola che cerca il dispenser più vicino
(defrule search-best-dispenser
	(declare (salience 60))
	?f1<-(best-dispenser (distance ?wd))
	(strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rd ?cd) (distance ?d&:(< ?d ?wd)))
=>
	(modify ?f1 (distance ?d) (pos-best-dispenser ?rd ?cd))
)

;Trovato il dispenser più vicino passo alla fase 3
;Questa regola mi serve per indicare il fatto che non vi sono dispenser più vicini di quello trovato. Blocca la ricerca.
; @TODO ricordarsi di pulire (strategy-best-dispenser) alla fase 4
(defrule found-best-dispenser
	(declare (salience 60))
	?f1<-(best-dispenser (distance ?wd) (pos-best-dispenser ?rd ?cd))
	(not(strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d&:(< ?d ?wd))))
	?f2<-(strategy-service-table (table-id ?id) (phase 2))
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains ?c))
=>
	(modify ?f2 (phase 3))
	(assert (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c)))
	(retract ?f1)
)

;
; FASE 3 della Strategia: Pianificare con astar un piano per raggiungere il dispenser più vicino. Eseguire il piano.
;

; pulisce le distanze ai dispensers
(defrule clean-strategy-distance-dispenser
  (declare (salience 80))
  (strategy-service-table (table-id ?id) (phase 3))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1 <- (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d))
=>
  (retract ?f1)
)

;(defrule initialize-phase3
;	(declare (salience 75))
;	(strategy-service-table (table-id ?id) (phase 3))
;	(msg-to-agent (step ?s) (sender ?id) (food-order ?fo) (drink-order ?do))
;=>
;	(assert (agent-truckload-counter (table ?id) (type FD) (qty ?fo)))
;	(assert (agent-truckload-counter (table ?id) (type DD) (qty ?do)))
;)

;regole per avviare astar
(defrule start-astar-to-dispenser
    (declare (salience 70))
    (strategy-service-table (table-id ?id) (phase 3) (step ?s) )
    (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
    (msg-to-agent (step ?s) (sender ?id) (food-order ?fo))
=>
	(assert (start-astar (pos-r ?rd) (pos-c ?cd)))
)

;Se esiste un piano per andare in una determinata posizione, e ho l'intenzione di andarci allora eseguo il piano.
(defrule clean-start-astar
    (declare (salience 15))
    (strategy-service-table (table-id ?id) (phase 3))
    (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
    ?f1<-(start-astar (pos-r ?rd) (pos-c ?cd))
	(plane (pos-start ?r1 ?c1) (pos-end ?rd ?cd))
=>
    (retract ?f1)
	(assert (run-plane-astar (pos-start ?r1 ?c1) (pos-end ?rd ?cd)))
)

;Eseguito il piano, il robot si trova vicino ad dispenser piu vicino.
(defrule go-phase4
	?f1<-(plan-executed)
	?f2<-(strategy-service-table (table-id ?id) (phase 3))
	(strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
=>
	(retract ?f1)
	(modify ?f2 (phase 4))
)

;
;  FASE 4 della Strategia: Il robot arrivato al dispenser carica
;

;regola per caricare il cibo
(defrule strategy-do-LoadFood
    (declare (salience 70))
    ?f1 <- (strategy-service-table (table-id ?id) (phase 4) (fl ?fl))
    (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type FD))
	(test (> ?fl 0))
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
=>
	(modify ?f1 (fl (- ?fl 1)))
	(assert (exec (step ?ks) (action LoadFood) (param1 ?rd) (param2 ?cd)))
)

;regola per caricare il drink
(defrule strategy-do-LoadDrink
    (declare (salience 70))
    ?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl))
    (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type DD))
	(test (> ?dl 0)) ; ci sono ancora drink da caricare
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
=>
	(modify ?f1 (dl (- ?dl 1)))
	(assert (exec (step ?ks) (action LoadDrink) (param1 ?rd) (param2 ?cd)))
)

(defrule strategy-clean-best-dispenser
	(declare (salience 70))
	?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl) (fl ?fl)) ;sei in fase 4
	?f2 <- (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?type)) ;c'è un fatto best dispenser da rimuovere
	(test (or (= ?dl 0) (= ?fl 0)))  ; hai caricato tutti i drink o food per quell'ordine
=>
	(retract ?f2)
	(modify ?f1 (phase 4.5))
)

;
; FASE 4.5 della Strategia: Controllo se ritornare alla fase 2 per caricare altra roba o consegnare al tavolo
;

(defrule strategy-return-phase2
	?f1<-(strategy-service-table (table-id ?id) (phase 4.5) (dl ?dl) (fl ?fl))
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
	(test (or (> ?dl 0) (> ?fl 0)))
=>
	(modify ?f1 (phase 2))
)

;(defrule strategy-go-phase5
;	?f1<-(strategy-service-table (table-id ?id) (phase 4.5) (dl ?dl) (fl ?fl))
;	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
;	(test (< (+ ?lf ?ld) 4))
;	(test (or (> ?dl 0) (> ?fl 0)))
;=>
;	(modify ?f1 (phase 2))
;)
