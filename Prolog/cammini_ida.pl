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
:-dynamic(soglia/1). soglia(99999).  /**Dato che soglia non poteva essere modificato tramite
                        retract/assert ho dovuto create questa regola dinamica*/



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



ric_prof_lim(S,Depth,_,_,[]) :-
        f_val(F),
        F =< Depth,
        finale(S),!. 
ric_prof_lim(S,Depth,G,Visitati,[Az|Resto]) :-
        f_val(F),
        F =< Depth,
                 finale(Goal),
                 applicabile(Az,S),
                 trasforma(Az,S,Nuovo_S),
                 \+ member(Nuovo_S,Visitati),
                 G1 is G + 1,
                 calcolo_euristica(Nuovo_S,Goal,G1),
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

ric_idastar(I,Ris,Depth,G) :- ric_prof_lim(I,Depth,G,[],Ris).

ric_idastar(I,Ris,_,G) :-
        soglia(Sog),
        retract(soglia(Sog)),
        assert(soglia(99999)),
        ric_idastar(I,Ris,Sog,G).

idastar :-
        iniziale(S),
        finale(Goal),
        calcolo_euristica(S,Goal,0),
        f_val(D),
        ric_idastar(S,Ris,D,0),
        write(Ris).
