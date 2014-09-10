;strategia FIFO un tavolo alla volta
; FASE 1, ricerca di un tavolo da servire
; FASE 2, individuare dispenser più vicino
; FASE 3, astar verso il dispenser più vicino ed esecuzione piano
; FASE 4, caricamento food/drink
; FASE 4.5, caricamento food/drink terminato, controllo se c'è ancora food/drink da caricare e c'è ancora spazio.
; FASE 5, A-star verso il tavolo ed esecuzione piano
; FASE 6, controllo action e scarica food/drink o carica trash
;      6.1, controllo di ritorno a fase 2 se c'è ancora roba da servire a quel tavolo
;      6.2, l'ordine è completato, vai alla fase 7
; FASE 7, ordine completato, retract service-table

;Regole per rispondere alla richiesta ordini da parte dei tavoli.
;Attiva quando ricevo un ordine da un tavolo Inform con accepted
(defrule answer-msg-order1
	(declare (salience 100))
  (status (step ?current))
	(msg-to-agent (request-time ?t) (step ?current) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (pos-r ?r) (pos-c ?c) (table-id ?sen) (clean yes))
=>
	(assert (exec (step ?current) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
)

;Attiva quando ricevo un ordine da un tavolo sporco che per specifica assumiamo abbia inviato precedentemente una finish. Inform con strategy-return-phase6-to-2_delayed
(defrule answer-msg-order2
	(declare (salience 100))
  (status (step ?current))
	(msg-to-agent (request-time ?t) (step ?current) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
	(K-table (table-id ?sen) (clean no))
=>
  (assert (exec (step ?current) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed)))
)

;
; FASE 1 della Strategia: Ricerca di un tavolo da servire.
;

;Se ho inviato delle Inform con accepted, e non sto servendo nessun tavolo, allora devo prendermi l'impegno di servire un tavolo. Quale? Strategia FIFO
(defrule strategy-go-phase1
  (declare (salience 70))
  (status (step ?current))

  ; cerca una exec di tipo inform
	(exec (step ?s) (action Inform) (param1 ?sen) (param2 ?t) (param3 ?status))

  ; @TODO cambiare per gestire più tavoli
	(not (strategy-service-table (table-id ?id) (phase ?ph)))
	(last-intention (step ?s1))
	(test (> ?s ?s1))
  (debug ?level)
=>
	(assert (strategy-service-table (step -1) (table-id -1) (phase 1) (action ?status) (fl 0) (dl 0)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F0:s"?current":"-1"] Inizializza Fase 1, tavolo probabile: " ?sen crlf)
  )
)

;Individua il tavolo da servire secondo la strategia FIFO
;Effettua una ricerca all'indietro all'interno dei fatti exec per trovare il tavolo, in ordine di tempo più vecchio, che ha effettuato un'ordinazione non ancora servita.
(defrule strategy-search-table-to-serve
	(status (step ?current))
	?f <- (strategy-service-table (step ?as) (table-id ?) (phase 1) (action accepted))
	(exec (step ?s2&:(< ?s2 ?current)) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
	(last-intention (step ?s1))
	(test (> ?s2 ?s1))
	(or (test (< ?s2 ?as)) (test (= ?as -1))) ; da controllare, forse ridondante, il discorso dell & potrebbe già selezionare la più piccolare
	(msg-to-agent (request-time ?t) (step ?s2) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
=>
	(modify ?f (step ?s2) (table-id ?sen) (fl ?fo) (dl ?do))
)

;Trovato il tavolo, passo alla fase due della strategia.
;Questa regola mi serve per indicare il fatto che non vi sono ordinazioni più vecchie di quella trovata non ancora servita. Blocca la ricerca.
(defrule strategy-found-table-to-serve
  (status (step ?current))
  ?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 1) (action accepted))
  ?f2 <- (last-intention (step ?s1))
  (not (exec (step ?s2&:(and (> ?s2 ?s1) (< ?s2 ?step))) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
  (exec (step ?s2) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted))
  (debug ?level)
=>
	(modify ?f1 (table-id ?id) (phase 2))
  (modify ?f2 (step ?s2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F1:s"?current":"?id"-SERVE] Tavolo da servire trovato: " ?sen crlf)
  )
)

(defrule strategy-found-table-to-clean
  (status (step ?current))
  ?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 1) (action delayed))
  ?f2 <- (last-intention (step ?s1))
  (not (exec (step ?s2&:(and (> ?s2 ?s1) (< ?s2 ?step))) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed)))
  (exec (step ?s2) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed))

  (debug ?level)
=>
  (modify ?f1 (step ?s2) (table-id ?sen) (phase 5))
  (modify ?f2 (step ?s2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F1:s"?current":"?id"-CLEAN] Table to clean found: " ?sen crlf)
  )
)

;
; FASE 2 della Strategia: Individuare il dispenser più vicino
;

; Initializza la fase 2
; =====================
; Appena viene avviata la fase 2 viene inserito un fatto best-dispenser
(defrule strategy-initialize-phase2
	(declare (salience 75))
  (status (step ?current))
  (debug ?level)

	(strategy-service-table (table-id ?id) (phase 2) (action ?a))
=>
	(assert (best-dispenser (distance 100000) (pos-best-dispenser null null)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F2:s"?current":"?id"] Init Phase 2 - Searching Best Dispenser... (action: " ?a ")" crlf)
  )
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun food-dispenser
(defrule distance-manhattan-fo
	(declare (salience 70))
	(strategy-service-table (table-id ?id) (phase 2) (fl ?fl) (action accepted))
	(test (> ?fl 0))
	(K-agent (pos-r ?ra) (pos-c ?ca))
	(K-cell (pos-r ?rfo) (pos-c ?cfo) (contains FD))
	=>
	(assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type food)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun drink-dispenser
(defrule distance-manhattan-do
	(declare (salience 70))
	(strategy-service-table (table-id ?id) (phase 2) (dl ?dl) (action accepted))
	(test (> ?dl 0))
	(K-agent (pos-r ?ra)(pos-c ?ca))
	(K-cell (pos-r ?rdo) (pos-c ?cdo) (contains DD))
	=>
	(assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance (+ (abs(- ?ra ?rdo)) (abs(- ?ca ?cdo)))) (type drink)))
)

(defrule distance-manhattan-tb
  (declare (salience 70))
  (strategy-service-table (table-id ?id) (phase 2) (action delayed))
  (K-agent (pos-r ?ra) (pos-c ?ca) (l_f_waste yes))
  (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains TB))
  =>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type trash-food)))
)

(defrule distance-manhattan-rb
  (declare (salience 70))
  (strategy-service-table (table-id ?id) (phase 2) (action delayed))
  (K-agent (pos-r ?ra) (pos-c ?ca) (l_d_waste yes))
  (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains RB))
  =>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type trash-drink)))
)

;Regola che cerca il dispenser più vicino
(defrule search-best-dispenser
	(declare (salience 60))
	?f1<-(best-dispenser (distance ?wd))
	(strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rd ?cd) (distance ?d&:(< ?d ?wd)))
=>
	(modify ?f1 (distance ?d) (pos-best-dispenser ?rd ?cd))
)

;Trovato il dispenser più vicino passo alla fase 3
;Questa regola mi serve per indicare il fatto che non vi sono dispenser più vicini di quello trovato. Blocca la ricerca.
(defrule found-best-dispenser
	(declare (salience 60))
  (status (step ?current))
  (debug ?level)

	?f1<-(best-dispenser (distance ?wd) (pos-best-dispenser ?rd ?cd))
	(not (strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d&:(< ?d ?wd))))
  (strategy-distance-dispenser (type ?type))
	?f2<-(strategy-service-table (table-id ?id) (phase 2) (action ?a))
	(K-cell (pos-r ?rd) (pos-c ?cd) (contains ?c))
=>
	(modify ?f2 (phase 3))
	(assert (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c)))
	(retract ?f1)

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F2:s"?current":"?id"] Dispenser/Basket Found: " ?type " in ("?rd", "?cd") (action: " ?a ")"  crlf)
  )
)

;
; FASE 3 della Strategia: Pianificare con astar un piano per raggiungere il dispenser più vicino. Eseguire il piano.
;

; pulisce le distanze ai dispensers
(defrule strategy-initialize-phase3
  (declare (salience 80))
  (status (step ?current))
  (debug ?level)

  (strategy-service-table (table-id ?id) (phase 3))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1 <- (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d))
=>
  (retract ?f1)

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 3 - A-star towards best dispenser: "?c" in ("?rd","?cd")" crlf)
  )
)

;regole per avviare astar
(defrule start-astar-to-dispenser
  (declare (salience 70))
  (strategy-service-table (table-id ?id) (phase 3) (step ?s) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  (msg-to-agent (step ?s) (sender ?id) (food-order ?fo))
=>
	(assert (start-astar (pos-r ?rd) (pos-c ?cd)))
)

;Se esiste un piano per andare in una determinata posizione, e ho l'intenzione di andarci allora eseguo il piano.
(defrule clean-start-astar


  (strategy-service-table (table-id ?id) (phase 3))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1<-(start-astar (pos-r ?rd) (pos-c ?cd))
  (plane (pos-start ?r1 ?c1) (pos-end ?rd ?cd))
=>
  (retract ?f1)
  (assert (run-plane-astar (pos-start ?r1 ?c1) (pos-end ?rd ?cd)))
)

;Eseguito il piano, il robot si trova vicino ad dispenser piu vicino.
(defrule strategy-go-phase4
  (status (step ?current))
  (debug ?level)

  ?f1<-(plan-executed)
	?f2<-(strategy-service-table (table-id ?id) (phase 3))
	(strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
=>
	(retract ?f1)
	(modify ?f2 (phase 4))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4:s"?current":"?id"] Init Phase 4 - Agent in front of best dispenser: "?c" in ("?rd","?cd")" crlf)
  )
)

;
;  FASE 4 della Strategia: Il robot arrivato al dispenser carica
;

; regola per caricare il cibo
; ===========================
; controlla che ci sia ancora del food da caricare (controlla l'ordine strategy-service-table)
; controlla che non ci sia waste
; controlla che il truckload non sia pieno
; scatena azione di load-food verso dispenser
; scatena diminuzione fl in strategy-service-table
(defrule strategy-do-LoadFood
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)

  ?f1 <- (strategy-service-table (table-id ?id) (phase 4) (fl ?fl))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type FD))        ; posizione del food dispenser
	(test (> ?fl 0))                                                   ; food to load > 0
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
=>
	(modify ?f1 (fl (- ?fl 1)))
	(assert (exec (step ?ks) (action LoadFood) (param1 ?rd) (param2 ?cd)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4:s"?current":"?id"] Loading food in dipsenser FD: ("?rd","?cd")" crlf)
  )
)

; regola per caricare il drink
; ===========================
; medesime situazioni del food
(defrule strategy-do-LoadDrink
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)

  ?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type DD))
	(test (> ?dl 0)) ; ci sono ancora drink da caricare
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
=>
	(modify ?f1 (dl (- ?dl 1)))
	(assert (exec (step ?ks) (action LoadDrink) (param1 ?rd) (param2 ?cd)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4:s"?current":"?id"] Loading drink in dispenser DD: ("?rd","?cd")" crlf)
  )
)

; regola per caricare il drink
; ===========================
; medesime situazioni del food
(defrule strategy-do-EmptyFood
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)

  ?f1 <- (strategy-service-table (table-id ?id) (phase 4) (fl ?fl))
  (strategy-best-dispenser (pos-dispenser ?rfo ?cfo) (type TB))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l_f_waste yes))
  ;controllo che l'agente possa operare sul disp
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

; regola per caricare il drink
; ===========================
; medesime situazioni del drink, RecyclaBasket
(defrule strategy-do-Release
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)

  ?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl))
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

(defrule strategy-clean-best-dispenser
	(declare (salience 70))
	?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl) (fl ?fl)) ;sei in fase 4
	?f2 <- (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?type)) ;c'è un fatto best dispenser da rimuovere
	(test (or (= ?dl 0) (= ?fl 0)))  ; hai caricato tutti i drink o food per quell'ordine
=>
	(retract ?f2)
	(modify ?f1 (phase 4.5))
)

;
; FASE 4.5 della Strategia: Controllo se ritornare alla fase 2 per caricare altra roba o andarea alla fase 5.
;
(defrule strategy-return-phase2_order
  (status (step ?current))
  (debug ?level)

	?f1 <- (strategy-service-table (table-id ?id) (phase 4.5) (dl ?dl) (fl ?fl) (action accepted))
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(test (< (+ ?lf ?ld) 4))
	(test (or (> ?dl 0) (> ?fl 0)))
=>
	(modify ?f1 (phase 2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4.5:s"?current":"?id"] Agent has space available, return to Phase 2: order (food: "?fl", drink: "?dl")" crlf)
  )
)

(defrule strategy-return-phase2_clean
  (status (step ?current))
  (debug ?level)

  ?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 4.5) (action delayed))
  (msg-to-agent (request-time ?t) (step ?step) (sender ?id) (type order) (drink-order ?do) (food-order ?fo))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste ?ldw) (l_f_waste ?lfw))
=>
  (if (or (= (str-compare ?ldw "yes") 0) (= (str-compare ?lfw "yes") 0))
  then
  (modify ?f1 (phase 2))
  else
  (modify ?f1 (phase 2) (dl ?do) (fl ?fo) (action accepted))
  )

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4.5:s"?current":"?id"] Agent has trash, return to Phase 2: agent trash (food: "?lfw", drink: "?ldw")" crlf)
  )
)

; L'agente ha caricato tutti i food o drink per quell'ordine, possiamo andare alla fase 5, cioè cercare il piano per arrivare al tavolo
(defrule strategy-go-phase5
  (status (step ?current))
  (debug ?level)

	?f1<-(strategy-service-table (table-id ?id) (phase 4.5) (dl ?dl) (fl ?fl) (action ?a))
	(K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
	(or
    (test (= (+ ?lf ?ld) 4))
		(test (and (= ?dl 0) (= ?fl 0)))
	)
=>
	(modify ?f1 (phase 5))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F5:s"?current":"?id"] Init Phase 5, a-star towards table "?id", order (food: "?fl", drink: "?dl") action "?a crlf)
  )
)

;
; FASE 5 della Strategia: Esecuzione di astar per determinare il piano per arrivare al tavolo ed esecuzione del piano.
;

(defrule strategy-start-astar-to-table
	(strategy-service-table (table-id ?id) (phase 5) (step ?s) )
	(K-table (pos-r ?r) (pos-c ?c) (table-id ?id))
=>
	(assert (start-astar (pos-r ?r) (pos-c ?c)))
)

;Se esiste un piano per andare in una determinata posizione, e ho l'intenzione di andarci allora eseguo il piano.
(defrule clean-start-astar-to-table
    (strategy-service-table (table-id ?id) (phase 5))
    ?f1<-(start-astar (pos-r ?r) (pos-c ?c))
	(plane (pos-start ?r1 ?c1) (pos-end ?r ?c))
=>
    (retract ?f1)
	(assert (run-plane-astar (pos-start ?r1 ?c1) (pos-end ?r ?c)))
)

;Eseguito il piano, il robot si trova vicino al tavolo.
(defrule strategy-go-phase6
  (status (step ?current))
  (debug ?level)

	?f1<-(plan-executed)
	?f2<-(strategy-service-table (table-id ?id) (fl ?fl) (dl ?dl) (phase 5) (action ?a))
=>
	(retract ?f1)
	(modify ?f2 (phase 6))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"] Init Phase 6, table approached deliveryclean, order (food: "?fl", drink: "?dl") action ("?a")" crlf)
  )
)

;
; FASE 6 della Strategia: il robot è arrivato al tavolo e deve scaricare.
;

(defrule strategy-do-DeliveryFood
  (status (step ?current))
  (debug ?level)

  (strategy-service-table (table-id ?id) (phase 6) (action accepted))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf))
  (Table (table-id ?id) (pos-r ?rfo) (pos-c ?cfo))
  (test (> ?lf 0))
=>
  (assert (exec (step ?ks) (action DeliveryFood) (param1 ?rfo) (param2 ?cfo)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-SERVE] Delivery Food" crlf)
  )
)

(defrule strategy-do-DeliveryDrink
  (status (step ?current))
  (debug ?level)

  (strategy-service-table (table-id ?id) (phase 6) (action accepted))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-drink ?ld))
  (Table (table-id ?id) (pos-r ?rfo) (pos-c ?cfo))
  (test (> ?ld 0))
=>
  (assert (exec (step ?ks) (action DeliveryDrink) (param1 ?rfo) (param2 ?cfo)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-SERVE] Delivery Drink" crlf)
  )
)

(defrule strategy-do-CleanTable
  (status (step ?current))
  (debug ?level)

  (strategy-service-table (table-id ?id) (phase 6) (action delayed))
  ?f1 <- (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-drink ?ld) (l-food ?lf))
  ?f2 <- (K-table (table-id ?id) (pos-r ?rt) (pos-c ?ct) (clean no))
  ;controllo che l'agente posso operare sul tavolo.
  (or (and (test(= ?ra ?rt)) (test(= ?ca (+ ?ct 1))))
      (and (test(= ?ra ?rt)) (test(= ?ca (- ?ct 1))))
      (and (test(= ?ra (+ ?rt 1))) (test(= ?ca ?ct)))
      (and (test(= ?ra (- ?rt 1))) (test(= ?ca ?ct)))
  )
  ; controlla che l'agente sia scarico
  (test (= (+ ?ld ?lf) 0))
=>
  (assert (exec (step ?ks) (action CleanTable) (param1 ?rt) (param2 ?ct)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-CLEAN] CleanTable" crlf)
  )
)

;
; FASE 7 della Strategia
;

(defrule strategy-return-phase6-to-2_accepted
  (status (step ?current))
  (debug ?level)

  ; ho scaricato tutta la roba
  ?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 6) (dl ?dl) (fl ?fl) (action accepted))
  (test (> (+ ?dl ?fl) 0))
  ; controllo che sul tavolo ci sia tutto
  ;(Table (table-id ?id) (l-drink ?dl) (l-food ?fl))
  ;(msg-to-agent (step ?step) (sender ?id) (type order) (drink-order ?dl) (food-order ?fl))
  (K-agent (l-drink 0) (l-food 0))
=>
  (modify ?f1 (phase 2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-SERVE] Order not completed, return to phase 2, order (food: "?fl", drink: "?dl")" crlf)
  )
)

(defrule strategy-return-phase6-to-2_delayed
  (status (step ?current))
  (debug ?level)

  ; ho scaricato tutta la roba
  ?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 6) (action delayed))
  ; controllo che sul tavolo ci sia tutto
  ;(Table (table-id ?id) (l-drink ?dl) (l-food ?fl))
  ;(msg-to-agent (step ?step) (sender ?id) (type order) (drink-order ?dl) (food-order ?fl))
  (K-agent (l_d_waste yes) (l_f_waste yes))
=>
  (modify ?f1 (phase 2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-CLEAN] CleanTable, sono pieno di trash, return to phase 2" crlf)
  )
)

(defrule strategy-go-phase-7
  (status (step ?current))
  (debug ?level)

  ; ho scaricato tutta la roba
  ?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 6) (dl 0) (fl 0))
  ; controllo che sul tavolo ci sia tutto
  ;(Table (table-id ?id) (l-drink ?dl) (l-food ?fl))
  ;(msg-to-agent (step ?step) (sender ?id) (type order) (drink-order ?dl) (food-order ?fl))
  (K-agent (l-drink 0) (l-food 0))
=>
  (retract ?f1)

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"] Phase 7" crlf)
  )
)
