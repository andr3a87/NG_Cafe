;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;; 			   			MODULO AGENT					   ;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmodule AGENT (import MAIN ?ALL) (export ?ALL))

(deftemplate kagent 
	(slot time) (slot step)
	(slot pos-r) (slot pos-c) 
    (slot direction)
)

(deftemplate kagent_cell 
	(slot pos-r) (slot pos-c)
	(slot type (allowed-values urban rural lake hill gate border))
	(slot percepted (allowed-values no water border gate hill urban rural)(default no))
	(slot visited (allowed-values true false)(default false)) ;//~ 	indica se ci sono effettivamente passato sopra
	(slot monitored (allowed-values no other low-water deep-water)(default no))
	(slot utility (default 0))
	(slot informed (allowed-values no ok flood initial-flood severe-flood)(default no))
)

(deftemplate future_cell
	(slot pos-r) (slot pos-c) 
    (slot direction)
)

(deftemplate next_action
	(slot action)
	(slot safety (allowed-values NA safe unsafe)(default NA))
)

;//~ ; rappresenta la percezione locale (ad ogni passo) dell'agente in termini delle 9 celle che e' in grado
;//~ ; di osservare: ogni campo e' rappresentato da 2 valori, riga e colonna 
;//~ ; -> es. (local_perc (p 1) (r 5) (c 4)) cioe' cella 1 di riga 5 e colonna 4
(deftemplate local_perc 
	(slot p)
	(slot r)
	(slot c)
)

;//~ template che rappresenta un passo di un piano
(deftemplate way_point
	(slot plan-id)
	(slot plan-step) (slot plan-time)
	(slot plan-pos-r) (slot plan-pos-c)
	(slot plan-direction)
	(slot plan-action)
	(slot plan-backup (default -1))
)

;//~ template che rappresenta un goal raggiungibile dall'agente (attualmente cosideriamo solo goal-gate) 
(deftemplate reachable_goal 
	(slot reachable-goal-id)
	(slot reachable-goal-r) (slot reachable-goal-c) 
	(slot reachable-goal-direction)
	(slot reachable-goal-time (default 99999)) (slot reachable-goal-steps)
)

;//~ template che rappresenta un goal temporaneo durante il calcolo di A*
(deftemplate goal
	(slot goal-id)
	(slot goal-r) (slot goal-c) 
	(slot goal-direction)
	(slot goal-time (default 99999)) (slot goal-steps)
	(slot goal-status (allowed-values NA found failed) (default NA))
)

(defrule create-kagent-cell-urban
	(declare (salience 510))
	(prior_cell (pos-r ?r) (pos-c ?c) (type urban))
 =>
	(assert (kagent_cell (pos-r ?r) (pos-c ?c) (type urban) (utility 80)))
)

(defrule create-kagent-cell-rural
	(declare (salience 510))
	(prior_cell (pos-r ?r) (pos-c ?c) (type rural))
 =>
	(assert (kagent_cell (pos-r ?r) (pos-c ?c) (type rural) (utility 60)))
)

(defrule create-kagent-cell-lake
	(declare (salience 510))
	(prior_cell (pos-r ?r) (pos-c ?c) (type lake))
 =>
	(assert (kagent_cell (pos-r ?r) (pos-c ?c) (type lake) (utility 20)))
)

(defrule create-kagent-cell-gate
	(declare (salience 510))
	(prior_cell (pos-r ?r) (pos-c ?c) (type gate))
 =>
	(assert (kagent_cell (pos-r ?r) (pos-c ?c) (type gate) (utility 9)))
)

(defrule create-kagent-cell-other
	(declare (salience 510))
	(prior_cell (pos-r ?r) (pos-c ?c) (type ?t&:(or (eq ?t border) (eq ?t hill))))
 =>
	(assert (kagent_cell (pos-r ?r) (pos-c ?c) (type ?t)))
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
;//~ ;;;;;;;;;;;;;; SEZIONE PER IL PRIMO PASSO DI USCITA DAL GATE ;;;;;;;;;;;;;; 
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

;//~ regola che implementa la prima azione dell'agente:
;//~ attualmente iniziamo con una pianificazione multi A* verso tutti i gate
(defrule  beginagent
	(declare (salience 150))
    (status (step 0))
    (not (exec (step 0)))
    (initial_agentstatus (pos-r ?r) (pos-c ?c) (direction ?d))
    (maxduration ?md)
    (test (or (> ?md 10) (= ?md 10)))
 => 
    (assert 
		(kagent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction ?d))
		
		(the_first_step)

		(current_goal 0)	 ;//~ indice del goal-gate su cui dobbiamo fare A*
		(reachable_goals 0)	 ;//~ conta quanti goal-gate sono raggiungibili attualmente 
		(gate_counter 0)	 ;//~ conta quanti goal-gate sono presenti nella mappa
		
		(current_shortest_plan -1 -1)
	)
)

(defrule first-future-cell-north
	(declare (salience 120))
	(the_first_step)
	(status (step 0))
	(not (exec (step 0)))
	(kagent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction north))
 =>
	(assert (future_cell (pos-r (+ ?r 1)) (pos-c ?c) (direction north)))
)

(defrule first-future-cell-south
	(declare (salience 120))
	(the_first_step)
	(status (step 0))
	(not (exec (step 0)))
	(kagent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction south))
 =>
	(assert (future_cell (pos-r (- ?r 1)) (pos-c ?c) (direction south)))
)

(defrule first-future-cell-east
	(declare (salience 120))
	(the_first_step)
	(status (step 0))
	(not (exec (step 0)))
	(kagent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction east))
 =>
	(assert (future_cell (pos-r ?r) (pos-c (+ ?c 1)) (direction east)))
)

(defrule first-future-cell-west
	(declare (salience 120))
	(the_first_step)
	(status (step 0))
	(not (exec (step 0)))
	(kagent (time 0) (step 0) (pos-r ?r) (pos-c ?c) (direction west))
 =>
	(assert (future_cell (pos-r ?r) (pos-c (- ?c 1)) (direction west)))
)

(defrule first-step
	?tfs <- (the_first_step)
	(status (step 0))
	(not (exec (step 0)))
	(reachable_goal (reachable-goal-id ?rgid))
	(kagent (time 0) (step 0))
 =>
	(assert (exec (action go-forward) (step 0)))
	(retract ?tfs)
)

(defrule continue-planning-0
	(declare (salience 90))
	(the_first_step)
	(goal (goal-id ?gid) (goal-status NA))
	?c <- (current_goal ?cg)
 =>
	(assert	(current_goal (+ ?cg 1)))
	(retract ?c)
	(focus PLANNER)
)

(defrule initialize_reachable_goal
	(declare (salience 10))
	(the_first_step)
	(maxduration ?md)
	(goal
		(goal-id ?rgid)
		(goal-r ?rgr) (goal-c ?rgc) 
		(goal-direction ?rgdir)
		(goal-time ?rgt) (goal-steps ?rgs)
		(goal-status found)
	)
	(test (> (- ?md ?rgt 10) 0))
 =>
	(assert
		(reachable_goal
			(reachable-goal-id ?rgid)
			(reachable-goal-r ?rgr) (reachable-goal-c ?rgc) 
			(reachable-goal-direction ?rgdir)
			(reachable-goal-time ?rgt) (reachable-goal-steps ?rgs)
		)
	)	
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ NB: queste 4 regole possono essere perfezionate implementando
;//~ una qualche forma di reasoning geometrico
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defrule find-gates-south
	(declare (salience 110))
	(the_first_step)
	(kagent_cell (pos-r 1) (pos-c ?c) (type gate))
	(kagent_cell (pos-r 1) (pos-c =(- ?c 1)) (type border|gate))
	(kagent_cell (pos-r 1) (pos-c =(+ ?c 1)) (type border|gate))
	?p <- (gate_counter ?pc)
	(not (goal (goal-r 1) (goal-c ?c) (goal-direction south)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r 1) (goal-c ?c)
			(goal-direction south)
		)
		(gate_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-gates-north
	(declare (salience 110))
	(the_first_step)
	(kagent_cell (pos-r ?r&:(neq ?r 1)) (pos-c ?c) (type gate))
	(kagent_cell (pos-r ?r&:(neq ?r 1)) (pos-c =(- ?c 1)) (type border|gate))
	(kagent_cell (pos-r ?r&:(neq ?r 1)) (pos-c =(+ ?c 1)) (type border|gate))
	?p <- (gate_counter ?pc)
	(not (goal (goal-r ?r) (goal-c ?c) (goal-direction north)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r ?r) (goal-c ?c)
			(goal-direction north)
		)
		(gate_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-gates-west
	(declare (salience 110))
	(the_first_step)
	(kagent_cell (pos-r ?r) (pos-c 1) (type gate))
	(kagent_cell (pos-r =(- ?r 1)) (pos-c 1) (type border|gate))
	(kagent_cell (pos-r =(+ ?r 1)) (pos-c 1) (type border|gate))
	?p <- (gate_counter ?pc)
	(not (goal (goal-r ?r) (goal-c 1) (goal-direction west)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r ?r) (goal-c 1)
			(goal-direction west)
		)
		(gate_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule find-gates-east
	(declare (salience 110))
	(the_first_step)
	(kagent_cell (pos-r ?r) (pos-c ?c&:(neq ?c 1)) (type gate))
	(kagent_cell (pos-r =(- ?r 1)) (pos-c ?c&:(neq ?c 1)) (type border|gate))
	(kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c&:(neq ?c 1)) (type border|gate))
	?p <- (gate_counter ?pc)
	(not (goal (goal-r ?r) (goal-c ?c) (goal-direction east)))
 =>
	(assert 
		(goal
			(goal-id ?pc)
			(goal-r ?r) (goal-c ?c)
			(goal-direction east)
		)
		(gate_counter (+ ?pc 1))
	)
	(retract ?p)
)

(defrule all-gates-found
	(declare (salience 100))
	(the_first_step)
 =>
	(focus PLANNER)
)

;//~ cancelliamo i goal che non sono piu' raggiungibili fisicamente,
;//~ a causa della conformazione della mappa
(defrule delete-unreachable-goal-space
	(declare (salience 150))
	(not (the_first_step))	
	?rg <- (reachable_goal (reachable-goal-id ?rgid))
	(goal (goal-id ?rgid) (goal-status failed))
 =>
	(retract ?rg)
)

;//~ cancelliamo i goal che non sono piu' raggiungibili,
;//~ dopo un'azione di move-..., con il tempo attualmente a disposizione
(defrule delete-unreachable-goal-time-0
	(declare (salience 140))
	(not (the_first_step))
	(maxduration ?md)
	(status (step ?i) (time ?t))	
	?rg <- (reachable_goal (reachable-goal-id ?rgid))
	(goal	(goal-id ?rgid) (goal-time ?gt) (goal-status found))
	(test (or (< (- ?md ?t ?gt) 0) (= (- ?md ?t ?gt) 0)))
 =>
	(retract ?rg)
)

;//~ cancelliamo i goal che non sono piu' raggiungibili,
;//~ dopo un'azione di loiter-monitoring/inform,
;//~ con il tempo attualmente a disposizione
(defrule delete-unreachable-goal-time-1
	(declare (salience 140))
	(not (the_first_step))
	(status (step ?i) (time ?t))
	(maxduration ?md)
	?rg1 <- (reachable_goal (reachable-goal-id ?rgid1) (reachable-goal-time ?rgt1))
	?rg2 <- (reachable_goal (reachable-goal-id ?rgid2&:(neq ?rgid2 ?rgid1)))
	?g <- (goal	(goal-id ?rgid1))
	?cg <- (current_goal ?)
	(test (or (< (- ?md ?t ?rgt1) 0) (= (- ?md ?t ?rgt1) 0)))
 =>
	(retract ?rg1 ?g ?cg)
	(assert (current_goal ?rgid2))
)

(defrule update-reachable-goal
	(declare (salience 130))
	(not (the_first_step))
	?rg <-	(reachable_goal
				(reachable-goal-id ?rgid)
				(reachable-goal-time ?rgt) (reachable-goal-steps ?rgs)
			)
	(or
		(goal
			(goal-id ?rgid)
			(goal-time ?gt&:(neq ?gt ?rgt)) (goal-steps ?gs)
			(goal-status found)
		)
		(goal
			(goal-id ?rgid)
			(goal-time ?gt) (goal-steps ?gs&:(neq ?gs ?rgs))
			(goal-status found)
		)
	)
 =>
	(modify ?rg	(reachable-goal-time ?gt) (reachable-goal-steps ?gs))
)

(defrule delete-goal
	(declare (salience 120))
	(not (the_first_step))
	?g <- (goal	(goal-id ?) (goal-status found|failed))
 =>
	(retract ?g)
)

(defrule add-goal
	(declare (salience 110))
	(not (the_first_step))
	?rg <- (reachable_goal
		(reachable-goal-id ?rgid)
		(reachable-goal-r ?rgr) (reachable-goal-c ?rgc) 
		(reachable-goal-direction ?rgdir)
		(reachable-goal-time ?rgt) (reachable-goal-steps ?rgs)
	)
 =>
	(assert
		(goal
			(goal-id ?rgid)
			(goal-r ?rgr) (goal-c ?rgc) 
			(goal-direction ?rgdir)
			(goal-time 99999) (goal-steps nil)
			(goal-status NA)
		)
	)
)

;//~ attivata quando non eseguiamo subito la prima azione forward
;//~  e restano nella KB delle next_action fallite
(defrule delete-next-action
	(declare (salience 100))
	(not (the_first_step))
	?na <- (next_action (action ?))
 =>
	(retract ?na)
)

;//~ regola che cancella un piano di backup calcolato precedentemente
(defrule remove-previous-backup-plan
	(declare (salience 95))
	(not (the_first_step))
	(not (getaway))
	(status (step ?i))
	?bwp <- (way_point (plan-id ?) (plan-backup ?pb&:(and (neq ?pb ?i) (neq ?pb -1))))
	(way_point (plan-id ?) (plan-backup -1))
 =>
	(retract ?bwp)
)

;//~ regola che cancella un piano inutile in fase di getaway
(defrule remove-useless-plan
	(declare (salience 95))
	(not (the_first_step))
	(getaway)
	?bwp <- (way_point (plan-id ?) (plan-backup -1))
 =>
	(retract ?bwp)
)

;//~ regola che seleziona, tra tutti i reachable_goal, il piu' veloce da raggiungere
(defrule select-shortest-plan
	(declare (salience 90))
	(not (the_first_step))
	(not (getaway))
	(status (step ?i))
	(reachable_goal (reachable-goal-id ?rgid) (reachable-goal-time ?rgt1))
	(not (reachable_goal (reachable-goal-time ?rgt2&:(< ?rgt2 ?rgt1))))
	?csp <- (current_shortest_plan ? ?s&:(neq ?s ?i))
 =>	
	(assert (current_shortest_plan ?rgid ?i))
	(retract ?csp)
)

;//~ regola che rimuove tutti i piani (way_point) piu' lontani
(defrule remove-longer-plan
	(declare (salience 90))
	(not (the_first_step))
	(not (getaway))
	(current_shortest_plan ?pid1 ?s)
	?wp <- (way_point (plan-id ?pid2&:(neq ?pid2 ?pid1)))
 =>
	(retract ?wp)
)

;//~ regola che effettua il backup del piano corrente
(defrule backup-plan
	(declare (salience 85))
	(not (getaway))
	(current_shortest_plan ?n ?s)
	(status (step ?i))
	?wp <- (way_point (plan-id ?n) (plan-backup -1))
 =>
	(modify ?wp (plan-backup ?i))
)

;//~ regola che verifica se il tempo rimanente consente solo di eseguire il piano di fuga
(defrule time-to-go-home
	(declare (salience 90))
	(status (time ?t))
	(maxduration ?md)
	(not (the_first_step))
	(not (getaway))
	(reachable_goal (reachable-goal-id ?rgid) (reachable-goal-time ?rgt))
	(current_shortest_plan ?rgid ?s)
	(test (= (- ?md ?t ?rgt) 1))
 =>
	(assert 
		(getaway)
		(current_plan_step 0)
		(time_is_over)
	)
)

(defrule reset-counters
	(declare (salience 80))
	(not (the_first_step))
	(not (getaway))
	?cg <- (current_goal ?)
	?rgls <- (reachable_goals ?)
;//~ 	prendo un generico reachable goal
	(reachable_goal (reachable-goal-id ?rgid))
 =>
	(retract ?cg ?rgls)
	(assert
		(current_goal ?rgid)
		(reachable_goals 0)
	)
	(focus CHECKER)
)

(defrule clean-getaway
	(declare (salience 88))
	(not (the_first_step))
	(getaway)
	(time_is_over)
	?gc <- (gate_counter ?)
	?cg <- (current_goal ?)
	?rg <- (reachable_goals ?)
	?fc <- (future_cell (pos-r ?) (pos-c ?) (direction ?))
 =>
	(retract ?gc ?cg ?rg ?fc)
)

(defrule clean-getaway-rg
	(declare (salience 88))
	(not (the_first_step))
	(getaway)
	(time_is_over)
	?rg <- (reachable_goal (reachable-goal-id ?))
 =>
	(retract ?rg)
)

(defrule clean-getaway-g
	(declare (salience 88))
	(not (the_first_step))
	(getaway)
	(time_is_over)
	?g <- (goal (goal-id ?))
 =>
	(retract ?g)
)

;//~ regola che fa eseguire il piano di fuga all'agente
(defrule exec-plan
	(declare (salience 85))
	(getaway)
	(current_shortest_plan ?gid ?st)
	(status (step ?s))
	(current_plan_step ?cps)
	?wp <- (way_point
				(plan-id ?gid)
				(plan-step ?cps) (plan-time ?pt)
				(plan-pos-r ?pr) (plan-pos-c ?pc)
				(plan-direction ?pd) (plan-action ?pa)
				(plan-backup ?pb&:(neq ?pb -1))
			)
	(kagent
		(time ?t) (step ?s)
		(pos-r ?r) (pos-c ?c)
		(direction ?d)
	)
 =>
	(assert (exec (step ?s) (action ?pa)))
	(retract ?wp)
)

;//~ regola che fa compiere l'azione di fuga
(defrule exec-act-getaway
	(declare (salience 160))
	(status (step ?i))
    (exec (step ?i))
    (getaway)
    ?c <- (current_plan_step ?cps)
 => 
	(assert (current_plan_step (+ ?cps 1)))
	(retract ?c)
	(focus MAIN)
)

;//~ Da fare quando siamo in fase di getaway
(defrule plan-delete-local-perc
	(declare (salience 87))
	(getaway)
	?p1 <- (local_perc (p 1))
	?p2 <- (local_perc (p 2))
	?p3 <- (local_perc (p 3))
	?p4 <- (local_perc (p 4))
	?p5 <- (local_perc (p 5))
	?p6 <- (local_perc (p 6))
	?p7 <- (local_perc (p 7))
	?p8 <- (local_perc (p 8))
	?p9 <- (local_perc (p 9))
 =>
	(retract ?p1 ?p2 ?p3 ?p4 ?p5 ?p6 ?p7 ?p8 ?p9)
)

;//~ regola che fa compiere l'azione di movimento classico
(defrule exec-act
	(declare (salience 160))
	(status (step ?i))
	(not (getaway))
    (exec (step ?i))
 => 
	(focus MAIN)
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;;; PARTE DI PERC-AGENT ;;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule perc-agent-north
	(declare (salience 170))
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction north)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1	<- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f3 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
	?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
	?f6 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
	?f7 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f8 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f9 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction north))
	(assert 
		(local_perc (p 1) (r =(+ ?r 1)) (c =(- ?c 1)))
		(local_perc (p 2) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 3) (r =(+ ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 4) (r ?r) (c =(- ?c 1)))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 7) (r =(- ?r 1)) (c =(- ?c 1)))
		(local_perc (p 8) (r =(- ?r 1)) (c ?c))
		(local_perc (p 9) (r =(- ?r 1)) (c =(+ ?c 1)))
	)
	(retract ?pv)
)

(defrule perc-agent-south
	(declare (salience 170))
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction south)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f3 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
    ?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
    ?f6 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
    ?f7 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
    ?f8 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f9 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction south))
	(assert 
		(local_perc (p 1) (r =(- ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 2) (r =(- ?r 1)) (c ?c))
		(local_perc (p 3) (r =(- ?r 1)) (c =(- ?c 1)))
		(local_perc (p 4) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r ?r) (c =(- ?c 1)))
		(local_perc (p 7) (r =(+ ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 8) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 9) (r =(+ ?r 1)) (c =(- ?c 1)))
	)
	(retract ?pv)	
)

(defrule perc-agent-east
	(declare (salience 170))
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction east)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
    ?f3 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f4 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
    ?f6 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f7 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
    ?f8 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
    ?f9 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction east))
	(assert 
		(local_perc (p 1) (r =(+ ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 2) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 3) (r =(- ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 4) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r =(- ?r 1)) (c ?c))
		(local_perc (p 7) (r =(+ ?r 1)) (c =(- ?c 1)))
		(local_perc (p 8) (r ?r) (c =(- ?c 1)))
		(local_perc (p 9) (r =(- ?r 1)) (c =(- ?c 1)))
	)
	(retract ?pv)	
)

(defrule perc-agent-west
	(declare (salience 170))
	(status (step ?i))
	?ka <- (kagent (step =(- ?i 1)))
	?pv <- (perc-vision
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(direction west)
		(perc1 ?p1)(perc2 ?p2)(perc3 ?p3)
		(perc4 ?p4)(perc5 ?p5)(perc6 ?p6)
		(perc7 ?p7)(perc8 ?p8)(perc9 ?p9)
	)
	?f1 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (kagent_cell (pos-r ?r) (pos-c =(- ?c 1)))
    ?f3 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
    ?f4 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c ?c))
    ?f5 <- (kagent_cell (pos-r ?r) (pos-c ?c))
    ?f6 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c ?c))
    ?f7 <- (kagent_cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    ?f8 <- (kagent_cell (pos-r ?r) (pos-c =(+ ?c 1)))
    ?f9 <- (kagent_cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
 =>
	(modify ?f1 (percepted ?p1))(modify ?f2 (percepted ?p2))(modify ?f3 (percepted ?p3))
	(modify ?f4 (percepted ?p4))(modify ?f5 (percepted ?p5) (visited true))(modify ?f6 (percepted ?p6))
	(modify ?f7 (percepted ?p7))(modify ?f8 (percepted ?p8))(modify ?f9 (percepted ?p9))
	(modify ?ka (time ?t) (step ?i) (pos-r ?r) (pos-c ?c) (direction west))
	(assert 
		(local_perc (p 1) (r =(- ?r 1)) (c =(- ?c 1)))
		(local_perc (p 2) (r ?r) (c =(- ?c 1)))
		(local_perc (p 3) (r =(+ ?r 1)) (c =(- ?c 1)))
		(local_perc (p 4) (r =(- ?r 1)) (c ?c))
		(local_perc (p 5) (r ?r) (c ?c))
		(local_perc (p 6) (r =(+ ?r 1)) (c ?c))
		(local_perc (p 7) (r =(- ?r 1)) (c =(+ ?c 1)))
		(local_perc (p 8) (r ?r) (c =(+ ?c 1)))
		(local_perc (p 9) (r =(+ ?r 1)) (c =(+ ?c 1)))
	)
	(retract ?pv)
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;;;; PARTE DI PERC-MONITOR ;;;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule perc-agent-monitored
	(declare (salience 160))
	?pm <- (perc-monitor
		(time ?t) (step ?i)
		(pos-r ?r) (pos-c ?c)
		(perc ?p)
	)
	?f <- (kagent_cell (pos-r ?r) (pos-c ?c))
 =>
	(modify ?f (monitored ?p))
	(retract ?pm)
)

;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;//~ ;;;;; PARTE DI AGGIORNAMENTO UTILITA' ;;;;;
;//~ ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defrule increase-utility-urban-water
	(declare (salience 155))
	(not (getaway))
	(local_perc (r ?r) (c ?c))
	?ka <- (kagent_cell (pos-r ?r) (pos-c ?c)
		(type urban) (percepted water)
		(monitored no) (utility 80) (informed no)
	)
 =>
	(modify ?ka (utility 120))
)

(defrule increase-utility-rural-water
	(declare (salience 155))
	(not (getaway))
	(local_perc (r ?r) (c ?c))
	?ka <- (kagent_cell (pos-r ?r) (pos-c ?c)
		(type rural) (percepted water)
		(monitored no) (utility 60) (informed no)
	)
 =>
	(modify ?ka (utility 100))
)

(defrule decrease-utility-visited
	(declare (salience 155))
	(not (getaway))
	(local_perc (p 5) (r ?r) (c ?c))
	?ka <- (kagent_cell (pos-r ?r) (pos-c ?c) (visited true) (utility ?u&:(neq ?u 10)))
 =>
	(modify ?ka (utility 10))
)

(defrule in-gate-done-0
	(declare (salience -99))
	(status (step 0))
 =>
	(assert (exec (action done) (step 0)))
)

(defrule clean-getaway-wp
	(declare (salience -98))
	(not (the_first_step))
	(getaway)
	?wp <- (way_point (plan-id ?))
 =>
	(retract ?wp)
)

(defrule getaway-done
	(declare (salience -99))
	(status (step ?i))
	?g <- (getaway)
	?csp <- (current_shortest_plan ? ?s)
	?cps <- (current_plan_step ?)
 =>
	(retract ?g ?csp ?cps)
	(assert (exec (action done) (step ?i)))
)
