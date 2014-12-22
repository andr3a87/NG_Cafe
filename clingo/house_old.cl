% houses
house(1..5).

% persons
person(eng;spa;jap;ita;nor).

% colors
color(red;green;blue;yellow;white).

% Generate
1 { house_color(X,C) : color(C) } 1 :- house(X).
%% 1 { house_nation(X,N) : person(N) } 1 :- house(X).

% different colors
:- X != Y, house_color(X,C), house_color(Y,C).
:- house_color(4,white).

%% % different nationality
%% :- X != Y, house_nation(X,N), house_nation(Y,N).

%% % proprietario casa verde beve caffé
%% bev_fav(X,coffee) :- house_color(X,green).

%% % casa verde destra bianca
%% house_color(X,white), house_color(Y,green) :- adj(X,Y).
