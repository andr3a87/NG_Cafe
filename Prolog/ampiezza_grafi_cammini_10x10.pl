% Mondo dei cammini mappa 10x10

num_col(10).
num_righe(10).

occupata(pos(2,5)).
occupata(pos(3,5)).
occupata(pos(4,5)).
occupata(pos(5,5)).
occupata(pos(6,5)).
occupata(pos(7,5)).
occupata(pos(7,1)).
occupata(pos(7,2)).
occupata(pos(7,3)).
occupata(pos(7,4)).
occupata(pos(5,7)).
occupata(pos(6,7)).
occupata(pos(7,7)).
occupata(pos(8,7)).
occupata(pos(4,7)).
occupata(pos(4,8)).
occupata(pos(4,9)).
occupata(pos(4,10)).

iniziale(pos(4,2)).
finale(pos(7,9)).

applicabile(est,pos(R,C)) :-
        num_col(NC), C<NC,
        C1 is C+1,
        \+ occupata(pos(R,C1)).

applicabile(sud,pos(R,C)) :-
        num_righe(NR), R<NR,
        R1 is R+1,
        \+ occupata(pos(R1,C)).

applicabile(ovest,pos(R,C)) :-
        C>1,
        C1 is C-1,
        \+ occupata(pos(R,C1)).


applicabile(nord,pos(R,C)) :-
        R>1,
        R1 is R-1,
        \+ occupata(pos(R1,C)).

trasforma(est,pos(R,C),pos(R,C1)) :- C1 is C+1.
trasforma(ovest,pos(R,C),pos(R,C1)) :- C1 is C-1.
trasforma(sud,pos(R,C),pos(R1,C)) :- R1 is R+1.
trasforma(nord,pos(R,C),pos(R1,C)) :- R1 is R-1.


ampiezza :-
    iniziale(S),
    finale(Goal),
    nb_setval(counter , 0),
    time(ric_ampiezza([nodo(S, [])], [], Ris)),
    writeln(Ris),
    nb_getval(counter, N_res),
    write(N_res).


ric_ampiezza([nodo(S, Lista_Az)|_], _, Lista_Az) :- finale(S), !.
ric_ampiezza([nodo(S, Lista_Az) | R_lista_open], Closed, Lista_Ris) :-
        member(S, Closed) ->
        	ric_ampiezza(R_lista_open, Closed, Lista_Ris);
        num_nodi_open,
        open_node(nodo(S, Lista_Az), Lista_children),
        ord_union(Lista_children, R_lista_open, Nuova_open),
        ric_ampiezza(Nuova_open,[S|Closed], Lista_Ris).

open_node(nodo(S, Lista_Az), Lista_childern) :-
        findall(Az, applicabile(Az,S), Az_applicabili),
        node(nodo(S, Lista_Az), Az_applicabili, Lista_childern).

num_nodi_open:-
        nb_getval(counter, N1),
        New1 is N1 + 1,
        nb_setval(counter, New1).

node(_,[],[]).
node(nodo(S, Lista_Az), [Az|R_az], Lista_children) :-
        finale(Goal),
        trasforma(Az, S, Nuovo_S),
        append(Lista_Az, [Az], Nuova_lista_az),
        node(nodo(S, Lista_Az), R_az, Old_children),
        ord_add_element(Old_children, nodo(Nuovo_S, Nuova_lista_az), Lista_children).