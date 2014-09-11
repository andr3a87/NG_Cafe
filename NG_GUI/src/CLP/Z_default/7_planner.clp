;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;; 			   			MODULO PLANNER					   ;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule PLANNER (import AGENT ?ALL) (export ?ALL))

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;; PARTE DI ASTAR ;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(deftemplate kagent_node
	(slot ident) (slot open)
	(slot pos-r) (slot pos-c)
	(slot direction)
	(slot fcost) (slot gcost)
	(slot father)	
)

(deftemplate kagent_newnode
	(slot ident) 
	(slot pos-r) (slot pos-c)
	(slot direction)
	(slot fcost) (slot gcost)
	(slot father) 
)

(deftemplate plan_local_pos
	(slot p)
	(slot r)
	(slot c)
)

(defrule start-planner
	(future_cell (pos-r ?r) (pos-c ?c) (direction ?d))
	(current_goal ?)
 =>
	(assert
		(kagent_node
			(ident 0) (open yes)
			(pos-r ?r) (pos-c ?c)
			(direction ?d)
			(fcost 0) (gcost 0)
			(father NA)
		)
		(current_node 0)
		(lastnode 0)
		(open-worse 0)
		(open-better 0)
		(alreadyclosed 0)
		(numberofnodes 0)
		(planning)
	)
)

(defrule achieved-goal
	(declare (salience 100))
	(planning)
    (current_node ?id)
    (current_goal ?gid)
    ?rg <- (reachable_goals ?rgls)
    ?gl <- (goal
				(goal-id ?gid)
				(goal-r ?gr) (goal-c ?gc)
				(goal-direction ?gd)
			)
    (kagent_node (ident ?id) (pos-r ?gr) (pos-c ?gc) (direction ?gd) (gcost ?g)) 
    (future_cell (pos-r ?fr) (pos-c ?fc) (direction ?fd)) 
 =>
	(printout t " Esiste soluzione da (" ?fr "," ?fc "," ?fd ")" crlf)
	(printout t " verso il goal (" ?gr "," ?gc "," ?gd "), con costo "  ?g crlf)
	(assert (solution_steps 0))
    (assert (stampa ?id))
    (assert (reachable_goals (+ ?rgls 1)))
    (retract ?rg)
    (modify ?gl (goal-status found) (goal-time ?g))
)

(defrule stampa-sol
	(declare (salience 101))
	(planning)
	?f <- (stampa ?id)
	?s <- (solution_steps ?sol-steps)
    (kagent_node (ident ?id) (direction ?d-nuova) (father ?anc&~NA))  
    (kagent_exec ?anc ?id ?oper ?r ?c ?d-prec ?d-nuova)
 => 
	(printout t " Eseguo azione " ?oper " da stato (" ?r "," ?c ") con direzione " ?d-prec crlf)
	(assert (move ?sol-steps ?oper ?r ?c ?d-prec))
	(assert (solution_steps (+ ?sol-steps 1)))
	(assert (stampa ?anc))
	(retract ?s)
    (retract ?f)
)

(defrule stampa-fine
	(declare (salience 102))
	(planning)
    (stampa ?id)
    (kagent_node (ident ?id) (father ?anc&NA))
    (open-worse ?worse)
    (open-better ?better)
    (alreadyclosed ?closed)
    (numberofnodes ?n) 
    ?s <- (solution_steps ?sol-steps)
    (current_goal ?gid)
    ?gl <- (goal (goal-id ?gid))
 =>
 	(printout t " La soluzione e' costituita da " ?sol-steps " azioni" crlf)
 	(assert	(way_point_step 0))
 	(assert (solution_steps (- ?sol-steps 1)))
	(retract ?s)
	(printout t " stati espansi " ?n crlf)
	(printout t " stati generati gia' in closed " ?closed crlf)
	(printout t " stati generati gia' in open (open-worse) " ?worse crlf)
	(printout t " stati generati gia' in open (open-better) " ?better crlf crlf)	
	(modify ?gl (goal-steps ?sol-steps))
)

(defrule reverse-solution-first-step
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step 0)
	(move ?sol-steps ?oper ?r ?c ?d)
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step 0) (plan-time 0)
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step 1))
	(retract ?s ?w)
)

(defrule reverse-solution-go-forward
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step ?wp-step)
	(move ?sol-steps ?oper ?r ?c ?d)
	(way_point (plan-step =(- ?wp-step 1)) (plan-time ?t) (plan-action go-forward))
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step ?wp-step) (plan-time (+ ?t 10))
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step (+ ?wp-step 1)))
	(retract ?s ?w)
)

(defrule reverse-solution-go-left
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step ?wp-step)
	(move ?sol-steps ?oper ?r ?c ?d)
	(way_point (plan-step =(- ?wp-step 1)) (plan-time ?t) (plan-action go-left))
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step ?wp-step) (plan-time (+ ?t 15))
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step (+ ?wp-step 1)))
	(retract ?s ?w)
)

(defrule reverse-solution-go-right
	(declare (salience 103))
	(planning)
	?s <- (solution_steps ?sol-steps)
	?w <- (way_point_step ?wp-step)
	(move ?sol-steps ?oper ?r ?c ?d)
	(way_point (plan-step =(- ?wp-step 1)) (plan-time ?t) (plan-action go-right))
	(current_goal ?n)
 =>
	(assert
		(way_point
			(plan-id ?n)
			(plan-step ?wp-step) (plan-time (+ ?t 15))
			(plan-pos-r ?r) (plan-pos-c ?c)
			(plan-direction ?d)
			(plan-action ?oper)
		)
	)
	(assert (solution_steps (- ?sol-steps 1)))
	(assert (way_point_step (+ ?wp-step 1)))
	(retract ?s ?w)
)

(defrule stop-planning
	(declare (salience 103))
	(solution_steps -1)
	?p <- (planning)
 =>
	(retract ?p)
)

;//~ pulizia in tutti i casi
(defrule clean-planner-module0
	(declare (salience -1))
	(not (planning))
	?ln <- (lastnode $?)
	?ac <- (alreadyclosed $?)
	?nn <- (numberofnodes $?)
	?ow <- (open-worse $?)
	?ob <- (open-better $?)
 =>
	(retract ?ln ?ac ?nn ?ow ?ob)
)

;//~ pulizia in caso piano riuscito
(defrule clean-planner-module1
	(declare (salience -1))
	(not (planning))
	?st <- (stampa $?)
	?wps <- (way_point_step $?)
	?sols <- (solution_steps $?)
	?c <- (current_node $?)
 =>
	(retract ?st ?wps ?sols ?c)
)

;//~ pulizia in caso piano fallito
(defrule clean-planner-module2
	(declare (salience -1))
	(not (planning))
	?plp <- (plan_local_pos (p ?))
 =>
	(retract ?plp)
)

;//~ pulizia fatti move
(defrule clean-planner-module3
	(declare (salience -1))
	(not (planning))
	?mv <- (move $?)
 =>
	(retract ?mv)
)

;//~ pulizia fatti kagent_node
(defrule clean-planner-module4
	(declare (salience -1))
	(not (planning))
	?kn <- (kagent_node (ident ?))
 =>
	(retract ?kn)
)

;//~ pulizia fatti kagent_exec
(defrule clean-planner-module5
	(declare (salience -1))
	(not (planning))
	?ke <- (kagent_exec $?)
 =>
	(retract ?ke)
)

(defrule pause-after-planning
	(declare (salience -2))
	(not (planning))
 =>
	(halt)
	(pop-focus)
)

;//~ ;;;;;;; Utilizziamo un fatto di comodo plan_local_pos 	   ;;;;;;;;;;;;
;//~ ;;;;;;; per mantenere il riferimento alle celle adiacenti ;;;;;;;;;;;;

(defrule update-plan-local-pos-north
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction north)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r =(+ ?r 1)) (c ?c))
		(plan_local_pos (p 4) (r ?r) (c =(- ?c 1)))
		(plan_local_pos (p 6) (r ?r) (c =(+ ?c 1)))
	)
)

(defrule update-plan-local-pos-south
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction south)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r =(- ?r 1)) (c ?c))
		(plan_local_pos (p 4) (r ?r) (c =(+ ?c 1)))
		(plan_local_pos (p 6) (r ?r) (c =(- ?c 1)))
	)
)

(defrule update-plan-local-pos-east
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction east)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r ?r) (c =(+ ?c 1)))
		(plan_local_pos (p 4) (r =(+ ?r 1)) (c ?c))
		(plan_local_pos (p 6) (r =(- ?r 1)) (c ?c))
	)
)

(defrule update-plan-local-pos-west
	(declare (salience 100))
	(planning)
	(current_node ?curr)
	(kagent_node
		(ident ?curr)
		(pos-r ?r) (pos-c ?c)
		(direction west)
	)
 =>
	(assert 
		(plan_local_pos (p 2) (r ?r) (c =(- ?c 1)))
		(plan_local_pos (p 4) (r =(- ?r 1)) (c ?c))
		(plan_local_pos (p 6) (r =(+ ?r 1)) (c ?c))
	)
)

;//~ ;;;;;;; ATTENZIONE: calcolo g(n) = +10 per op. forward, +15 per op. left e right.
;//~ ;;;;;;;				calcolo f(n) = prima dist. Manhattan, ora moltiplicato * 10.


;//~ Aggiunta salience per preferire forward a right, e a sua volta right a left
(defrule forward-apply-plan
	(declare (salience 52))
	(planning)
	(current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction ?d-prec) (open yes))
	(plan_local_pos (p 2) (r ?r) (c ?c))
	(kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 => 
	(assert (apply ?curr go-forward ?r-prec ?c-prec ?d-prec))
)

(defrule forward-exec-plan
	(declare (salience 52))
	(planning)
    (current_node ?curr)
    (lastnode ?n)
	?f1<- (apply ?curr go-forward ?r-prec ?c-prec ?d-nuova)
	(plan_local_pos (p 2) (r ?r) (c ?c))
	(kagent_node (ident ?curr) (direction ?d-prec) (gcost ?g))
    (current_goal ?gid)
    (goal (goal-id ?gid) (goal-r ?y) (goal-c ?x) (goal-direction ?dir))
 =>
	(assert 
		(kagent_exec ?curr (+ ?n 1) go-forward ?r-prec ?c-prec ?d-prec ?d-nuova)
		(kagent_newnode 
			(ident (+ ?n 1)) 
			(pos-r ?r) (pos-c ?c) 
			(direction ?d-nuova)
			(gcost (+ ?g 10)) (fcost (+ (* (+ (abs (- ?x ?r)) (abs (- ?y ?c))) 10) ?g 10))
			(father ?curr)
		)
	)
	(retract ?f1)
	(focus NEW)
)

;//~ Aggiunta salience per preferire forward a right, e a sua volta right a left
(defrule right-apply-north-plan
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction north) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec east))
)

(defrule right-apply-south-plan
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction south) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec west))
)

(defrule right-apply-east-plan
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction east) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec south))
)

(defrule right-apply-west-plan
	(declare (salience 51))
	(planning)
    (current_node ?curr)
	(kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction west) (open yes))
    (plan_local_pos (p 6) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-right ?r-prec ?c-prec north))
)

(defrule right-exec-plan
	(declare (salience 51))
	(planning)
	(current_node ?curr)
	(lastnode ?n)
	?f1 <- (apply ?curr go-right ?r-prec ?c-prec ?d-nuova)
	(plan_local_pos (p 6) (r ?r) (c ?c))
	(kagent_node (ident ?curr) (direction ?d-prec) (gcost ?g))
    (current_goal ?gid)
    (goal (goal-id ?gid) (goal-r ?y) (goal-c ?x) (goal-direction ?dir))
 =>
	(assert 
		(kagent_exec ?curr (+ ?n 3) go-right ?r-prec ?c-prec ?d-prec ?d-nuova)
		(kagent_newnode
			(ident (+ ?n 3))
			(pos-r ?r) (pos-c ?c)
			(direction ?d-nuova)
			(gcost (+ ?g 15)) (fcost (+ (* (+ (abs (- ?y ?c)) (abs (- ?x ?r))) 10) ?g 15))
			(father ?curr)
		)
	)
	(retract ?f1)
	(focus NEW)
)

;//~ Aggiunta salience per preferire forward a right, e a sua volta right a left
(defrule left-apply-north-plan
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction north) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec west))
)

(defrule left-apply-south-plan
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction south) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec east))
)

(defrule left-apply-east-plan
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction east) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec north))
)

(defrule left-apply-west-plan
    (declare (salience 50))
    (planning)
    (current_node ?curr)
    (kagent_node (ident ?curr) (pos-r ?r-prec) (pos-c ?c-prec) (direction west) (open yes))
    (plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_cell (pos-r ?r) (pos-c ?c) (type urban|rural|lake|gate))
 =>
	(assert (apply ?curr go-left ?r-prec ?c-prec south))
)

(defrule left-exec-plan
	(declare (salience 50))
	(planning)
    (current_node ?curr)
    (lastnode ?n)
	?f1<- (apply ?curr go-left ?r-prec ?c-prec ?d-nuova)
	(plan_local_pos (p 4) (r ?r) (c ?c))
    (kagent_node (ident ?curr) (direction ?d-prec) (gcost ?g))
	(current_goal ?gid)
    (goal (goal-id ?gid) (goal-r ?y) (goal-c ?x) (goal-direction ?dir))
 =>
	(assert
		(kagent_exec ?curr (+ ?n 4) go-left ?r-prec ?c-prec ?d-prec ?d-nuova)
		(kagent_newnode
			(ident (+ ?n 4))
			(pos-r ?r) (pos-c ?c)
			(direction ?d-nuova)
			(gcost (+ ?g 15)) (fcost (+ (* (+ (abs (- ?y ?c)) (abs (- ?x ?r))) 10) ?g 15))
			(father ?curr)
		)
	)
	(retract ?f1)
    (focus NEW)
)

(defrule change-current_node
	(declare (salience 49))
	(planning)
	?f1 <- (current_node ?curr)
	?f2 <- (kagent_node (ident ?curr))
    (kagent_node (ident ?best&:(neq ?best ?curr)) (fcost ?bestcost) (open yes))
    (not (kagent_node (ident ?id&:(neq ?id ?curr)) (fcost ?gg&:(< ?gg ?bestcost)) (open yes)))
	?f3 <- (lastnode ?last)
	?p2 <- (plan_local_pos (p 2))
	?p4 <- (plan_local_pos (p 4))
	?p6 <- (plan_local_pos (p 6))
 =>
	(assert (current_node ?best) (lastnode (+ ?last 5)))
    (retract ?f1 ?f3 ?p2 ?p4 ?p6)
    (modify ?f2 (open no))
) 

(defrule close-empty
	(declare (salience 49))
	?p <- (planning)
	?f1 <- (current_node ?curr)
	?f2 <- (kagent_node (ident ?curr))
    (not (kagent_node (ident ?id&:(neq ?id ?curr)) (open yes)))
    (current_goal ?gid)
    ?gl <- (goal (goal-id ?gid) (goal-r ?gr) (goal-c ?gc) (goal-direction ?gd))
    (numberofnodes ?non)
    (future_cell (pos-r ?fr) (pos-c ?fc) (direction ?fd))
 => 
    (retract ?f1 ?p)
    (modify ?f2 (open no))
    (printout t " Non esiste soluzione da (" ?fr "," ?fc "," ?fd ")" crlf)
	(printout t " verso il goal (" ?gr "," ?gc "," ?gd ")!!!" crlf)
    (printout t " [espansi " ?non " nodi]" crlf crlf)
	(modify ?gl (goal-status failed))
)    
                     
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;; 			   			MODULO NEW					   ;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule NEW (import PLANNER ?ALL) (export ?ALL))

(defrule check-closed
	(declare (salience 50))
	(planning)
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d))
	(kagent_node (ident ?old) (pos-r ?r) (pos-c ?c) (open no) (direction ?d))
	?f2 <- (alreadyclosed ?a)
 =>
	(assert (alreadyclosed (+ ?a 1)))
    (retract ?f1)
    (retract ?f2)
    (pop-focus)
)

(defrule check-open-worse
	(declare (salience 50))
	(planning)
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (father ?anc))
    (kagent_node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes))
    (test (or (> ?g ?g-old) (= ?g-old ?g)))
	?f2 <- (open-worse ?a)
 =>
    (assert (open-worse (+ ?a 1)))
    (retract ?f1)
    (retract ?f2)
    (pop-focus)
)

(defrule check-open-better
	(declare (salience 50))
	(planning)
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc))
	?f2 <- (kagent_node (ident ?old) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g-old) (open yes))
    (test (<  ?g ?g-old))
	?f3 <- (open-better ?a)
 => 
	(assert
		(kagent_node
			(ident ?id)
			(pos-r ?r) (pos-c ?c)
			(direction ?d)
			(gcost ?g) (fcost ?f)
			(father ?anc) (open yes)
		)
	)
    (assert (open-better (+ ?a 1)))
    (retract ?f1 ?f2 ?f3)
    (pop-focus)
)

(defrule add-open
	(declare (salience 49))
	(planning)
	?f1 <- (kagent_newnode (ident ?id) (pos-r ?r) (pos-c ?c) (direction ?d) (gcost ?g) (fcost ?f) (father ?anc))
	?f2 <- (numberofnodes ?a)
 => 
	(assert 
		(kagent_node 
			(ident ?id)
			(pos-r ?r) (pos-c ?c)
			(direction ?d)
			(gcost ?g) (fcost ?f)
			(father ?anc) (open yes)
		)
	)
    (assert (numberofnodes (+ ?a 1)))
    (retract ?f1 ?f2)
    (pop-focus)
)
