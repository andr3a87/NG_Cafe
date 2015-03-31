
% Mondo dei blocchi
% Specifica delle azioni mediante precondizioni ed effetti alla STRIPS
% Gli stati sono rappresentati con insiemi ordinati

:- use_module(library(statistics)).
:-dynamic(f_val/1). f_val(0).
:-dynamic(h_val/1). h_val(0).
?- set_prolog_stack(global, limit(2*10**9)).

% esempio Prof. Martelli
 list_block(B):-list_to_ord_set([a,b,c,d,e],B).
 
 block(a).
 block(b).
 block(c).
 block(d).
 block(e).
 
 iniziale(S):- list_to_ord_set([on(a,b),on(b,c),ontable(c),clear(a),on(d,e),ontable(e),clear(d),handempty],S).
 
 goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),ontable(d),ontable(e)],G).
 
 finale(S):- goal(G), ord_subset(G,S).
 
% esempio Prof. Torasso

% block(a).
% block(b).
% block(c).
% block(d).
% block(e).
% block(f).
% block(g).
% block(h).
% 
% list_block(B):-list_to_ord_set([a,b,c,d,e,f,g,h],B).
% 
% iniziale(S):-
%         list_to_ord_set([clear(a), clear(c), clear(d), clear(e), clear(f), clear(g), clear(h), on(a,b), ontable(b), ontable(c), ontable(d), ontable(e), ontable(f), ontable(g), ontable(h), handempty],S).
% 
% goal(G):- list_to_ord_set([on(a,b),on(b,c),on(c,d),on(d,e),
%         ontable(e)],G).
% 
% finale(S):- goal(G), ord_subset(G,S).

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

ric_astar([nodo(_,_, S, Lista_Az)|_],_, Lista_Az) :- finale(S), !.
ric_astar([nodo(Fcost, Gcost, S, Lista_Az)| R_lista_open], Closed, Lista_Ris) :-
        member(S, Closed) ->
                ric_astar(R_lista_open, Closed, Lista_Ris);
        num_nodi_open,
        open_node(nodo(Fcost, Gcost, S, Lista_Az), Lista_children),
        ord_union(Lista_children, R_lista_open, Nuova_open),
        ric_astar(Nuova_open,[S|Closed],Lista_Ris).

open_node(nodo(Fcost, Gcost, S, Lista_Az), Lista_childern) :-
        findall(Az, applicabile(Az,S), Az_applicabili),
        best_node(nodo(Fcost, Gcost, S, Lista_Az), Az_applicabili, Lista_childern).

best_node(_,[],[]).
best_node(nodo(Fcost, Gcost, S, Lista_Az), [Az|R_az], Lista_children) :-       
        trasforma(Az, S, Nuovo_S),
        append(Lista_Az, [Az], Nuova_lista_az),
        % num_nodi_open,
        best_node(nodo(Fcost, Gcost, S, Lista_Az), R_az, Old_children),
        G1 is Gcost + 1,
        calcolo_euristica(Nuovo_S, G1),
        f_val(F),
        ord_add_element(Old_children, nodo(F, G1, Nuovo_S, Nuova_lista_az), Lista_children).
        
num_nodi_open:-
        nb_getval(counter, N1),
        New1 is N1 + 1,
        nb_setval(counter, New1).

astar :-
        iniziale(S),
        nb_setval(counter , 0),
        calcolo_euristica(S, 0),
        f_val(Fcost),
        time(ric_astar([nodo(Fcost, 0, S, [])], [], Ris)),
        nb_getval(counter, N_res),
        writeln(Ris),
        write(N_res),
        write('\n').