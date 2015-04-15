#const lastlev=500.

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
:- occurs(load(C,P0,A),S), holds(in(C,P1),S).
:- occurs(load(C,P,A),S), -holds(at(C,A),S).
:- occurs(load(C,P,A),S), -holds(at(P,A),S).

% precondizioni di unload
% - il cargo deve essere su quell'aereo, l'aereo in quell'areoporto
:- occurs(unload(C,P,A),S), -holds(in(C,P),S).
:- occurs(unload(C,P,A),S), -holds(at(P,A),S).
% - il cargo non deve essere in un areoporto
:- occurs(unload(C,P,A),S), holds(in(C,A),S).

% precondizioni di fly
% - il l'aereo deve essere in A1 e non essere in A2
:- occurs(fly(P,A1,A2),S), -holds(at(P,A1),S).

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

% #Problema 1
% STATO INIZIALE
%% cargo(c1).
%% cargo(c2).
%% plane(p1).
%% plane(p2).
%% airport(jfk).
%% airport(sfo).

%% holds(at(c1,sfo),0).
%% holds(at(c2,jfk),0).
%% holds(at(p1,sfo),0).
%% holds(at(p2,jfk),0).

%% % GOAL
%% goal:- holds(at(c1,jfk),lastlev+1), holds(at(c2,sfo),lastlev+1).

% #Problema 2
% STATO INIZIALE
cargo(c1).
cargo(c2).
cargo(c3).
cargo(c4).
cargo(c5).
cargo(c6).
cargo(c7).
cargo(c8).
cargo(c9).
cargo(c10).
cargo(c11).
cargo(c12).
cargo(c13).
cargo(c14).
cargo(c15).
cargo(c16).
cargo(c17).
cargo(c18).
cargo(c19).
cargo(c20).
cargo(c21).
cargo(c22).
cargo(c23).
cargo(c24).
cargo(c25).
cargo(c26).
cargo(c27).
cargo(c28).
cargo(c29).
cargo(c30).
plane(p1).
plane(p2).
plane(p3).
plane(p4).
plane(p5).
plane(p6).
plane(p7).
plane(p8).
plane(p9).
plane(p10).
airport(a1).
airport(a2).
airport(a3).
airport(a4).
airport(a5).
airport(a6).
airport(a7).
airport(a8).
airport(a9).
airport(a10).
airport(a11).
airport(a12).
airport(a13).
airport(a14).
airport(a15).
airport(a16).
airport(a17).
airport(a18).
airport(a19).
airport(a20).

holds(at(p1,a1),0).
holds(at(p2,a7),0).
holds(at(p3,a2),0).
holds(at(p4,a2),0).
holds(at(p5,a5),0).
holds(at(p6,a5),0).
holds(at(p7,a5),0).
holds(at(p8,a5),0).
holds(at(p9,a9),0).
holds(at(p10,a11),0).

holds(at(c1,a2),0).
holds(at(c2,a2),0).
holds(at(c3,a3),0).
holds(at(c4,a3),0).
holds(at(c5,a3),0).
holds(at(c6,a3),0).
holds(at(c7,a6),0).
holds(at(c8,a9),0).
holds(at(c9,a11),0).
holds(at(c10,a12),0).
holds(at(c11,a14),0).
holds(at(c12,a14),0).
holds(at(c13,a14),0).
holds(at(c14,a14),0).
holds(at(c15,a14),0).
holds(at(c16,a6),0).
holds(at(c17,a7),0).
holds(at(c18,a8),0).
holds(at(c19,a9),0).
holds(at(c20,a10),0).
holds(at(c21,a12),0).
holds(at(c22,a12),0).
holds(at(c23,a13),0).
holds(at(c24,a13),0).
holds(at(c25,a13),0).
holds(at(c26,a13),0).
holds(at(c27,a16),0).
holds(at(c28,a19),0).
holds(at(c29,a20),0).
holds(at(c30,a20),0).

% GOAL
goal:-  holds(at(p1,a6), lastlev+1),
        holds(at(p2,a3), lastlev+1),
        holds(at(p3,a1), lastlev+1),
        holds(at(p4,a1), lastlev+1),
        holds(at(p5,a8), lastlev+1).

:- not goal.

#show occurs/2.
