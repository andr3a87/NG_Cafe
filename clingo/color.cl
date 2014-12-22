% Generate
1 { color(X,C) : color(C) } 1 :- house(X).

% Test
:- edge(X,Y), color(X,C), color(Y,C).

% Nodes
node(1..5).

% (Directed) Edges
edge(1,2).
edge(2,3).
edge(3,4).
edge(4,5).

