(deffacts initial-fact
  (start 0)
)

(defrule run-plane
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id ?oper ?d ?r ?c) (cost ?g))
  (status (step ?s))
  =>
  (retract ?f1)
  (assert (start ?id))
  (assert (exec (step ?s) (action ?oper)))
)

(defrule clean-start
  (declare (salience 79))
  ?f1 <- (start ?father)
  ?f2 <- (run-plane-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  =>
  (retract ?f1)
  (retract ?f2)
  (assert (start 0))
)
  