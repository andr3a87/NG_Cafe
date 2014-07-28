##cammini_ida.pl
**TEORIA:** Le strategie di ricerca informate utilizzano una funzione euristica h(n) che nel nostro caso è la distanza di manhattan. Inoltre la g(n) è il costo del cammino trovato dal nodo iniziale al nodo n.

**SVOLGIMENTO**: La soglia all'inizio è uguale alla f(n) calcolata sul nodo 
*INIZIALE*. Si procede in profondità fin quando non si effettua un backtracking (analizzo tutti i nodi entro quella soglia. Se non sono arrivato al goal effettuo backtracking aggiornando la soglia.) La nuova soglia al giro successivo sarà data dall'f(n) minore dei **soli** nodi n che avevano superato la soglia al passo precedente.