(defrule distance-manhattan-fo
	(declare (salience 150))
	(msg-to-agent (step ?s) (food-order ?fo))
	(test (> ?fo 0))
	(exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
	(status (step ?s))
	(K-agent (step ?s) (pos-r ?ra)(pos-c ?ca))
	(K-cell (pos-r ?rfo) (pos-c ?cfo) (contains FD))
	=>
	(assert (distance-fd (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo))))))
)

(defrule distance-manhattan-do
	(declare (salience 150))
	(msg-to-agent (step ?s) (drink-order ?do))
	(test (> ?do 0))
	(exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
	(status (step ?s))
	(K-agent (step ?s) (pos-r ?ra)(pos-c ?ca))
	(K-cell (pos-r ?rdo) (pos-c ?cdo) (contains DD))
	=>
	(assert (distance-dd (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance (+ (abs(- ?ra ?rdo)) (abs(- ?ca ?cdo))))))
)