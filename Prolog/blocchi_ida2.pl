
% Mondo dei blocchi
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

:- use_module(library(statistics)).
:-dynamic(f_val/1). f_val(0).
:-dynamic(h_val/1). h_val(0).
:-dynamic(soglia/1). soglia(99999).
:-dynamic(cost/1). cost(0).

% esempio Prof. Martelli
% list_block(B):-list_to_ord_set([a,b,c,d,e],B).
% 
% block(a).
% block(b).
% block(c).
% block(d).
% block(e).
% 
% iniziale(S):- list_to_ord_set([on(a,b),on(b,c),ontable(c),clear(a),on(d,e),ontable(e),clear(d),handempty],S).
% 
% goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),ontable(d),ontable(e)],G).
% 
% finale(S):- goal(G), ord_subset(G,S).

% esempio Prof. Torasso

 block(a).
 block(b).
 block(c).
 block(d).
 block(e).
 block(f).
 block(g).
 block(h).
 
 list_block(B):-list_to_ord_set([a,b,c,d,e,f,g,h],B).
 
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

calcolo_euristica(S, G) :-
        goal(Goal),
        list_block(B),
        retract(cost(_)),
        assert(cost(0)),
        cost_of_state(S,Goal,B),
        cost(Ris),
        F is G - Ris,
        retract(f_val(_)),
        assert(f_val(F)).

cost_of_state(S,Goal,[]).

cost_of_state(S,Goal,[H|T]) :-          block(H),
                                        \+ ord_memberchk(ontable(H),S),
                                        check_pila(S,Goal,H,0,0),
                                        cost_of_state(S,Goal,T).

% Caso in cui il blocco è sul tavolo.
cost_of_state(S,Goal,[H|T]) :-          block(H),
                                        ord_memberchk(ontable(H),S),
                                        cost_of_state(S,Goal,T).

% Caso in cui il blocco è holding.
cost_of_state(S,Goal,[H|T]) :-          block(H),
                                        ord_memberchk(holding(H),S),
                                        cost_of_state(S,Goal,T).

% Caso in cui ci sia un blocco sul tavolo senza niente sopra. Assegno un +0.
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         ord_memberchk(ontable(Blocco),S), 
                                                ord_memberchk(ontable(Blocco),Goal), 
                                                ord_memberchk(clear(Blocco),S), 
                                                ord_memberchk(clear(Blocco),Goal).

% Simoa arrivat al ceh sta sul tavolo nello stato S, ma nello stato Goal no. na penalità pari alla lunghezza della pila.                                
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         ord_memberchk(ontable(Blocco),S), 
                                                \+ ord_memberchk(ontable(Blocco),Goal), 
                                                cost(R),
                                                retract(cost(_)),
                                                R1 is R - (N_ok + N_nok),
                                                assert(cost(R1)).

% Siamo arrivati al blocco che sta sul tavolo. Se ho trovato dei blocchi non a posto allora avrò una penalità pari alla lunghezza della pila.                               
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         ord_memberchk(ontable(Blocco),S), 
                                                ord_memberchk(ontable(Blocco),Goal),
                                                block(X),
                                                ord_memberchk(on(X,Blocco),S), 
                                                ord_memberchk(on(X,Blocco),Goal),
                                                N_nok > 0,
                                                cost(R),
                                                retract(cost(_)),
                                                R1 is R - (N_ok + N_nok),
                                                assert(cost(R1)).

% Siamo arrivati al blocco che sta sul tavolo. Ma il blocco sopra a questo è diverso nello stato S rispetto allo stato Goal. 
% Assegno una penalità pari alla lunghezza della pila.                                
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         ord_memberchk(ontable(Blocco),S), 
                                                ord_memberchk(ontable(Blocco),Goal),
                                                block(X),
                                                ord_memberchk(on(X,Blocco),S), 
                                                \+ ord_memberchk(on(X,Blocco),Goal),
                                                cost(R),
                                                retract(cost(_)),
                                                R1 is R - (N_ok + N_nok),
                                                assert(cost(R1)).

% Caso in cui il supporto di un blocco sia uguale sia nello stato S sia nello stato Goal. Assegno un +(N_ok + N_nok).                                
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         ord_memberchk(ontable(Blocco),S), 
                                                ord_memberchk(ontable(Blocco),Goal),
                                                block(X),
                                                ord_memberchk(on(X,Blocco),S), 
                                                ord_memberchk(on(X,Blocco),Goal),
                                                N_nok =:= 0,
                                                cost(R),
                                                retract(cost(_)),
                                                R1 is R + (N_ok + N_nok),
                                                assert(cost(R1)).


% Caso in cui il supporto fino adesso controllato non è uguale nello stato S e nello Stato Goal. Itero aggiornando N_nok.
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         block(X),
                                                ord_memberchk(on(Blocco,X),S),
                                                \+ ord_memberchk(on(Blocco,X),Goal),
                                                N is N_nok + 1,
                                                check_pila(S,Goal,X,N_ok,N).

% Caso in cui il supporto fino adesso controllato è uguale sia nello stato S sia nello Stato Goal. Itero. Itero aggiornando N_ok.
check_pila(S,Goal,Blocco,N_ok,N_nok) :-         block(X),
                                                ord_memberchk(on(Blocco,X),S),
                                                ord_memberchk(on(Blocco,X),Goal),
                                                N is N_ok + 1,
                                                check_pila(S,Goal,X,N,N_nok).
        
        
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
