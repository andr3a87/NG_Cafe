# Todo NG_Cafè

1.  Ottimizzazioni

# Strategie

Serviamo le richieste in ordine di arrivo. (Strategy1)


# Domande da fare a Torasso

* Può capitare che il tavolo mandi una ordinazione se il tavolo è sporco?
* Come funzion la checkFinish, se un tavolo viene marcato sporco non appena consegno il cibo? Se deve intercorrere un tempo constante dal momento in cui avviene la consegna per terminare la consumazione non posso calcolarmelo a priori senza fare la checkFinish?
* Cosa succede se una persona si trova davanti a un tavolo? la servicetable per quella posizion è false. Se la persona si sposta continua a rimanere false.

# Regole di costruzione della mappa

* nessun tavolo adiacente al muro	


#Ottimizzazioni
* Caricare cibo di prenotazioni diverse
* Controllare se la consumazione a un tavolo è stata terminata (CheckFinish)
* Euristiche su chi servire prima o dopo