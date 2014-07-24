
(deffacts initial-fact
  (start 0)
)

(defrule run-plane
  (declare (salience 80))
  ?f1 <- (start ?father)
  (run-astar (pos-start ?rs ?cs) (pos-end ?rg ?cg))
  (plane (pos-start ?rs ?cs) (pos-end ?rg ?cg) (exec-astar-sol ?father ?id ?oper ?d ?r ?c) (cost ?g))
  (status (step ?s))
  =>
  (retract ?f1)
  (assert (start ?id))
  (assert (exec (step ?s) (action ?oper)))
)
  