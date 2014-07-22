; Un ordine da parte del tavolo arriva solo se il tavolo è pulito o se è sporco ma è stata inviata in precedenza una finish.

;Attiva quando ricevo un ordine da un tavolo pulito. Inform con accepted
(defrule answer-msg-order1
	?f1<-(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (table-id ?sen) (clean yes))
=>
	(assert (inform (request-id ?f1) (table ?sen) (answer accepted)))
)
 
;Attiva quando ricevo un ordine da un tavolo sporco che per specifica assumiamo abbia inviato precedentemente una finish. Inform con delayed
(defrule answer-msg-order2
	?f1<-(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (table-id ?sen) (clean no))
=>
	(assert (inform (request-id ?f1) (table ?sen) (answer delayed)))
)
;Attiva quando ricevo un ordine di finish. Inform con accepted
(defrule answer-msg-order3
	?f1<-(msg-to-agent (request-time ?t) (step ?s) (sender ?sen) (type finish) (drink-order ?do) (food-order ?fo))
=>
	(assert (inform (request-id ?f1) (table ?sen) (answer accepted)))
)