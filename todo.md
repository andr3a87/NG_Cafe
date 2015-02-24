# Todo NG_Cafè

## Dimensioni su cui effettuare i test
* w: strategia, [FIFO, FIFO-PRO, LOW-PENALITY, HARD]
* x: id mappa
* y: id history
* z: penalità

* MAPPA: m mappe, di dimensione differente, con un diverso numero di tavoli
  * dimensione della mappa [10,20,30]
  * numero di tavoli
  * posizione dei tavoli

* HISTORY: facciamo variare ordini e persone ad hoc (ossia creiamo n history per ogni mappa specifica)
  * varianti della history: frequenza di movimento e quantità di persone
  * numero di ordini, contemporaneità di ordini aperti e distanza dai dispenser

### Dettagli History
creiamo due history estreme per ogni mappa, dove ogni ordine è composto in un caso di (0,1/1,0) e nell'altro di (>=2,>=2); gli ordini devono essere gli stessi, dagli stessi tavoli allo stesso tempo.
Altre due history dove in una le persone si muovono sempre e nell'altra a step.
Strategia per attivare le checkfinish

Dominio
[MAPID-HISTORYID]

m10a,m20a,m30a [10x10,20x20,30x30]
hdefault, hsimple, hhard, hperson1, hperson2, hcheckf


#COSA MANCA?
	* Mappe 10x10
	* Grafici Relazione CLIPS