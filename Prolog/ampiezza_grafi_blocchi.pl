
% Mondo dei blocchi
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

block(a).
block(b).
block(c).

iniziale(S):-
        list_to_ord_set([clear(a), clear(c), clear(d), clear(e), clear(f), clear(g), clear(h), on(a,b), ontable(b), ontable(c), ontable(d), ontable(e), ontable(f), ontable(g), ontable(h), handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),clear(a),ontable(c),handempty],G).

finale(S):- goal(G), ord_subset(G,S).

applicabile(pickup(X),S):-
        block(X),
        ord_memberchk(ontable(X),S),
        ord_memberchk(clear(X),S),
        ord_memberchk(handempty,S).
        
applicabile(putdown(X),S):-
        block(X),
        ord_memberchk(holding(X),S).
        
applicabile(stack(X,Y),S):-
        block(X), block(Y), X\=Y,
        ord_memberchk(holding(X),S),
        ord_memberchk(clear(Y),S).

applicabile(unstack(X,Y),S):-
        block(X), block(Y), X\=Y,
        ord_memberchk(on(X,Y),S),
        ord_memberchk(clear(X),S),
        ord_memberchk(handempty,S).
        
trasforma(pickup(X),S1,S2):-
        block(X),
        list_to_ord_set([ontable(X),clear(X),handempty],DLS),
        ord_subtract(S1,DLS,S),
        list_to_ord_set([holding(X)],ALS),
        ord_union(S,ALS,S2).
        
trasforma(putdown(X),S1,S2):-
        block(X),
        list_to_ord_set([holding(X)],DLS),
        ord_subtract(S1,DLS,S),
        list_to_ord_set([ontable(X),clear(X),handempty],ALS),
        ord_union(S,ALS,S2).

trasforma(stack(X,Y),S1,S2):-
        block(X), block(Y), X\=Y,
        list_to_ord_set([holding(X),clear(Y)],DLS),
        ord_subtract(S1,DLS,S),
        list_to_ord_set([on(X,Y),clear(X),handempty],ALS),
        ord_union(S,ALS,S2).

trasforma(unstack(X,Y),S1,S2):-
        block(X), block(Y), X\=Y,
        list_to_ord_set([on(X,Y),clear(X),handempty],DLS),
        ord_subtract(S1,DLS,S),
        list_to_ord_set([holding(X),clear(Y)],ALS),
        ord_union(S,ALS,S2).

ampiezza :-
    iniziale(S),
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
        trasforma(Az, S, Nuovo_S),
        append(Lista_Az, [Az], Nuova_lista_az),
        node(nodo(S, Lista_Az), R_az, Old_children),
        ord_add_element(Old_children, nodo(Nuovo_S, Nuova_lista_az), Lista_children).