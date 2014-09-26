;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun trash basket (Food)
(defrule distance-manhattan-tb
  (declare (salience 70))
  (exec-order (table-id ?id) (phase 2) (status delayed|finish))
  (K-agent (pos-r ?ra) (pos-c ?ca) (l_f_waste yes))
  (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains TB))
  =>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type trash-food)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun recyclable basket (Drink)
(defrule distance-manhattan-rb
  (declare (salience 70))
  (exec-order (table-id ?id) (phase 2) (status delayed|finish))
  (K-agent (pos-r ?ra) (pos-c ?ca) (l_d_waste yes))
  (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains RB))
  =>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type trash-drink)))
)

;Regola che cerca il dispenser/cestino più vicino
(defrule search-best-dispenser
  (declare (salience 60))
  (status (step ?current))
  (debug ?level)
  ?f1<-(exec-order (table-id ?id) (phase 2))
  (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rd1 ?cd1) (distance ?d)) 
  (not (strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rd2 ?cd2) (distance ?dist&:(< ?dist ?d)) ))
  (K-cell (pos-r ?rd1) (pos-c ?cd1) (contains ?c))
=>
  (assert(strategy-best-dispenser (pos-dispenser ?rd1 ?cd1) (type ?c)))
  (modify ?f1 (phase 3))

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F2:s"?current":"?id"] Dispenser/Basket Found: " ?c " in ("?rd1", "?cd1")"  crlf)
    (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 3: Pianifica Astar verso dispenser " ?c " in ("?rd1", "?cd1")"  crlf)
  )
)


;
; FASE 3 della Strategia: Pianificare con astar un piano per raggiungere il dispenser/cestino più vicino. Eseguire il piano.
;

; pulisce le distanze ai dispensers/cestini
(defrule clean-distance-dispenser
  (declare (salience 80))
  (status (step ?current))
  (exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1 <- (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d))
=>
  (retract ?f1)
)

;Controlle se esiste un piano per andare al best dispenser/trash con status OK
(defrule strategy-existence-plane-3
  (declare (salience 10))
  (exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  (K-agent (pos-r ?ra) (pos-c ?ca))
  (plane (plane-id ?pid)(pos-start ?ra ?ca) (pos-end ?rd ?cd) (status ok))
=>
  (assert (plane-exist ?pid))
)
;Se il piano non esiste allora devo avviare astar per cercare un percorso che mi porti a destinazione.
(defrule strategy-create-plane-3
  (declare (salience 1))
  (exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  (not (plane-exist))
=>
  (assert (start-astar (pos-r ?rd) (pos-c ?cd)))
)

;Se il piano esiste allo lo eseguo.
(defrule strategy-execute-plane-3
  (declare (salience 1))
  (exec-order (table-id ?id) (phase 3) )
  ?f1<-(plane-exist ?pid)
  (plane  (plane-id ?pid) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (direction ?d) (status ok))
=>
  (assert (run-plane-astar (plane-id ?pid) (pos-start ?ra ?ca ?d) (pos-end ?rd ?cd) (phase 1)))
  (retract ?f1)
)

;Eseguito il piano, il robot si trova vicino al dispenser/cestino piu vicino.
(defrule strategy-go-phase4
  (declare (salience 1))
  (status (step ?current))
  (debug ?level)
  (plan-executed (plane-id ?pid) (step ?current) (pos-start ?rs ?cs) (pos-end ?rg ?cg) (result ok))
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
  (declare (salience 20))
  (status (step ?current))
  (debug ?level)
  (plan-executed (plane-id ?pid) (step ?current) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (result fail))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1<-(plane (plane-id ?pid) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (status ok))
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
  (declare(salience 20))
  (debug ?level)
  (status (step ?current))
  ?f1<-(exec-order (table-id ?id) (step ?s2) (phase 3))
  ?f2<-(strategy-best-dispenser (type ?c) (pos-dispenser ?rd ?cd))
  ?f3<-(astar-solution (value no))
  ?f4<-(K-agent)
=>
  (modify ?f1 (step ?current) (phase 0))
  (modify ?f4)
  (retract ?f2 ?f3)

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F3:s"?current":"?id"] A-Star not found solution to the dispenser: "?c" in ("?rd","?cd")" crlf)
    (printout t " [DEBUG] [F3:s"?current":"?id"] Order moved to the bottom." crlf)
  )
)

; regola per scaricare il cibo
; ===========================
; controllo che ci sia del l_f_waste
; controllo che l'agente possa operare sul trash basket ovvero che sia in una posizione adiacente.
(defrule strategy-do-EmptyFood
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)

  (exec-order (step ?s2) (table-id ?id) (phase 4))
  (strategy-best-dispenser (pos-dispenser ?rfo ?cfo) (type TB))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l_f_waste yes))
 
  (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
      (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
      (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
      (and (test(= ?ra (- ?rfo 1))) (test(= ?ca ?cfo)))
  )
=>
  (assert (exec (step ?ks) (action EmptyFood) (param1 ?rfo) (param2 ?cfo)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4:s"?current":"?id"] EmptyFood in TrashBasket: ("?rfo","?cfo")" crlf)
  )
)

; regola per scaricare il drink
; ===========================
; controllo che ci sia del l_d_waste
; controllo che l'agente possa operare sul trash basket ovvero che sia in una posizione adiacente.
(defrule strategy-do-Release
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)

  (exec-order (step ?s2) (table-id ?id) (phase 4))
  (strategy-best-dispenser (pos-dispenser ?rfo ?cfo) (type RB))
  ;controllo che l'agente possa operare sul disp.
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l_d_waste yes))
  (or (and (test(= ?ra ?rfo)) (test(= ?ca (+ ?cfo 1))))
      (and (test(= ?ra ?rfo)) (test(= ?ca (- ?cfo 1))))
      (and (test(= ?ra (+ ?rfo 1))) (test(= ?ca ?cfo)))
      (and (test(= ?ra (- ?rfo 1))) (test(= ?ca ?cfo)))
  )
=>
  (assert (exec (step ?ks) (action Release) (param1 ?rfo) (param2 ?cfo)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4:s"?current":"?id"] Release drink in RecyclableBasket: ("?rfo","?cfo")" crlf)
  )
)

; Una volta caricato o scaricato rimuovo il fatto best-dispenser. 
; Nel caso del carico controllo che non abbia ancora drink o food di quell'ordine da caricare
(defrule strategy-clean-best-dispenser
        (declare (salience 60))
        ?f1<-(exec-order (drink-order ?do) (food-order ?fo) (phase 4))
        ?f2 <- (strategy-best-dispenser)
=>  
        (retract ?f2)
        (modify ?f1 (phase 4.5))
)