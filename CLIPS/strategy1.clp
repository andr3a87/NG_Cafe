;strategia FIFO un tavolo alla volta

;
; FASE 1 della Strategia: Ricerca di un tavolo da servire, rispondere alle richieste di ordinazione da parte dei tavoli.
;

;Attiva quando ricevo un ordine da un tavolo Inform con accepted
(defrule answer-msg-order1
	(declare (salience 70))
	(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (pos-r ?r)(pos-c ?c)(table-id ?sen) (clean yes))
=>
	(assert (exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
)

;Attiva quando ricevo un ordine da un tavolo sporco che per specifica assumiamo abbia inviato precedentemente una finish. Inform con delayed
(defrule answer-msg-order2
	(declare (salience 70))
	(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (table-id ?sen) (clean no))
=>
  (assert (exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed)))
)

;Se ho inviato delle Inform con accepted, e non sto servendo nessun tavolo, allora devo prendermi l'impegno di servire un tavolo. Quale? Strategia FIFO
(defrule strategy-start-search-service-table
	(declare (salience 70))
	(exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
	;
	; da controllare, controlla che non ci siano altre strategie per altri tavoli attive
	; ATTENZIONE!
	;
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
	?f <- (strategy-service-table (step ?as) (table-id ?table) (phase 1))
	(exec (step ?s2&:(< ?s2 ?current)) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
	(last-intention (step ?s1))
	(test (> ?s2 ?s1))
	(test (> ?s2 ?as))
=>
	(modify ?f (step ?s2)(table-id ?sen))
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
; FASE 2 della Strategia: Individuare il dispancer più vicino
;

(defrule initializa-phase2
	(declare (salience 75))
	(strategy-service-table (table-id ?id) (phase 2))
=>
	(assert (best-dispancer (distance 100000) (pos-best-dispancer null null)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun food-dispancer
(defrule distance-manhattan-fo
	(declare (salience 70))
	(strategy-service-table (table-id ?id) (phase 2))
	(msg-to-agent (step ?s) (sender ?id) (food-order ?fo))
	(test (> ?fo 0))
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(K-cell (pos-r ?rfo) (pos-c ?cfo) (contains FD))
	=>
	(assert (strategy-distance-dispancer (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type food)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun drink-dispancer
(defrule distance-manhattan-do
	(declare (salience 70))
	(strategy-service-table (table-id ?id) (phase 2))
	(msg-to-agent (step ?s) (sender ?id) (drink-order ?do))
	(test (> ?do 0))
	(K-agent (pos-r ?ra)(pos-c ?ca))
	(K-cell (pos-r ?rdo) (pos-c ?cdo) (contains DD))
	=>
	(assert (strategy-distance-dispancer (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance (+ (abs(- ?ra ?rdo)) (abs(- ?ca ?cdo)))) (type drink)))
)

;Regola che cerca il dispancer più vicino
(defrule search-best-dispancer
	(declare (salience 60))
	?f1<-(best-dispancer (distance ?wd))
	(strategy-distance-dispancer  (pos-start ?ra ?ca) (pos-end ?rd ?cd) (distance ?d&:(< ?d ?wd)))
=>
	(modify ?f1 (distance ?d) (pos-best-dispancer ?rd ?cd))
)

;Trovato il dispancer più vicino passo alla fase 3
;Questa regola mi serve per indicare il fatto che non vi sono dispancer più vicini di quello trovato. Blocca la ricerca.
(defrule found-best-dispancer
	(declare (salience 60))
	?f1<-(best-dispancer (distance ?wd) (pos-best-dispancer ?rd ?cd))
	(not(strategy-distance-dispancer  (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d&:(< ?d ?wd))))
	?f2<-(strategy-service-table (table-id ?id) (phase 2))
=>
	(modify ?f2 (phase 3) (pos-best-dispancer ?rd ?cd))
	(retract ?f1)
)

;
; FASE 3 della Strategia: Pianificare con astar un piano per raggiungere il dispancer più vicino. Eseguire il piano
;

;regola per avviare astar
;aggiunto il contatore che servirà per eseguire le load fintanto che devo caricare food

;(defrule start-astar-fd
;    (declare (salience 10))
;    (strategy-service-table (table-id ?id) (phase 3) (pos-best-dispancer ?rdo ?cdo) )
;    (msg-to-agent (step ?s) (food-order ?fo))
;     =>
;    ;(retract ?f1)
;		(assert (start-astar (type food) (pos-r ?rfo) (pos-c ?cfo)))
;		(assert (agent-truckload-counter (type loadFood) (qty ?fo)))
;)

;regola per eseguire astar
;aggiunto il contatore che servirà per eseguire le load fintanto che devo caricare drink

;(defrule start-astar-dd
;    (declare (salience 10))
;    ?f1<-(distance-dd (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance ?))
;    (msg-to-agent (step ?s) (drink-order ?do))
;     =>
;    (retract ?f1)
;		(assert (start-astar (type drink) (pos-r ?rfo) (pos-c ?cfo)))
;		(assert (agent-truckload-counter (type loadDrink)(qty ?do)))
;)