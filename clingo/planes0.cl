#const lastlev=1.

level(0..lastlev).
state(0..lastlev+1).

% AZIONI

action(load(C,P,A)) :- cargo(C), plane(P), airport(A).

1{occurs(A,S): action(A)} :- level(S).

% FLUENTI

fluent(in(C,P))  :- cargo(C), plane(P).
fluent(at(C,A))  :- cargo(C), airport(A).

% EFFETTI
%holds(F,S) :- fluent(F), state(S)
%-holds(F,S) :- not fluent(F), state(S)

% afferma la -posizione di un cargo in un areoporto quando viene caricato su un aereo
%-holds(at(C,A), S+1) :- occurs(load(C,P,A),S),state(S).

% afferma che un cargo è su un aereo, quando viene caricato
holds(in(C,P),S+1) :- occurs(load(C,P,A),S),state(S).

% PRECONDIZIONI

% DEVE ESSERE FALSO che ci sia contemporaneamente un'azione di load di un cargo in un plane da un areoporto
% E (ci sia un fatto che indichi che il plane NON sia in quell'areoporto
% O che il cargo NON sia in quell'areoporto
% O che il cargo NON sia su quell'areo)
:- occurs(load(C,P,A),S), -holds(in(C,P),S).
:- occurs(load(C,P,A),S), holds(at(C,A1),S), holds(at(P,A2),S), A1 != A2.
:- occurs(load(C,P,A),S), -holds(at(C,A),S), -holds(at(P,A),S).

% REGOLE CAUSALI
-holds(in(C,P),S) :- cargo(C), plane(P), plane(P1), state(S), holds(in(C,P1),S), P1!=P.
-holds(at(C,A),S) :- cargo(C), airport(A), airport(A1), state(S), holds(at(C,A1),S), A1!=A.
-holds(at(C,A),S) :- cargo(C), airport(A), plane(P), state(S), holds(in(C,P),S).
-holds(at(P,A),S) :- plane(P), airport(A1), airport(A), state(S), holds(at(P,A1),S), A1!=A.

% PERSISTENZA
holds(F, S+1) :-
  fluent(F), state(S),
  holds(F,S), not -holds(F,S+1).

-holds(F,S+1) :-
  fluent(F), state(S),
  -holds(F, S), not holds(F, S+1).

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

%% -holds(at(c1,jfk),0).
%% -holds(at(c2,sfo),0).
%% -holds(at(p1,jfk),0).
%% -holds(at(p2,sfo),0).
%% -holds(in(c1,p1),0).
%% -holds(in(c2,p2),0).
% GOAL

goal:- holds(in(c1,p1),lastlev+1).
:- not goal.

#hide.
#show holds/2.
