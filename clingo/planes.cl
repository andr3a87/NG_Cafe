#const lastlev=10.

level(0..lastlev).
state(0..lastlev+1).

% AZIONI

action(load(C,P,A)) :- cargo(C), plane(P), airport(A).
action(unload(C,P,A)) :- cargo(C), plane(P), airport(A).
action(fly(P,A1,A2)) :- plane(P), airport(A1), airport(A2), A1 != A2.

1{occurs(A,S): action(A)}1 :- level(S).

% FLUENTI

fluent(in(C,P))  :- cargo(C), plane(P).
fluent(at(C,A))  :- cargo(C), airport(A).

% EFFETTI
%holds(F,S) :- fluent(F), state(S)
%-holds(F,S) :- not fluent(F), state(S)

% afferma la -posizione di un cargo in un areoporto quando viene caricato su un aereo
-holds(at(C,A), S+1) :- occurs(load(C,P,A),S),state(S).

% afferma che un cargo è su un aereo, quando viene caricato
holds(in(C,P),S+1) :- occurs(load(C,P,A),S),state(S).

% rimette i cargo in un areoporto quando vengono scaricati
holds(at(C,A),S+1) :- occurs(unload(C,P,A),S),state(S).

% nega che un cargo è su un aereo, quando viene scaricato
-holds(in(C,P),S+1) :- occurs(unload(C,P,A),S),state(S).

% togliere un aereo da un areoporto quando vola
-holds(at(P,AS),S+1) :- occurs(fly(P,AS,AD),S),state(S).

% rimetterlo nella posizione
holds(at(P,AD),S+1) :- occurs(fly(P,AS,AD),S),state(S).

% PRECONDIZIONI

% DEVE ESSERE FALSO che ci sia contemporaneamente un'azione di load di un cargo in un plane da un areoporto
% E (ci sia un fatto che indichi che il plane NON sia in quell'areoporto
% O che il cargo NON sia in quell'areoporto
% O che il cargo NON sia su quell'areo)
:- occurs(load(C,P,A),S), not holds(at(P,A),S).
:- occurs(load(C,P,A),S), not holds(at(C,A),S).
:- occurs(load(C,P,A),S), not holds(in(C,P),S).
:- occurs(load(C,P,A),S), holds(at(C,A1),S), holds(at(P,A2),S), A1 != A2.

% DEVE ESSERE FALSO che ci sia contemporaneamente un'azione di unload di un cargo da un plane in un areoporto
% E (ci sia un fatto che indichi che il cargo NON sia in quello stesso aereo)
:- occurs(unload(C,P,A),S), not holds(in(C,P),S).
% o che l'aereo NON sia in quell'areoporto
:- occurs(unload(C,P,A),S), not holds(at(P,A),S).
% o che il cargo SIA in un altro areoporto
:- occurs(unload(C,P,A),S), holds(at(C1,A1),S), C1 != C, A1 != A.

%
:- occurs(fly(P,A1,A2),S), not holds(at(P,A1),S), holds(at(P,A2),S).

% PERSISTENZA
holds(F, S+1) :-
  fluent(F), state(S),
  holds(F,S), not -holds(F,S+1).

-holds(F,S+1) :-
  fluent(F), state(S),
  -holds(F, S), not holds(F, S+1).

% REGOLE CAUSALI
-holds(in(C,P),S) :- cargo(C), plane(P), plane(P1), state(S), holds(in(C,P1),S), P1!=P.
-holds(at(C,A),S) :- cargo(C), airport(A), airport(A1), state(S), holds(at(C,A1),S), A1!=A.
-holds(at(C,A),S) :- cargo(C), airport(A), plane(P), state(S), holds(in(C,P),S).
-holds(at(P,A),S) :- plane(P), airport(A1), airport(A), state(S), holds(at(P,A1),S), A1!=A.

% STATO INIZIALE
cargo(c1).
cargo(c2).
plane(p1).
plane(p2).
airport(jfk).
airport(sfo).

holds(at(c1,sfo),0).
holds(at(c2,jfk),0).
holds(at(p1,sfo),0).
holds(at(p2,jfk),0).

% GOAL

goal:- holds(at(c1,jfk),lastlev+1), holds(at(c2,sfo),lastlev+1).
:- not goal.

