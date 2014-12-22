% houses
house_position(1..5).
house_col(red;green;blue;yellow;white).
house_per(eng;spa;jap;ita;nor).
house_prof(painter;sculptor;diplomatic;doctor;violinist;).
house_ani(dog;zebra;horse;fox;snail).
house_bev(coffee;milk;tea;juice;beer).

% (Directed) Edges
adj(1,2).
adj(2,3).
adj(3,4).
adj(4,5).

% Generate
1 { house(P,C,N,PR,A,B) : house_col(C), house_per(N), house_prof(PR), house_ani(A), house_bev(B)} 1 :- house_position(P).
%1 { house(P,_,N) : house_persons(N) } 1 :- house_position(P).


% different colors
:- X != Y, house(X,C,_,_,_,_), house(Y,C,_,_,_,_).

% different nationality
:- X != Y, house(X,_,N,_,_,_), house(Y,_,N,_,_,_).

% different prof
:- X != Y, house(X,_,_,PR,_,_), house(Y,_,_,PR,_,_).

% different animals
:- X != Y, house(X,_,_,_,AN,_), house(Y,_,_,_,AN,_).

% different beverage
:- X != Y, house(X,_,_,_,_,B), house(Y,_,_,_,_,B).

% inglese rosso
:- house(_,red,P,_,_,_), P != eng.

% spagnolo possiede cane
:- house(_,_,P,_,dog,_), P != spa.

% giapponese pittore
:- house(_,_,P,painter,_,_), P != jap.

% italiano beve te
:- house(_,_,P,_,_,tea), P != ita.

% norvegese prima casa a sinistra
:- house(1,_,P,_,_,_), P != nor.

% proprietario casa verde beve caffé
:- house(_,C,_,_,_,coffee), C != green.

% casa verde destra bianca
:- house(X,white,_,_,_,_), house(Y,green,_,_,_,_), not adj(X,Y).

% scultore alleva lumache
:- house(_,_,_,P,snail,_), P != sculptor.

% diplomatico nella casa gialla
:- house(_,yellow,_,P,_,_), P != diplomatic.

% casa 3 si beve latte
:- house(3,_,_,_,_,B), B != milk.

% norv adiacente blue
:- house(2,C,_,_,_,_), C != blue.

% violinista succo di frutta
:- house(_,_,_,P,_,juice), P != violinist.

% volpe adiacente dottore
:- house(X,_,_,_,fox,_), house(Y,_,_,doctor,_,_), not adj(X,Y), not adj(Y,X).

%% % cavallo adiacente diplomatico
:- house(X,_,_,_,horse,_), house(Y,_,_,diplomatic,_,_), not adj(X,Y), not adj(Y,X).

%% %
%% %animals(dog;lumaca).
%% person_animal(spa,dog).

%% % professions
%% %professions(painter;)
%% person_profession(jap,painter).

%% % bevande favorite
%% %beverages(tea;coffee;milk;juice).
%% bev_fav(ita, tea).

%% % colors
%% color(red;green;blue;yellow;white).
%% person_color(eng,red).
