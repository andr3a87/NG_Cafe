# Todo NG_Cafè

1.  creare le regole per eseguire il piano creato da astar (plane)
2.  creare le regole per gestire le ordinazioni. Le ordinazioni sono di due tipi: *order* e *finish*. La prima indica una ordinazione mentre la seconda è la richiesta di puliza del tavolo.In particolare l’agente robotico può:
	* mandare un inform di *accepted* . Questo messaggio è adeguato se l’agente stesso sa che il tavolo è già stato pulito (od era inizialmente pulito)  ed la richiesta di una ordinazione arriva dopo che il tavolo è pulito.
	* mandare un inform di *delayed*. Questo messaggio è adeguato se l’agente stesso sa che dal tavolo stesso è pervenuta prima una richiesta di pulire in tavolo  e poi una richiesta di nuova ordinazione.
	* mandare un inform di *rejected* (nella versione attuale questa riposta non è mai adeguata).

# Strategie

Serviamo le richieste in ordine di arrivo.
 

# Domande da fare a Torasso

* inserire una regola nella generazione della mappa in modo da evitare la creazione di un tavolo con 4 sedie
* Per servire un tavolo o scaricare/cariare il cibo il robot deve essere orientato verso il tavolo?
* Può capitare che il tavolo mandi una ordinazione se il tavolo è sporco?
* Appena vengono consegnati cibi e/o bevande il tavolo diventa sporco?

# Regole di costruzione della mappa

* nessun tavolo adiacente al muro	
* nessun tavolo con 4 sedie
