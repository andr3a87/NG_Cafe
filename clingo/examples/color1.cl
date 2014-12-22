
col(rosso). col(verde).  col(blu).

% uso dei conditional literals

% Generate
1 { color(X,C) : col(C) } 1 :- node(X).

% L'aggregato { color(X,C) : col(C) } rappresenta l'insieme
% {color(X,rosso), color(X,verde), color(X,blu)}


% Test
:- edge(X,Y), color(X,C), color(Y,C).


% Nodes
node(1..6).

% (Directed) Edges
edge(1,2;3;4).  edge(2,4;5;6).  edge(3,1;4;5).
edge(4,1;2).    edge(5,3;4;6).  edge(6,2;3;5).
