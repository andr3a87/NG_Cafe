
% Mondo dei blocchi
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

:- use_module(library(statistics)).

block(a).
block(b).
block(c).
block(d).
block(e).
block(f).
block(g).
block(h).


iniziale(S):-
        list_to_ord_set([clear(a), clear(c), clear(d), clear(e), clear(f), clear(g), clear(h), on(a,b), ontable(b), ontable(c), ontable(d), ontable(e), ontable(f), ontable(g), ontable(h), handempty],S).

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

ric_prof_cc_lim(S,_,_,[]) :- finale(S),!.
ric_prof_cc_lim(S,D,Visitati,[Az|Resto]) :-
    D>0,
    applicabile(Az,S),
    trasforma(Az,S,Nuovo_S),
    \+ member(Nuovo_S,Visitati),
    num_nodi_open,
    D1 is D-1,
    ric_prof_cc_lim(Nuovo_S,D1,[S|Visitati],Resto).

ric_prof_cc_id(I,D,Ris) :- ric_prof_cc_lim(I,D,[],Ris).
ric_prof_cc_id(I,D,Ris) :-
    D1 is D+1,
    ric_prof_cc_id(I,D1,Ris).
    
num_nodi_open:-
        nb_getval(counter, N1),
        New1 is N1 + 1,
        nb_setval(counter, New1).

prof_lim(D) :- iniziale(I),ric_prof_cc_lim(I,D,[],Ris),write(Ris).
prof_id :-
        iniziale(I),
        nb_setval(counter , 0),
        time(ric_prof_cc_id(I,1,Ris)),
        nb_getval(counter, N_res),
        writeln(Ris),
        write(N_res),
        write('\n').