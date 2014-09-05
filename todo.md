# Todo NG_Cafè

1.  Creare le regole per eseguire il piano creato da astar (plane) /FATTO!!
2.  Gestire Ordine di un tavolo
3.  Gestire Pulizia di un tavolo
4.  Ottimizzazioni

# Strategie

Serviamo le richieste in ordine di arrivo.

La regola exec_act per l'esecuzione di un azione ha priorita 100.
Le regole per gestire le percezioni hanno priorira 90.
Le regole per eseguire un piano generato da astar hanno priorita 80.
Le regole per ripondere a un messaggio di ordinazione o rimozione cibo hanno priorita 70.
 


# Domande da fare a Torasso

* inserire una regola nella generazione della mappa in modo da evitare la creazione di un tavolo con 4 sedie
* Per servire un tavolo o scaricare/cariare il cibo il robot deve essere orientato verso il tavolo?
* Può capitare che il tavolo mandi una ordinazione se il tavolo è sporco?
* Appena vengono consegnati cibi e/o bevande il tavolo diventa sporco?
* Come funzion la checkFinish, se un tavolo viene marcato sporco non appena consegno il cibo? Se deve intercorrere un tempo constante dal momento in cui avviene la consegna per terminare la consumazione non posso calcolarmelo a priori senza fare la checkFinish?
* Devo rispondere a delle richieste di tipo Finish?
* Ci sono più dispenser e/o cestini? **Si ci sono!**
* Cosa serve result nella struttura status
* Quando rispondo a un tavolo delayed?	

# Regole di costruzione della mappa

* nessun tavolo adiacente al muro	
* nessun tavolo con 4 sedie


#Cosa significa completare un ordine di prenotazione 
* Calcolo distanza di manhattan per capire in quale dispenser andare.
* Calcolo Astar
* Eseguo Astar
* Se ho ancora spazio e ordini sull'altro dispenser calcolo Astar sull'altro dispenser.
* Eseguo Astar
* Calcolo Astar per raggiungere il tavolo
* Eseguo Astar
* Loop se ordina ha ancora richieste pendenti


#Come gestire la pulizia del tavolo quando arriva un ordine di finish
* Calcolo Astar verso il tavolo
* Carico dello sporco
* Calcolo distanza di manhattan per il cestino più vicino.
* Calcolo di Astar per ragg. il cestino.
* Eseguo Astar
* Potenzialmente calcolo astar per andare all'altro cestino
* Eseguo Astar
* Loop se il tavolo è ancora sporco.

#Ottimizzazioni
* Caricare cibo di prenotazioni diverse
* Controllare se la consumazione a un tavolo è stata terminata (CheckFinish)
* Euristiche su chi servire prima o dopo