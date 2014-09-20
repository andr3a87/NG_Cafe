;Controlle se esiste un piano per andare al best dispenser/trash con status OK
(defrule existence-plane
	(declare (salience 10))
	(exec-order (table-id ?id) (phase 3) )
	(strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(plane (pos-start ?ra ?ca) (pos-end ?rd ?cd) (status ok))
=>
	(assert (plane-exist))
)
;Se il piano non esiste allora devo avviare astar per cercare un percorso che mi porti a destinazione.
(defrule create-plane
	(exec-order (table-id ?id) (phase 3) )
	(strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
	(not (plane-exist))
=>
	(assert (start-astar (pos-r ?rd) (pos-c ?cd)))
)

;Se il piano esiste allo lo eseguo.
(defrule execute-plane
	(declare (salience 1))
	(exec-order (table-id ?id) (phase 3) )
	?f1<-(plane-exist)
	(plane  (plane-id ?id) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (direction ?d) (status ok))
=>
	(assert (run-plane-astar (plane-id) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (direction ?d) (phase 1)))
	(retract ?f1)
)

;Eseguito il piano, il robot si trova vicino al dispenser/cestino piu vicino.
(defrule strategy-go-phase4
  (status (step ?current))
  (debug ?level)
  (plan-executed (step ?current) (pos-start ?rs ?cs) (pos-end ?rg ?cg) (result ok))
  ?f1<-(exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
=>
  (modify ?f1 (phase 4) (fail 0))

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F4:s"?current":"?id"] Init Phase 4 - Agent in front of best dispenser: "?c" in ("?rd","?cd")" crlf)
  )
)

;Piano fallito, il robot deve ripianificare il percorso per raggiungere il best-dispenser. 
;Devo modificare K-agent altrimenti la regola S0 di astar non parte perche attivata più volte dal medesimo fatto.
(defrule strategy-re-execute-phase3
  (status (step ?current))
  (debug ?level)
  (plan-executed (step ?current) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (result fail))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1<-(plane (pos-start ?ra ?ca) (pos-end ?rd ?cd) (status ok))
  ?f2<-(exec-order (table-id ?id) (phase 3) (fail ?f))
  ?f3<-(K-agent)
=>
  (modify ?f1 (status failure))	
  (modify ?f2 (phase 3) (fail (+ ?f 1)))
  (modify ?f3)

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 3: Plane Failed. Re-Plane Astar to dispenser: "?c" in ("?rd","?cd")" crlf)
  )
)

;Se non esiste un percorso per arrivare a destinazione, l'ordine viene inserito al fondo.
;Devo modificare K-agent altrimenti la regola S0 di astar non parte perche attivata più volte dal medesimo fatto
(defrule strategy-change-order-in-phase3
  (declare(salience 10))
  (debug ?level)
  (status (step ?current))
  ?f1<-(exec-order (table-id ?id) (step ?s2) (phase 3))
  ?f3<-(strategy-best-dispenser (type ?c) (pos-dispenser ?rd ?cd))
  ?f4<-(astar-solution (value no))
  ?f5<-(K-agent)
  ?f6<-(start-astar)
=>
  (modify ?f1 (step ?current) (phase 0))
  (modify ?f5)
  (retract ?f3 ?f4 ?f6)

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F3:s"?current":"?id"] A-Star not found solution to the dispenser: "?c" in ("?rd","?cd")" crlf)
    (printout t " [DEBUG] [F3:s"?current":"?id"] Order moved to the bottom." crlf)
  )
)



