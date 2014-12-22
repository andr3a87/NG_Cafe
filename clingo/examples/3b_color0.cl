colored(X,r) | colored(X,g) | colored(X,b) :- node(X).
:- edge(X,Y), colored(X,C), colored(Y,C).
node(a).
node(b).
node(c).
edge(a,b).
edge(b,c).
edge(c,a).
