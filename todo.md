# Todo NG_Cafè

1.  Ottimizzazioni

# Strategie

Serviamo le richieste in ordine di arrivo. (Strategy1)


# Domande da fare a Torasso

* Può capitare che il tavolo mandi una ordinazione se il tavolo è sporco?
* Come funzion la checkFinish, se un tavolo viene marcato sporco non appena consegno il cibo? Se deve intercorrere un tempo constante dal momento in cui avviene la consegna per terminare la consumazione non posso calcolarmelo a priori senza fare la checkFinish?
* Aggionrnamento in caso di incertezza (Assunzioni di che?) sia per astar che per percezioni.	

# Regole di costruzione della mappa

* nessun tavolo adiacente al muro	


#Ottimizzazioni
* Caricare cibo di prenotazioni diverse
* Controllare se la consumazione a un tavolo è stata terminata (CheckFinish)
* Euristiche su chi servire prima o dopo

#Problemi Strategy1
* Esecuzione di un piano a costo 0 già calcolato, quindi senza rifare astar. (fa le turnleft inutilmente)
* Ottimizzare la regola 'run-plane-turn' nel file exec-plane
* Problema tavolo non accessibile a causa di una persona (domanda torasso)
* Caso in cui il tavolo o il dispenser non sia accessibile da nessun percorso. Cosa succede?