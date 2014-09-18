# Todo NG_Cafè


### Strategie

Serviamo le richieste in ordine di arrivo. (Strategy1)


### Domande da fare a Torasso

### Regole di costruzione della mappa

* nessun tavolo adiacente al muro	


### Ottimizzazioni
* Caricare cibo di prenotazioni diverse
* Controllare se la consumazione a un tavolo è stata terminata (CheckFinish)
* Euristiche su chi servire prima o dopo

### Problemi Strategy1
*Controllare status fail di exec-order (inizializzarlo a 0)
* Esecuzione di un piano a costo 0 già calcolato, quindi senza rifare astar. (fa le turnleft inutilmente).
* Ottimizzare la regola 'run-plane-turn' nel file exec-plane
* Se ho più piani creati da astar per arrivare a una determinata posizione, quale eseguo? (Caso in cui un piano è appena fallito non devo rieseguirlo).

