
% Mondo dei blocchi
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

:- use_module(library(statistics)).

block(a).
block(b).
block(c).
block(d).
block(e).
:-dynamic(f_val/1). f_val(0).
:-dynamic(h_val/1). h_val(0).
:-dynamic(soglia/1). soglia(99999). 

iniziale(S):-
        list_to_ord_set([on(a,b),on(b,c),ontable(c),clear(a),on(d,e),
                                                  ontable(e),clear(d),handempty],S).

goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),ontable(d),
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

calcolo_euristica(S, G) :-
        goal(Res),
        ord_subtract(S, Res, Diff),
        calcola_h(Diff, Ndiff),
        h_val(Ndiff),
        F is G + Ndiff,
        retract(f_val(_)),
        assert(f_val(F)).

calcola_h([],0).
calcola_h([_|Resto_Ok],H) :-
        calcola_h(Resto_Ok, H1),
        H is H1 + 1,
        retract(h_val(_)),
        assert(h_val(H)).
        
        
ric_prof_lim(S,Depth,_,_,[]) :-
        f_val(F),
        F =< Depth,
        finale(S),!. 
ric_prof_lim(S,Depth,G,Visitati,[Az|Resto]) :-
        f_val(F),
        F =< Depth,
                 applicabile(Az,S),
                 trasforma(Az,S,Nuovo_S),
                 \+ member(Nuovo_S,Visitati),
                 num_nodi_open,
                 G1 is G + 1,
                 calcolo_euristica(Nuovo_S,G1),
                 ric_prof_lim(Nuovo_S,Depth,G1,[S|Visitati],Resto).
ric_prof_lim(_,Depth,_,_,_) :-
        f_val(F),
        F > Depth,
        try_prof(F),
        fail.

try_prof(F) :-
        soglia(X),
        X =< F, !
        ;
        retract(soglia(X)), !,
        assert(soglia(F)).
        
num_nodi_open:-
        nb_getval(counter, N1),
        New1 is N1 + 1,
        nb_setval(counter, New1).

ric_idastar(I,Ris,Depth,G) :- ric_prof_lim(I,Depth,G,[],Ris).

ric_idastar(I,Ris,_,G) :-
        soglia(Sog),
        retract(soglia(Sog)),
        assert(soglia(99999)),
        ric_idastar(I,Ris,Sog,G).

idastar :-
        iniziale(S),
        nb_setval(counter , 0),
        calcolo_euristica(S,0),
        f_val(D),
        time(ric_idastar(S,Ris,D,0)),
        nb_getval(counter, N_res),
        writeln(Ris),
        write(N_res),
        write('\n').
