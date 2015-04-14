#const lastlev=4.

level(0..lastlev).
state(0..lastlev+1).

% AZIONI

action(load(C,P,A)) :- cargo(C), plane(P), airport(A).
action(unload(C,P,A)) :- cargo(C), plane(P), airport(A).
action(fly(P,A1,A2)) :- plane(P), airport(A1), airport(A2), A1 != A2.

% le azioni possono essere eseguite in parallelo
1{occurs(A,L): action(A)} :- level(L).

% FLUENTI

% cargo C is in plane P
fluent(in(C,P))  :- cargo(C), plane(P).
% cargo C is at airport A
fluent(at(C,A))  :- cargo(C), airport(A).
% plane P is at airport A
fluent(at(P,A))  :- plane(P), airport(A).

% EFFETTI
% i -holds vengono generati dalle regole causali

% afferma che un cargo è su un aereo, quando viene caricato
holds(in(C,P),S+1) :- occurs(load(C,P,A),S),state(S).
% rimette i cargo in un areoporto quando vengono scaricati
holds(at(C,A),S+1) :- occurs(unload(C,P,A),S),state(S).
% mette l'aereo nel nuovo areoporto quando l'azione fly deve essere fatta
holds(at(P,AD),S+1) :- occurs(fly(P,AS,AD),S),state(S).

% PRECONDIZIONI

% precondizioni di laod
% - il cargo non deve essere su un aereo
% - il cargo e l'aereo devono essere nello stesso areoporto
:- occurs(load(C,P0,A),S), holds(in(C,P1),S), airport(A), plane(P1), plane(P0).
:- occurs(load(C,P,A),S), -holds(at(C,A),S), plane(P).
:- occurs(load(C,P,A),S), -holds(at(P,A),S), cargo(C).

% precondizioni di unload
% - il cargo deve essere su quell'aereo, l'aereo in quell'areoporto
:- occurs(unload(C,P,A),S), -holds(in(C,P),S), airport(A).
:- occurs(unload(C,P,A),S), -holds(at(P,A),S), cargo(C).
% - il cargo non deve essere in un areoporto
:- occurs(unload(C,P,A),S), holds(in(C,A),S), plane(P).

% precondizioni di fly
% - il l'aereo deve essere in A1 e non essere in A2
:- occurs(fly(P,A1,A2),S), -holds(at(P,A1),S), holds(at(P,A2),S).

% trick
% lo stesso aereo non può eseguire più azioni nello stesso livello
:- occurs(fly(P,A1,A2),S), occurs(load(C,P,A1),S), plane(P), airport(A1), airport(A2), cargo(C).
:- occurs(fly(P,A1,A2),S), occurs(unload(C,P,A1),S), plane(P), airport(A1), airport(A2), cargo(C).

% PERSISTENZA
holds(F, S+1) :-
  fluent(F), state(S),
  holds(F,S), not -holds(F,S+1).

-holds(F,S+1) :-
  fluent(F), state(S),
  -holds(F, S), not holds(F, S+1).

% REGOLE CAUSALI

% cargo non è in nessun aereo, se è in areoporto
-holds(in(C,P),S) :- cargo(C), airport(A), plane(P), state(S), holds(at(C,A),S).
% cargo è in plane, cargo non è in nessun areoporto
-holds(at(C,A),S) :- cargo(C), airport(A), plane(P), state(S), holds(in(C,P),S).
% cargo è in areoporto, non è in tutti gli altri
-holds(at(C,A2),S) :- cargo(C), airport(A1), airport(A2), state(S), holds(at(C,A1),S), A1!=A2.
% aereo in areoporto, non è in tutti gli altri
-holds(at(P,A2),S) :- plane(P), airport(A1), airport(A2), state(S), holds(at(P,A1),S), A1!=A2.

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
%goal :- holds(at(p1,jfk), lastlev+1).
:- not goal.

#hide.
#show occurs/2.
