;strategia FIFO un tavolo alla volta

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

;salience ????
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

(defrule strategy-found-table-to-serve
	(last-intention (step ?s1))
	?f <- (strategy-service-table (table-id ?id) (phase 1))
	(not (exec (step ?s2&:(< ?s2 ?s1)) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
	=>
	(modify ?f (table-id ?id) (phase 2))
)
