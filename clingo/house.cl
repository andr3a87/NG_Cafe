% houses
house(1..5).

% (Directed) Edges
adj(1,2).
adj(2,3).
adj(3,4).
adj(4,5).
person_position(nor,1).

% persons
person(eng;spa;jap;ita;nor).

%
%animals(dog;lumaca).
person_animal(spa,dog).

% professions
%professions(painter;)
person_profession(jap,painter).

% bevande favorite
%beverages(tea;coffee;milk;juice).
bev_fav(ita, tea).

% colors
color(red;green;blue;yellow;white).
person_color(eng,red).


% Generate
1 { house_color(X,C) : color(C) } 1 :- house(X).
1 { house_nation(X,N) : person(N) } 1 :- house(X).

% different colors
:- X != Y, house_color(X,C), house_color(Y,C).

% different nationality
:- X != Y, house_nation(X,N), house_nation(Y,N).

% proprietario casa verde beve caffé
bev_fav(X,coffee) :- house_color(X,green).

% casa verde destra bianca
house_color(X,white), house_color(Y,green) :- adj(X,Y).
