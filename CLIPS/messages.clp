; Un ordine da parte del tavolo arriva solo se il tavolo è pulito o se è sporco ma è stata inviata in precedenza una finish.
; Attiva quando ricevo un ordine da un tavolo pulito. Inform con accepted

(defrule answer-msg-order1
	?f1<-(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (pos-r ?r)(pos-c ?c)(table-id ?sen) (clean yes))
=>
	(assert (exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
	(assert (start-astar (pos-r ?r) (pos-c ?c)))
)
 
;Attiva quando ricevo un ordine da un tavolo sporco che per specifica assumiamo abbia inviato precedentemente una finish. Inform con delayed
(defrule answer-msg-order2
	?f1<-(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (table-id ?sen) (clean no))
=>
    (assert (exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed)))
)
