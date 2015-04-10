#const lastlev=1.

level(0..lastlev).
state(0..lastlev+1).

% AZIONI

1 {
    load(C,P,A,S) : cargo(C), plane(P), airport(A), state(S),
    unload(C,P,A,S) : cargo(C), plane(P), airport(A), state(S),
    fly(P,A1,A2,S) : plane(P), airport(A1), airport(A2), state(S)
} :- level(S).

% EFFETTI

% afferma la -posizione di un cargo in un areoporto quando viene caricato su un aereo
-at(C,A,S+1) :- load(C,P,A,S),state(S).

% afferma che un cargo è su un aereo, quando viene caricato
in(C,P,S+1) :- load(C,P,A,S),state(S).

% rimette i cargo in un areoporto quando vengono scaricati
at(C,A,S+1) :- unload(C,P,A,S),state(S).

% nega che un cargo è su un aereo, quando viene scaricato
-in(C,P,S+1) :- unload(C,P,A,S),state(S).

% togliere un aereo da un areoporto quando vola
-at(P,AS,S+1) :- fly(P,AS,AD,S),state(S).

% rimetterlo nella posizione
at(P,AD,S+1) :- fly(P,AS,AD,S),state(S).

% PRECONDIZIONI

:-
