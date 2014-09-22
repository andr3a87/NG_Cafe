# Todo NG_Cafè


### Strategie

* Strategy-FIFO
* Strategy-FIFO-WAIT
* Strategy-LOW-PENALITY


### Domande da fare a Torasso


### Ottimizzazioni
* Caricare cibo di prenotazioni diverse
* Controllare se la consumazione a un tavolo è stata terminata (CheckFinish)
* Euristiche su chi servire prima o dopo

### Problemi Strategie
* Ottimizzare la regola 'run-plane-turn' nel file exec-plane
* Rimette a 'ok' un piano che era stato messo in precedenza a failure. Quando? (Strategy_FIFO)
* Ottimizzare regole search-best-dispenser e found-best-dispenser in una sola.
* LOW_PENALITY, gli ordini finish e Inform su uno stesso tavolo vanno serviti in ordine (o non servo la finish).