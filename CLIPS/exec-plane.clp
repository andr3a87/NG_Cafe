;@TODO gestire fallimento piano

(deffacts initial-fact
  (start 0)
)

(defrule run-plane-turn
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id ?oper ?d ?r ?c) (cost ?g))
  (test (or (= (str-compare ?oper "Turnleft")0) (= (str-compare ?oper "Turnright")0)))
  (status (step ?s))
=>
  (retract ?f1)
  (assert (start ?id))
  (assert (exec (step ?s) (action ?oper)))
)

(defrule run-plane-forward-north
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id Forward north ?r ?c) (cost ?g))
  (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) (contains ?con))
  (status (step ?s))
=>
  (if (= (str-compare ?con "Empty")0)
    then
      (retract ?f1)
      (assert (start ?id))
      (assert (exec (step ?s) (action Forward)))
    else
      (assert (plan-failed))
  )
)

(defrule run-plane-forward-south
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id Forward south ?r ?c) (cost ?g))
  (K-cell (pos-r =(- ?r 1)) (pos-c ?c) (contains ?con))
  (status (step ?s))
=>
  (if (= (str-compare ?con "Empty")0)
    then
      (retract ?f1)
      (assert (start ?id))
      (assert (exec (step ?s) (action Forward)))
    else
      (assert (plan-failed))
  )
)

(defrule run-plane-forward-east
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id Forward east ?r ?c) (cost ?g))
  (K-cell (pos-r ?r) (pos-c =(+ ?c 1)) (contains ?con))
  (status (step ?s))
=>
  (if (= (str-compare ?con "Empty")0)
    then
      (retract ?f1)
      (assert (start ?id))
      (assert (exec (step ?s) (action Forward)))
    else
      (assert (plan-failed))
  )
)

(defrule run-plane-forward-west
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?g))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id Forward west ?r ?c) (cost ?g))
  (K-cell (pos-r ?r) (pos-c =(- ?c 1)) (contains ?con))
  (status (step ?s))
=>
  (if (= (str-compare ?con "Empty")0)
    then
      (retract ?f1)
      (assert (start ?id))
      (assert (exec (step ?s) (action Forward)))
    else
      (assert (plan-failed))
  )
)

(defrule clean-start
  (declare (salience 78))
  ?f1 <- (start ?father)
  ?f2 <- (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
=>
  (retract ?f1)
  (retract ?f2)
  (assert (start 0))
  (assert (plan-executed))
)

