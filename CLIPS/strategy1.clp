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
	not (intention-service-table (sender ?sen))
	(last-intention (step ?s1))
	(test (> s s1))
	=>
	(assert (strategy-table-to-serve (step -1) (sen -1) (done no)))
)

(defrule strategy-search-table-to-serve
	(status (step ?current)) 
	?f <- (strategy-table-to-serve (step ?s1) (sen ?sen1) (done no))
	(exec (step ?s2&:(< ?s2 ?current)) (action Inform) (param1 ?sen2) (param2 ?t) (param3 accepted))
	(last-intention (step ?s1))
	(test (> ?s s1))
	=> 
	(modify ?f (step ?s2) (sen ?sen2))  
)

(defrule strategy-found-table-to-serve 
	(status (step ?current))
	?f<-(strategy-table-to-serve (step ?s) (sen ?sen) (done no))
	(not (exec (step ?s&:(< ?s ?current))))
	=> 
	(modify ?f (done yes))  
)

(defrule strategy-add-intention-service-table
	?f <- (strategy-table-to-serve (step ?s) (sen ?sen) (done yes))
	=>
	(assert (intention-service-table (sender ?sen))
	(retract ?f)
)

