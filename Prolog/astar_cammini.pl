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

:-dynamic(f_val/1). f_val(0).
:-dynamic(h_val/1). h_val(0).



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

calcolo_euristica(pos(R,C),pos(R1,C1), G) :-
        X is R - R1,
        Y is C - C1,
        abs(X, Xabs),
        abs(Y, Yabs),
        H is Xabs + Yabs,
        F is G + H,
        retract(f_val(_)),
        assert(f_val(F)),
        retract(h_val(_)),
        assert(h_val(H)).

ric_astar([nodo(_,_, S, Lista_Az)|_],_, Lista_Az) :- finale(S), !.
ric_astar([nodo(Fcost, Gcost, S, Lista_Az)| R_lista_open], Closed, Lista_Ris) :-
        member(S, Closed) ->
                ric_astar(R_lista_open, Closed, Lista_Ris);
        open_node(nodo(Fcost, Gcost, S, Lista_Az), Lista_children),
        ord_union(Lista_children, R_lista_open, Nuova_open),
        /**([nodo(Fcost2, Gcost3, Nuova_S, Nuova_lista_Az)]),*/
        ric_astar(Nuova_open,[S|Closed], Lista_Ris).

        
open_node(nodo(Fcost, Gcost, S, Lista_Az), Lista_childern) :-
        findall(Az, applicabile(Az,S), Az_applicabili),
        best_node(nodo(Fcost, Gcost, S, Lista_Az), Az_applicabili, Lista_childern).

best_node(_,[],[]).
best_node(nodo(Fcost, Gcost, S, Lista_Az), [Az|R_az], Lista_children) :-
        finale(Goal),        
        trasforma(Az, S, Nuovo_S),
        append(Lista_Az, [Az], Nuova_lista_az),
        best_node(nodo(Fcost, Gcost, S, Lista_Az), R_az, Old_children),
        G1 is Gcost + 1,
        calcolo_euristica(Nuovo_S, Goal, G1),
        f_val(F),
        ord_add_element(Old_children, nodo(F, G1, Nuovo_S, Nuova_lista_az), Lista_children).

astar :-
        iniziale(S),
        finale(Goal),
        calcolo_euristica(S, Goal, 0),
        f_val(Fcost),
        time(ric_astar([nodo(Fcost, 0, S, [])], [], Ris)),
        write(Ris).