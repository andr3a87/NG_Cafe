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
  (declare (salience 150))
  (status (step ?current))
  (msg-to-agent (request-time ?t) (step ?current) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
  (K-table (pos-r ?r) (pos-c ?c) (table-id ?sen) (clean yes))
=>
  (assert (exec (step ?current) (action Inform) (param1 ?sen) (param2 ?t) (param3 accepted)))
  (assert (exec-order (step ?current) (action Inform) (table-id ?sen) (time-order ?t) (status accepted) (drink-order ?do) (food-order ?fo) (phase 0) (fail 0)))
)

;Attiva quando ricevo un ordine da un tavolo sporco che per specifica assumiamo abbia inviato precedentemente una finish. 
;Inform con strategy-return-phase6-to-2_delayed
(defrule answer-msg-order2
  (declare (salience 150))
  (status (step ?current))
  (msg-to-agent (request-time ?t) (step ?current) (sender ?sen) (type order) (drink-order ?do) (food-order ?fo))
  (K-table (table-id ?sen) (clean no))
=>
  (assert (exec (step ?current) (action Inform) (param1 ?sen) (param2 ?t) (param3 delayed)))
  (assert (exec-order (step ?current) (action Inform) (table-id ?sen) (time-order ?t) (status delayed) (drink-order ?do) (food-order ?fo) (phase 0) (fail 0)))
)

;Attiva quando ricevo un 'ordine' di finish da un tavolo sporco. 
(defrule answer-msg-order3
  (declare (salience 150))
  (status (step ?current))
  (msg-to-agent (request-time ?t) (step ?current) (sender ?sen) (type finish))
=>
  (assert (exec-order (step ?current)(action Finish) (table-id ?sen) (time-order ?t) (status finish) (drink-order 0) (food-order 0) (phase 0) (fail 0)))
)

;
; FASE 1 della Strategia: Ricerca di un tavolo da servire.
;

;Ricerca dell'ordine da servire. La ricerca avviene sia sulle Inform che sulle Finish. Si ricerca l'ordine più vecchio non ancora servito.
(defrule strategy-go-phase1
  (declare (salience 70))
  (status (step ?current) )
  (debug ?level)
  ?f1 <- (last-intention (step ?last) (time ?time))
  ; cerca una exec di tipo inform
  ?f2<-(exec-order (step ?next&:(and (> ?next ?last) (<= ?next ?current))) (action Inform|Finish) (table-id ?sen) (time-order ?t) (status ?status))
  (not (exec-order (step ?lol&:(and (< ?lol ?next) (> ?lol ?last) (< ?lol ?current)))  (action Inform|Finish)))

  ; @TODO cambiare per gestire più tavoli
  ;La ricerca avviene solo ne caso non stia servendo nessun altro ordine, ovvero non esiste un ordine che è nelle fasi 1,2,3,4,5,6 o 7
  (not (exec-order (phase 1|2|3|4|4.5|5|6|7)))
=>
  (modify ?f1 (step ?next) (time ?t))
  (modify ?f2 (phase 1))

  ;debug
  (if (> ?level 0)
    then
      (printout t " [DEBUG] [F0:s"?current":"-1"] Inizializza Fase 1 - target tavolo: " ?sen crlf)
  )
)

;Trovato l'ordine eseguo la fase di competenza
(defrule strategy-complete-phase1
  (declare (salience 70))
  (status (step ?s1))
  ;?f1 <- (strategy-service-table (step ?s2) (table-id ?id) (phase 1) (action ?status))
  ?f1 <- (exec-order (step ?s2) (drink-order ?do) (food-order ?fo) (table-id ?id) (status ?status)  (phase 1) )
  (K-table (table-id ?id) (clean ?clean))
  (K-agent (l-drink ?ld) (l-food ?lf) (l_d_waste ?ldw) (l_f_waste ?lfw))
=>
  ; vado alla fase 2 se l'ordine è accettato, ovvero posso cercare già il dispenser più vicino
  (if (=(str-compare ?status "accepted") 0) 
  then
    (modify ?f1 (table-id ?id) (phase 2))
  )
  ; se l'ordine è delayed e il tavolo è sporco (ossia non l'ho ancora pulito), vado alla fase 5
  (if (and (= (str-compare ?status "delayed") 0) (=(str-compare ?clean "no")0))
  then
    (modify ?f1 (table-id ?id) (phase 5))
  )
  ; se l'ordine è delayed e il tavolo è pulito (ossia l'ho già pulito) modifico in accepted, così da gestirlo come un ordine normale.
  (if (and (= (str-compare ?status "delayed") 0) (=(str-compare ?clean "yes")0))
  then
    (modify ?f1 (status accepted))
  )
  ; se ho ricevuto una finish e non ho cibo caricato vado a pulire il tavolo
  (if (= (str-compare ?status "finish") 0)  
  then
    (modify ?f1 (table-id ?id) (phase 5))
  )
)

;
; FASE 2 della Strategia: Individuare il dispenser/cestino più vicino.
;

; Initializza la fase 2
; =====================
; Appena viene avviata la fase 2 viene asserito un fatto best-dispenser
(defrule strategy-initialize-phase2
  (declare (salience 75))
  (status (step ?current))
  (debug ?level)
  ;?f1<-(strategy-service-table (table-id ?id) (phase 2) (action ?a) (fl ?fl) (dl ?dl))
  ?f1 <- (exec-order (drink-order ?do) (food-order ?fo) (table-id ?id) (phase 2) (status ?a))
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
        ;(strategy-service-table (table-id ?id) (phase 2) (fl ?fl) (action accepted))
        (exec-order (food-order ?fo) (table-id ?id) (phase 2) (status accepted))
        (K-agent (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld))
        (test (> ?fo 0))
        (test (< ?lf ?fo))
        (test (< (+ ?lf ?ld) 4))

        (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains FD))
        =>
        (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type food)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun drink-dispenser 
(defrule distance-manhattan-do
  (declare (salience 70))
  ;(strategy-service-table (table-id ?id) (phase 2) (dl ?dl) (action accepted))
  (exec-order (drink-order ?do) (table-id ?id) (phase 2) (status accepted))
  (K-agent (pos-r ?ra)(pos-c ?ca) (l-food ?lf) (l-drink ?ld))
  (test (> ?do 0))
  (test (< ?ld ?do))
  (test (< (+ ?lf ?ld) 4))

  (K-cell (pos-r ?rdo) (pos-c ?cdo) (contains DD))
=>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance (+ (abs(- ?ra ?rdo)) (abs(- ?ca ?cdo)))) (type drink)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun trash basket (Food)
(defrule distance-manhattan-tb
  (declare (salience 70))
  ;(strategy-service-table (table-id ?id) (phase 2) (action delayed|finish))
  (exec-order (table-id ?id) (phase 2) (status delayed|finish))
  (K-agent (pos-r ?ra) (pos-c ?ca) (l_f_waste yes))
  (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains TB))
  =>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type trash-food)))
)

;Regola che calcola la distanza di manhattan dalla posizione corrente del robot a ciascun recyclable basket (Drink)
(defrule distance-manhattan-rb
  (declare (salience 70))
  ;(strategy-service-table (table-id ?id) (phase 2) (action delayed|finish))
  (exec-order (table-id ?id) (phase 2) (status delayed|finish))
  (K-agent (pos-r ?ra) (pos-c ?ca) (l_d_waste yes))
  (K-cell (pos-r ?rfo) (pos-c ?cfo) (contains RB))
  =>
  (assert (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rfo ?cfo) (distance (+ (abs(- ?ra ?rfo)) (abs(- ?ca ?cfo)))) (type trash-drink)))
)

;Regola che cerca il dispenser/cestino più vicino
(defrule search-best-dispenser
  (declare (salience 60))
  ?f1<-(best-dispenser (distance ?wd))
  (strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rd ?cd) (distance ?d&:(< ?d ?wd)))
=>
  (modify ?f1 (distance ?d) (pos-best-dispenser ?rd ?cd))
)

;Trovato il dispenser/cestino più vicino passo alla fase 3
;Questa regola mi serve per indicare il fatto che non vi sono dispenser più vicini di quello trovato. Blocca la ricerca.
(defrule found-best-dispenser
  (declare (salience 60))
  (status (step ?current))
  (debug ?level)

  ?f1<-(best-dispenser (distance ?wd) (pos-best-dispenser ?rd ?cd))
  (not (strategy-distance-dispenser  (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d&:(< ?d ?wd))))
  ;QUESTA REGOLA LA POSSO TOGLIERE??????????
  (strategy-distance-dispenser (type ?type))
  ;?f2<-(strategy-service-table (table-id ?id) (phase 2) (action ?a))
  ?f2 <- (exec-order (table-id ?id) (phase 2) (status ?a))
  (K-cell (pos-r ?rd) (pos-c ?cd) (contains ?c))
=>
  (modify ?f2 (phase 3))
  (assert (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c)))
  (retract ?f1)

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F2:s"?current":"?id"] Dispenser/Basket Found: " ?type " in ("?rd", "?cd") (action: " ?a ")"  crlf)
    (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 3: Pianifica Astar verso dispenser " ?type " in ("?rd", "?cd")"  crlf)
  )
)

(defrule strategy-all-loaded-go-phase5
  (declare (salience 70))
  (status (step ?current))
  (debug ?level)
  ;?f1<-(strategy-service-table (table-id ?id) (phase 2) (dl ?dl) (fl ?fl) (action accepted))
  ?f1<-(exec-order (table-id ?id) (phase 2) (food-order ?fo) (drink-order ?do) (status accepted))
  (not (strategy-distance-dispenser (type ?type)))
=>
  (modify ?f1 (phase 5))

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F2:s"?current":"?id"] Agent hasn't space available. Useless found dispenser."  crlf)
    (printout t " [DEBUG] [F5:s"?current":"?id"] Init Phase 5, a-star towards table "?id", order (food: "?fo", drink: "?do")" crlf)
  )
)


;
; FASE 3 della Strategia: Pianificare con astar un piano per raggiungere il dispenser/cestino più vicino. Eseguire il piano.
;

; pulisce le distanze ai dispensers/cestini
(defrule clean-distance-dispenser
  (declare (salience 80))
  (status (step ?current))

  ;(strategy-service-table (table-id ?id) (phase 3))
  (exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f1 <- (strategy-distance-dispenser (pos-start ?ra ?ca) (pos-end ?rdo ?cdo) (distance ?d))
=>
  (retract ?f1)
)

;regola per avviare astar
(defrule start-astar-to-dispenser
  (declare (salience 70))
  ;(strategy-service-table (table-id ?id) (phase 3) (step ?s) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  (exec-order (step ?s) (table-id ?id) (phase 3))
=>
  (assert (start-astar (pos-r ?rd) (pos-c ?cd)))
)

;Se esiste un piano per andare in una determinata posizione, e ho l'intenzione di andarci allora eseguo il piano.
(defrule clean-start-astar
  (declare (salience 75))
  (status (step ?current))
  ;(strategy-service-table (table-id ?id) (phase 3))
  (exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  (K-agent (pos-r ?ra) (pos-c ?ca))
  ?f1<-(start-astar (pos-r ?rd) (pos-c ?cd))
  (plane (pos-start ?ra ?ca ?d) (pos-end ?rd ?cd))
  ;(not(plan-executed (step ?current) (pos-start ?ra ?ca) (pos-end ?rd ?cd) (result fail)))
=>
  (retract ?f1)
  (assert (run-plane-astar (pos-start ?ra ?ca ?d) (pos-end ?rd ?cd) (phase 1)))
)

;Eseguito il piano, il robot si trova vicino al dispenser/cestino piu vicino.
(defrule strategy-go-phase4
  (status (step ?current))
  (debug ?level)
  (plan-executed (step ?current) (pos-start ?rs ?cs) (pos-end ?rg ?cg) (result ok))
  ;?f2<-(strategy-service-table (table-id ?id) (phase 3))
  ?f2<-(exec-order (table-id ?id) (phase 3) )
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
=>
  (modify ?f2 (phase 4) (fail 0))

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F4:s"?current":"?id"] Init Phase 4 - Agent in front of best dispenser: "?c" in ("?rd","?cd")" crlf)
  )
)

;Piano fallito, il robot deve ripianificare il percorso per raggiungere il best-dispenser. 
;Devo modificare K-agent altrimenti la regola S0 di astar non parte perche attivata più volte dal medesimo fatto
(defrule strategy-re-execute-phase3
  (status (step ?current))
  (debug ?level)
  (plan-executed (step ?current) (pos-start ?rs ?cs) (pos-end ?rg ?cg) (result fail))
  ;?f2<-(strategy-service-table (table-id ?id) (phase 3) (fail ?f))
  ?f2<-(exec-order (table-id ?id) (phase 3) (fail ?f))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type ?c))
  ?f3<-(K-agent)
=>
  (modify ?f2 (phase 3) (fail (+ ?f 1)))
  (modify ?f3)

  (assert (exec (step ?current) (action Wait)))
  

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 3: Plane Failed. Wait and try again." crlf)
  )
)

;Se non esiste un percorso per arrivare alla destinazione, vado in wait e riprovo.
;Devo modificare K-agent altrimenti la regola S0 di astar non parte perche attivata più volte dal medesimo fatto
(defrule strategy-change-order-in-phase3
  (declare(salience 10))
  (debug ?level)
  (status (step ?current))
  ?f1<-(exec-order (table-id ?id)(step ?s2) (phase 3) (fail ?f))
  ;?f2<-(strategy-service-table (step ?s2) (table-id ?id) (phase 3) (fail ?f))
  (strategy-best-dispenser (type ?c) (pos-dispenser ?rd ?cd))
  ?f2<-(astar-solution (value no))
  ?f3<-(K-agent)
  ?f4<-(start-astar)
=>
  (modify ?f1 (phase 3) (fail (+ ?f 1)))
  (modify ?f3)
  (retract ?f2 ?f4)

  (assert (exec (step ?current) (action Wait)))

  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F3:s"?current":"?id"] A-Star not found solution to the dispenser: "?c" in ("?rd","?cd")" crlf)
    (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 3: Plane Failed. Wait and try again." crlf)
  )
)
;
;  FASE 4 della Strategia: Il robot arrivato al dispenser/cestino carica/scarica.
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

  ;?f1 <- (strategy-service-table (table-id ?id) (phase 4) (fl ?fl))
  ?f1<-(exec-order (step ?s2) (table-id ?id) (phase 4) (food-order ?fo))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type FD))        ; posizione del food dispenser
  (test (> ?fo 0))                                                   ; food to load > 0
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (test (< (+ ?lf ?ld) 4))
  (test (> ?fo ?lf))
=>
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

  ;?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl))
  ?f1<-(exec-order (step ?s2) (table-id ?id) (phase 4) (drink-order ?do))
  (strategy-best-dispenser (pos-dispenser ?rd ?cd) (type DD))
  (test (> ?do 0)) ; ci sono ancora drink da caricare
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (test (< (+ ?lf ?ld) 4))
  (test (> ?do ?ld))
=>
  (assert (exec (step ?ks) (action LoadDrink) (param1 ?rd) (param2 ?cd)))
        
  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F4:s"?current":"?id"] Loading drink in dispenser DD: ("?rd","?cd")" crlf)
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

  ;?f1 <- (strategy-service-table (table-id ?id) (phase 4) (fl ?fl))
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

  ;?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl))
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
        ;?f1 <- (strategy-service-table (table-id ?id) (phase 4) (dl ?dl) (fl ?fl))
        ?f1<-(exec-order (drink-order ?do) (food-order ?fo) (phase 4))
        ?f2 <- (strategy-best-dispenser)
        (K-agent (l-food ?lf) (l-drink ?ld))
        (test (or (=(- ?fo ?lf)0) (=(- ?do ?ld)0) (= (+ ?lf ?ld)4) ))
=>  
        (retract ?f2)
        (modify ?f1 (phase 4.5))
)

;
; FASE 4.5 della Strategia: Controllo se ritornare alla fase 2 sia nel caso debba caricare altra roba, oppure se non ha finito di scaricare lo sporco. Altrimenti vado alla fase 5.
;

;Controllo se deve caricare altra roba
(defrule strategy-return-phase2_order
  (status (step ?current))
  (debug ?level)

    ;?f1 <- (strategy-service-table (table-id ?id) (phase 4.5) (dl ?dl) (fl ?fl) (action accepted))
    ?f1<-(exec-order (table-id ?id) (drink-order ?do) (food-order ?fo) (phase 4.5) (status accepted))
    (K-agent (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
    (test (< (+ ?lf ?ld) 4))
    (test (or (>(- ?fo ?lf)0) (>(- ?do ?ld)0)))
=>
    (modify ?f1 (phase 2))

    ;debug
    (if (> ?level 0)
    then
    (printout t " [DEBUG] [F4.5:s"?current":"?id"] Agent has space available, return to Phase 2" crlf)
    )
)

;Controllo se ho altro sporco da scaricare.
(defrule strategy-return-phase2_clean
  (status (step ?current))
  (debug ?level)

  ;?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 4.5) (action delayed))
  ?f1<-(exec-order (table-id ?id) (drink-order ?do) (food-order ?fo) (phase 4.5) (status delayed))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste ?ldw) (l_f_waste ?lfw))
=>
  (if (or (= (str-compare ?ldw "yes") 0) (= (str-compare ?lfw "yes") 0))
  then
    (modify ?f1 (phase 2))

    ;debug
    (if (> ?level 0)
    then
    (printout t " [DEBUG] [F4.5:s"?current":"?id"] Agent has trash, return to Phase 2: agent trash (food: "?lfw", drink: "?ldw")" crlf)
    )
  else
    (modify ?f1 (phase 2) (status accepted))

    ;debug
    (if (> ?level 0)
    then
    (printout t " [DEBUG] [F4.5:s"?current":"?id"] Agent has finished trashing, starting serving table" ?id crlf)
    )
  )

)
; Se era un ordine di finish e non ho sporco a bordo ho finito di pulire e vado alla fase 6. Altrimenti se ho ancora sporco vado alla 2.
(defrule strategy-return-phase2_finish
  (status (step ?current))
  (debug ?level)

  ;?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 4.5) (action finish))
  ?f1 <- (exec-order (table-id ?id) (drink-order ?do) (food-order ?fo) (phase 4.5) (status finish))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste ?ldw) (l_f_waste ?lfw))
=>
  (if (or (= (str-compare ?ldw "yes") 0) (= (str-compare ?lfw "yes") 0))
  then
    (modify ?f1 (phase 2))
    ;debug
    (if (> ?level 0)
    then
    (printout t " [DEBUG] [F4.5:s"?current":"?id"] (FINISH) Agent has trash, return to Phase 2: agent trash (food: "?lfw", drink: "?ldw")" crlf)
    )
  else
    (modify ?f1 (phase 6))
  )
)

; L'agente ha caricato tutti i food o drink per quell'ordine o è arrivato alla capienza max trasportabile, possiamo andare alla fase 5, cioè cercare il piano per arrivare al tavolo
(defrule strategy-go-phase5
  (status (step ?current))
  (debug ?level)

  ;?f1<-(strategy-service-table (table-id ?id) (phase 4.5) (dl ?dl) (fl ?fl) (action ?a))
  ?f1 <- (exec-order (table-id ?id) (drink-order ?do) (food-order ?fo) (phase 4.5) (status ?a))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf) (l-drink ?ld) (l_d_waste no) (l_f_waste no))
  (or (test (= (+ ?lf ?ld) 4))
      (test (or (<=(- ?fo ?lf)0) (<=(- ?do ?ld)0)))
  )
=>
  (modify ?f1 (phase 5))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F5:s"?current":"?id"] Init Phase 5, a-star towards table "?id", order (food: "?fo", drink: "?do") action "?a crlf)
  )
)

;
; FASE 5 della Strategia: Esecuzione di astar per determinare il piano per arrivare al tavolo ed esecuzione del piano.
;

(defrule strategy-start-astar-to-table
  (declare(salience 10))
  ;(strategy-service-table (table-id ?id) (phase 5) (step ?s) )
  (exec-order (table-id ?id) (phase 5))
  (K-table (pos-r ?r) (pos-c ?c) (table-id ?id))
=>
  (assert (start-astar (pos-r ?r) (pos-c ?c)))
)

;Se esiste un piano per andare in una determinata posizione, e ho l'intenzione di andarci allora eseguo il piano.
(defrule clean-start-astar-to-table
  (declare(salience 15))
  (status (step ?current))
  ;(strategy-service-table (table-id ?id) (phase 5))
  (exec-order (table-id ?id) (phase 5))
  ?f1<-(start-astar (pos-r ?r) (pos-c ?c))
  (K-agent (pos-r ?ra) (pos-c ?ca))
  (plane (pos-start ?ra ?ca ?d) (pos-end ?r ?c))
  ;(not(plan-executed (step ?current) (pos-start ?ra ?ca) (pos-end ?r ?c) (result fail)))
=>
  (retract ?f1)
  (assert (run-plane-astar (pos-start ?ra ?ca ?d) (pos-end ?r ?c) (phase 1)))
)

;Eseguito il piano, il robot si trova vicino al tavolo.
(defrule strategy-go-phase6
  (status (step ?current))
  (debug ?level)

  (plan-executed (step ?current) (pos-start ?rs ?cs) (pos-end ?rg ?cg) (result ok))
  ;?f2<-(strategy-service-table (table-id ?id) (fl ?fl) (dl ?dl) (phase 5) (action ?a))
  ?f2<-(exec-order (table-id ?id) (phase 5) (drink-order ?do) (food-order ?fo) (status ?a))
=>
  (modify ?f2 (phase 6) (fail 0))
  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"] Init Phase 6, table approached deliveryclean, order (food: "?fo", drink: "?do") action ("?a")" crlf)
  )
)

;Se il piano è fallito, il robot deve ripianificare per arrivare al tavolo. Cio significa rieseguire la fase 5.
;Devo modificare K-agent altrimenti la regola S0 di astar non parte perche attivata più volte dal medesimo fatto
(defrule strategy-re-execute-phase5
  (status (step ?current))
  (debug ?level)
  ?f1<- (plan-executed (step ?current) (pos-start ?rs ?cs) (pos-end ?rg ?cg) (result fail))
  ;?f2<-(strategy-service-table (table-id ?id) (fl ?fl) (dl ?dl) (phase 5) (action ?a) (fail ?f))
  ?f2<-(exec-order (table-id ?id) (phase 5)  (fail ?f))
  ?f3<-(K-agent)
=>
  (retract ?f1)
  (modify ?f2 (phase 5) (fail (+ ?f 1)))
  (modify ?f3)
  
  (assert (exec (step ?current) (action Wait)))
  
  ;debug
  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F3:s"?current":"?id"] Init Phase 5: Plane Failed. Wait and try again." crlf)
  )
)


;Se non esiste un percorso per arrivare alla destinazione, vado in wait e riprovo.
;Devo modificare K-agent altrimenti la regola S0 di astar non parte perche attivata più volte dal medesimo fatto
(defrule strategy-change-order-in-phase5
  (declare(salience 10))
  (debug ?level)
  (status (step ?current))
  ?f1<-(exec-order (step ?s2) (table-id ?id) (phase 5) (fail ?f))
  ;?f2<-(strategy-service-table (step ?s2) (table-id ?id) (phase 5) (fail ?f))
  ?f2<-(astar-solution (value no))
  ?f3<-(K-agent)
  ?f4<-(start-astar)
=>
  (modify ?f1 (phase 5) (fail (+ ?f 1)))
  (retract ?f2 ?f4)
  (modify ?f3)

  (assert (exec (step ?current) (action Wait)))

  (if (> ?level 0)
    then
    (printout t " [DEBUG] [F5:s"?current":"?id"] A-Star not found solution to the table: "?id crlf)
    (printout t " [DEBUG] [F5:s"?current":"?id"] Init Phase 5: Plane Failed. Wait and try again." crlf)
  )
)
;
; FASE 6 della Strategia: il robot è arrivato al tavolo e deve scaricare.
;

;Regola per scaricare il food al tavolo
(defrule strategy-do-DeliveryFood
  (declare(salience 10))
  (status (step ?current))
  (debug ?level)

  ;(strategy-service-table (table-id ?id) (phase 6) (action accepted))
  (exec-order (step ?s2) (table-id ?id) (phase 6) (status accepted) (food-order ?fo))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-food ?lf))
  (Table (table-id ?id) (pos-r ?rfo) (pos-c ?cfo))
  (and (test(> ?fo 0)) (test(> ?lf 0)))
=>
  (assert (exec (step ?ks) (action DeliveryFood) (param1 ?rfo) (param2 ?cfo)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-SERVE] Delivery Food" crlf)
  )
)

;Regola per scaricare i drink al tavolo
(defrule strategy-do-DeliveryDrink
  (declare(salience 10))
  (status (step ?current))
  (debug ?level)

  ;(strategy-service-table (table-id ?id) (phase 6) (action accepted))
  (exec-order (step ?s2) (table-id ?id) (phase 6) (status accepted) (drink-order ?do))
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-drink ?ld))
  (Table (table-id ?id) (pos-r ?rfo) (pos-c ?cfo))
  (and (test(> ?do 0)) (test(> ?ld 0)))
=>
  (assert (exec (step ?ks) (action DeliveryDrink) (param1 ?rfo) (param2 ?cfo)))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"-SERVE] Delivery Drink" crlf)
  )
)

;regola per pulire il tavolo se l'ordine era delayed o finish.
(defrule strategy-do-CleanTable
  (declare(salience 10))
  (status (step ?current))
  (debug ?level)
  (K-agent (step ?ks) (pos-r ?ra) (pos-c ?ca) (l-drink ?ld) (l-food ?lf))
  (K-table (table-id ?id) (pos-r ?rt) (pos-c ?ct) (clean no))
  ;?f3 <- (strategy-service-table (table-id ?id) (phase 6) (action delayed|finish))
  (exec-order (table-id ?id) (phase 6) (status  delayed|finish))
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

;Se non ho ne da scaricare cibo, ne da scaricare drink ne da pulire il tavolo vado alla fase 7.
(defrule go-phase7
  (declare(salience 5))
  (debug ?level)
  (status (step ?current))
  ;?f3 <- (strategy-service-table (table-id ?id) (phase 6))
  ?f3<-(exec-order (table-id ?id) (phase 6))
  =>
  (modify ?f3 (phase 7))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F7:s"?current":"?id"] Init Phase 7" crlf)
  )
)
;
; FASE 7 della Strategia: Controllo se l'ordine è stato evaso.
;

;Devo ancora consegnare della roba al tavolo. Devo ricercare il best-dispenser (FASE 2)
(defrule strategy-return-phase7-to-2_accepted
  (status (step ?current))
  (debug ?level)
  ;?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 7) (dl ?dl) (fl ?fl) (action accepted))
  ?f1<-(exec-order (table-id ?id) (phase 7) (status accepted) (food-order ?fo) (drink-order ?do))
  ; ho scaricato tutta la roba
  (test (> (+ ?fo ?do) 0))
=>
  (modify ?f1 (phase 2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F7:s"?current":"?id"-SERVE] Order not completed, return to phase 2, order (food: "?fo", drink: "?do")" crlf)
  )
)

;Devo ancora buttare lo sporco. Devo ricercare il cestino più vicino (FASE 2)
(defrule strategy-return-phase7-to-2_delayed
  (status (step ?current))
  (debug ?level)
  ;?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 7) (action delayed|finish))
  ?f1<-(exec-order (table-id ?id) (phase 7) (status delayed|finish))
  (K-agent (l_d_waste ?ldw) (l_f_waste ?lfw))
  (test (or (= (str-compare ?ldw "yes") 0) (= (str-compare ?lfw "yes") 0))) 
=>
  (modify ?f1 (phase 2))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F7:s"?current":"?id"-CLEAN] CleanTable, sono pieno di trash, return to phase 2" crlf)
  )
)

;Ordine completato. Devo trovare il nuovo ordine da evadare.
;Ordine completato se ho scaricato tutta la roba e  l'agente non ha niente (attenzione giusto nella logica di servire un tavolo alla volta)
(defrule strategy-order-completed
  (status (step ?current))
  (last-intention (step ?step))
  (debug ?level)
  ;?f1 <- (strategy-service-table (step ?step) (table-id ?id) (phase 7))
  ?f1<-(exec-order (table-id ?id) (step ?step) (phase 7) (food-order 0) (drink-order 0))

  ;(K-agent (l-drink 0) (l-food 0))
=> 
  (modify ?f1 (phase FINISH))

  ;debug
  (if (> ?level 0)
  then
  (printout t " [DEBUG] [F6:s"?current":"?id"] Phase 7: Order at step:" ?step " of table:" ?id " is completed" crlf)
  )
)