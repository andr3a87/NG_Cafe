Progetto di Intelligenza Artificiale
---
NG_Cafe
=======

La struttura del progetto comprende 3 moduli: 


1. **main**:usato esclusivamente per la comunicazione tra gli altri due moduli. Nel  modulo MAIN  sono definite le strutture che sono condivise tra il modulo AGENT ed il modulo ENV. 
2. **env**: che modella l’ambiente in cui opera il robot (compresi i movimenti dei clienti umani). Il modulo ENV è molto complesso perché deve modellare l’evoluzione dell’ambiente che non è solo dovuta alle azioni decise da AGENT, ma anche dagli altri agenti (clienti e tavoli che operano come fossero agenti). 
3. **agent**: sono presenti tre regole (`beginagent1`, `beginagent2`, `beginagent3`) che hanno il compito di “copiare” in strutture interne di AGENT le informazioni relative alla mappa, alla stato inziale dell’agente e ai tavoli. Vi sono altre regole in grado di aggiornare lo stato del mondo che l'agente conosce grazie alle percezioni.

Il progetto contiene tre file:

1. **InitMap**: la descrizione CLIPS dell’ambiente 
2. **histoty**: contiene sia  info relative  agli spostamenti dei clienti sia alle loro richieste (ordinazioni). 
3. **batch**: che serve per caricare i vari moduli in clips.

 