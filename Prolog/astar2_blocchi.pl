
% Mondo dei blocchi
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

:- use_module(library(statistics)).
:-dynamic(f_val/1). f_val(0).
:-dynamic(h_val/1). h_val(0).


block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).


iniziale(S):-
        list_to_ord_set([clear(a), on(c,b), on(d,c), on(a,d), ontable(b), handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),on(d,e),
        ontable(e)],G).

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




calcola_pile(S,PRis) :- 
        block(X),
        ord_memberchk(ontable(X),S),
        block(Y),
        ord_memberchk(on(Y,X),S),
        create_pila(Y,X,S,[]),
        ord_union(PRis,Pila,Pila).

create_pila(Y,X,S,Pila) :-
        append(Pila,Y,Pila),
        block(Y1),
        ord_memberchk(on(Y1,Y),S), 
        create_pila(Y1,Y,S,Pila).

astar :-
        iniziale(S),
        nb_setval(counter , 0),
        calcola_pile(S,PRis),
        write('\n').