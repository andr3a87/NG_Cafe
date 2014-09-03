; PERCEZIONI PER IL WEST TRASFORMATE SULLE K-CELL
(defrule k-percept-west
  (declare (salience 100))		
	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s) (type movement))
	(test (> ?s ?old-s))
	(perc-vision 
        (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west) 
        (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
				(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
				(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
    )
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

    ?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f2 <- (K-cell (pos-r ?r)  	(pos-c =(- ?c 1)))
	?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
	?f4 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f5 <- (K-cell (pos-r ?r)  	(pos-c ?c) )
	?f6 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c) )
	?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))	
	?f8 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))	
	?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))

=> 
    (modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction west))
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)

; PERCEZIONI PER IL EAST TRASFORMATE SULLE K-CELL
(defrule k-percept-east
  (declare (salience 100))
	(status (step ?s))
  ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s) (type movement))
	(test (> ?s ?old-s))
	(perc-vision 
        (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east) 
	    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
	)
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

	?f1 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))
	?f2 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))
	?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f5 <- (K-cell (pos-r ?r)  	(pos-c ?c))
	?f6 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))	
	?f8 <- (K-cell (pos-r ?r)	(pos-c =(- ?c 1)))	
	?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
=> 
    (modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction east))
	(modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)


; PERCEZIONI PER IL SOUTH TRASFORMATE SULLE K-CELL
(defrule k-percept-south
  (declare (salience 100))
	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s)(type movement))
	(test (> ?s ?old-s))
	(perc-vision 
        (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south) 
	    (perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
	    (perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
	    (perc7 ?x7) (perc8 ?x8) (perc9 ?x9)

	)
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

	?f1 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
	?f2 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f3 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f4 <- (K-cell (pos-r ?r)  	(pos-c =(+ ?c 1)))
	?f5 <- (K-cell (pos-r ?r)  	(pos-c ?c))
	?f6 <- (K-cell (pos-r ?r)  	(pos-c =(- ?c 1)))
	?f7 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f8 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f9 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(- ?c 1)))
=> 
	(modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction south))
    (modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))
)

; PERCEZIONI PER IL NORTH TRASFORMATE SULLE K-CELL
(defrule k-percept-north
  (declare (salience 100))
	(status (step ?s))
    ;//per evitare di mandare sempre in esecuzione questa regola.Una volta eseguita non deve essere più attivabile.
	?fs <- (last-perc (step ?old-s) (type movement))
	(test (> ?s ?old-s))
	(perc-vision 
		(time ?t) (step ?s) (pos-r ?r) (pos-c ?c) (direction north) 
		(perc1 ?x1) (perc2 ?x2) (perc3 ?x3)
		(perc4 ?x4) (perc5 ?x5) (perc6 ?x6)
		(perc7 ?x7) (perc8 ?x8) (perc9 ?x9)
	)
	?fa <- (K-agent (step ?) (time ?) (pos-r ?) (pos-c ?) (direction ?) (l-drink ?) (l-food ?) (l_d_waste ?) (l_f_waste ?))

    ?f1 <- (K-cell (pos-r =(+ ?r 1))	(pos-c =(- ?c 1)))
	?f2 <- (K-cell (pos-r =(+ ?r 1)) (pos-c ?c))
	?f3 <- (K-cell (pos-r =(+ ?r 1)) (pos-c =(+ ?c 1)))
	?f4 <- (K-cell (pos-r ?r) 	(pos-c =(- ?c 1)))
	?f5 <- (K-cell (pos-r ?r) 	(pos-c ?c))
	?f6 <- (K-cell (pos-r ?r) 	(pos-c =(+ ?c 1)))
	?f7 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(- ?c 1)))
	?f8 <- (K-cell (pos-r =(- ?r 1)) (pos-c ?c))
	?f9 <- (K-cell (pos-r =(- ?r 1)) (pos-c =(+ ?c 1)))
    => 
	(modify ?fa (step ?s) (time ?t) (pos-r ?r) (pos-c ?c) (direction north))
    (modify ?f1 (contains ?x1))
	(modify ?f2 (contains ?x2))
	(modify ?f3 (contains ?x3))
	(modify ?f4 (contains ?x4))
	(modify ?f5 (contains ?x5))
	(modify ?f6 (contains ?x6))
	(modify ?f7 (contains ?x7))
	(modify ?f8 (contains ?x8))
	(modify ?f9 (contains ?x9))
	(modify ?fs (step ?s))

)

(defrule k-percept-load-food
	(declare(salience 100))
	(perc-load (time ?t) (step ?s) (load yes))
	?fs <- (last-perc (step ?old-s) (type load))
	(test (> ?s ?old-s) )
	?f1<-(K-agent (step ?)(l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(exec (step =(- ?s 1))(action LoadFood))
	=>
	(modify ?f1(l-food(+ ?lf 1)))
	(modify ?fs (step ?s)))
		
)

(defrule k-percept-load-drink
	(declare(salience 100))
	(perc-load (time ?t) (step ?s) (load yes))
	?fs <- (last-perc (step ?old-s) (type load))
	(test (> ?s ?old-s))
	?f1<-(K-agent (step ?)(l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(exec (step =(- ?s 1))(action LoadDrink))
	=>
	(modify ?f1(l-drink(+ ?ld 1))) 
	(modify ?fs (step ?s))
		
)