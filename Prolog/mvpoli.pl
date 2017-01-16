%%%% 793113 Magalini Filippo
%%%% 794132 Maggiotto Davide
%%%% 793977 Rispoli Claudio

%%%% -*- Mode: Prolog -*-
is_monomial(m(_C, TD, VPs)) :-
	integer(TD),
	TD >= 0,
	get_gradi(VPs, Gradi),
	somma(Gradi, Z),
	TD = Z,
	is_list(VPs).

is_varpower(v(Power, VarSymbol)) :-
	integer(Power),
	Power >= 0,
	atom(VarSymbol).

is_polynomial(poly(Monomials)) :-
	is_list(Monomials),
	foreach(member(M, Monomials), is_monomial(M)).

% Data una espressione matematica crea il monomio in forma m(C,TD,VPs)
as_monomial(Expression, Monomial) :-
	parse_monomio(Expression, MonomioR),
	reverse(MonomioR, Monomio),
	componi_monomio(Monomio, MonomioNO),
	ordina_monomio(MonomioNO, MonomioO),
	semplifica_monomi(MonomioO, MonomioONO),
	clean_variabili(MonomioONO, Monomial).

% Data una espressione matematica crea il polinomio in forma
% poly([m(C,TD,VPs)...])
as_polynomial(Expression, Poly) :-
	parse_polinomio(Expression, PolinomioR),
	reverse(PolinomioR, Monomios),
	componi_polinomio(poly(Monomios), AllMonomios),
	sum_monomials(AllMonomios, ResultNO),
	ordina_polinomio(ResultNO, ResultO),
	clean_monomi(ResultO, Monomials),
	Poly = poly(Monomials).

% Coefficients unifica con la lista dei coefficienti di un polinomio
coefficients(poly([]), [0]) :- !.

coefficients(poly(Monomi), Coefficients) :-
	!,
	sum_monomials(Monomi, MonomiS),
	ordina_polinomio(MonomiS, MonomiOR),
	get_coefficienti(MonomiOR, Coefficients).

% Coefficients unifica con la lista dei coefficienti di un monomio 
% dato in input convertendolo in un polinomio.
coefficients(Poly, Coefficients) :-
	as_polynomial(Poly, R),
	!,
	coefficients(R, Coefficients).

% Variables unifica con la lista senza duplicati delle variabili contenute
% in un polinomio o in un monomio.
variables(Poly, Variables) :-
	monomials(Poly, Monomi),
	!,
	var(Monomi, VariabiliMonomiUF),
	flatten(VariabiliMonomiUF, VariabiliMonomiF),
	compress(VariabiliMonomiF, Variables).

variables(Poly, Variables) :-
	as_polynomial(Poly, R),
	!,
	variables(R, Variables).

% Monomials unifica con la lista di tutti i monomi che compongono un polinomio.
monomials(poly([]), [m(0, 0, [])]) :- !.

monomials(m(C, Gr, Vs), Monomials) :-
	!,
	monomials(poly([m(C, Gr, Vs)]), Monomio),
	ordina_polinomio(Monomio, Monomials).

monomials(Poly, Monomials) :-
	Poly = poly(Monomio),
	!,
	ordina_polinomio(Monomio, Monomials).

monomials(Poly, Monomials) :-
	as_polynomial(Poly, R),
	!,
	monomials(R, Monomials).

% Degree unifica con il grado massimo tra tutti i monomi del polinomio.
maxdegree(Poly, Degree) :-
	monomials(Poly, Monomi),
	degree(Monomi, R),
	flatten(R, R1),
	max(R1, Degree).

% Degree unifica con il grado minimo tra tutti i monomi del polinomio.
mindegree(Poly, Degree) :-
	monomials(Poly, Monomi),
	degree(Monomi, R),
	flatten(R, R1),
	min(R1, Degree).

% Stampa in forma standard il polinomio (o il monomio) in input.
pprint_polynomial(Polynomial) :-
	monomials(Polynomial, Monomios),
	!,
	print_monomio(Monomios).

pprint_polynomial(Polynomial) :-
	as_polynomial(Polynomial, P),
	!,
	pprint_polynomial(P).

% Result unifica con la somma tra i due polinomi (o monomi).
polyplus(Poly1, Poly2, Result) :-
	monomials(Poly1, Monomios1),
	monomials(Poly2, Monomios2),
	!,
	append(Monomios1, Monomios2, AllMonomios),
	sum_monomials(AllMonomios, ResultNO),
	ordina_polinomio(ResultNO, ResultO),
	clean_monomi(ResultO, Monomials),
	Result = poly(Monomials).

polyplus(Poly1, poly(Poly2), Result) :-
	as_polynomial(Poly1, P1),
	!,
	polyplus(P1, poly(Poly2), Result).

polyplus(poly(Poly1), Poly2, Result) :-
	as_polynomial(Poly2, P2),
	!,
	polyplus(poly(Poly1), P2, Result).

polyplus(Poly1, Poly2, Result) :-
	as_polynomial(Poly1, P1),
	as_polynomial(Poly2, P2),
	!,
	polyplus(P1, P2, Result).

% Result unifica con la differenza tra i due polinomi (o monomi).
polyminus(Poly1, Poly2, Result) :-
	monomials(Poly1, Monomios1),
	monomials(Poly2, Monomios2),
	!,
	cambio_segno(Monomios2, Monomios2I),
	append(Monomios1, Monomios2I, Monomios),
	sum_monomials(Monomios, MonomiosNO),
	ordina_polinomio(MonomiosNO, MonomiosO),
	clean_monomi(MonomiosO, Monomials),
	Result = poly(Monomials).

polyminus(Poly1, poly(Poly2), Result) :-
	as_polynomial(Poly1, P1),
	!,
	polyminus(P1, poly(Poly2), Result).

polyminus(poly(Poly1), Poly2, Result) :-
	as_polynomial(Poly2, P2),
	!,
	polyminus(poly(Poly1), P2, Result).

polyminus(Poly1, Poly2, Result) :-
	as_polynomial(Poly1, P1),
	as_polynomial(Poly2, P2),
	!,
	polyminus(P1, P2, Result).

% Result unifica con il prodotto tra i due polinomi (o monomi).
polytimes(Poly1, Poly2, Result) :-
	monomials(Poly1, Monomios1),
	monomials(Poly2, Monomios2),
	!,
	moltiplica_monomi(Monomios1, Monomios2, ResNS),
	sum_monomials(ResNS, ResNO),
	ordina_polinomio(ResNO, ResO),
	clean_monomi(ResO, Monomials),
	Result = poly(Monomials).

polytimes(Poly1, poly(Poly2), Result) :-
	as_polynomial(Poly1, P1),
	!,
	polytimes(P1, poly(Poly2), Result).

polytimes(poly(Poly1), Poly2, Result) :-
	as_polynomial(Poly2, P2),
	!,
	polytimes(poly(Poly1), P2, Result).

polytimes(Poly1, Poly2, Result) :-
	as_polynomial(Poly1, P1),
	as_polynomial(Poly2, P2),
	!,
	polytimes(P1, P2, Result).

% Value unifica con il valore del polinomio (o monomio) con le variabili
% sostituite con i valori numerici contenuti in VariableValues
polyval(Polynomial, VariableValues, Value) :-
	monomials(Polynomial, Monomios),
	!,
	variables(Polynomial, Variables),
	sostituisci_valori(Monomios, Variables, VariableValues, Result),
	elevamento(Result, RT),
	moltiplicazione(RT, RT1),
	somma(RT1, Value).

polyval(Polynomial, VariableValues, Value) :-
	as_polynomial(Polynomial, P),
	!,
	polyval(P, VariableValues, Value).

% Date due liste di monomi viene calcolato il prodotto
moltiplica_monomi([], [], []) :- !.

moltiplica_monomi([], _, []) :-	!.

moltiplica_monomi(_, [], []) :-	!.

moltiplica_monomi([m(C1, G1, Vs1)|Xs], [m(C2, G2, Vs2)|Ys], [m(C, G, V)|Zs]) :-
	!,
	C is C1 * C2,
	G is G1 + G2,
	append(Vs1, Vs2, VarsR),
	sort(2, @=<, VarsR, VarsRR),
	straknapk(VarsRR, V),
	moltiplica_monomi([m(C1, G1, Vs1)], Ys, Zss),
	moltiplica_monomi(Xs, [m(C2, G2, Vs2)|Ys], Zsss),
	append(Zss, Zsss, Zs).

% Dati due monomi aventi le stesse variabili viene effettuata la 
% semplificazione.
semplifica_monomi(m(Coeff, TD, Vars), m(Coeff, TD, VarR)) :-
	straknapk(Vars, VarR).

% Dato un monomio vengono eliminate le variabili che hanno esponente pari a 0.
clean_variabili(m(Coeff, TD, Vars), m(Coeff, TD, VarR)) :-
	!,
	elimina_variabili(Vars, VarR).

elimina_variabili([], []) :- !.

elimina_variabili([v(0, _)|Xs], Ys) :-
	!,
	elimina_variabili(Xs, Ys).

elimina_variabili([v(Gr, Var)|Xs], [v(Gr, Var)|Ys]) :-
	!,
	elimina_variabili(Xs, Ys).

% Semplifica la lista di variabili sommando quelle con variabili uguale.
straknapk([], []) :- !.

straknapk([v(Exp, Var)], [v(Exp, Var)]) :- !.

straknapk([v(Exp1, Var), v(Exp2, Var)|Xs], Ys) :-
	!,
	ExpT is Exp1 + Exp2,
	straknapk([v(ExpT, Var)|Xs], Ys).

straknapk([v(Exp1, Var1), v(Exp2, Var2)|Xs], [v(Exp1, Var1)|Ys]) :-
	!,
	straknapk([v(Exp2, Var2)|Xs], Ys).

% Effettua tutte le moltiplicazioni presenti in una lista di numeri ed 
% operazioni.
moltiplicazione([], []) :- !.

moltiplicazione([_X], []) :- !.

moltiplicazione([X, *, Y, *|Xs], Zs) :-
	!,
	Z is X * Y,
	moltiplicazione([Z, *|Xs], Zs).

moltiplicazione([X, *, Y|Xs], [Z|Zs]) :-
	!,
	Z is X * Y,
	moltiplicazione(Xs, Zs).

moltiplicazione([X, Y|Xs], [X|Zs]) :-
	!,
	moltiplicazione([Y|Xs], Zs).

% Effettua tutti gli elevamenti a potenza presenti in una lista di numeri ed 
% operazioni.
elevamento([], []) :- !.

elevamento([X], [X]) :- !.

elevamento([*|Xs], [*|Zs]) :-
	!,
	elevamento(Xs, Zs).

elevamento([X, *|Xs], [X, *|Zs]) :-
	!,
	elevamento(Xs, Zs).

elevamento([X, ^, Y|Xs], [Z|Zs]) :-
	!,
	Z is X ^ Y,
	elevamento(Xs, Zs).

elevamento([X, Y|Xs], [X|Zs]) :-
	!,
	elevamento([Y|Xs], Zs).

% Data una lista di monomi, una lista di variabili, una lista di valori di 
% variabile; Result unifica con la sostituzione dei valori delle variabili
% all'interno dei monomi. 
sostituisci_valori(Monomios, Variables, VariableValues, Result) :-
	crea_polinomio(Monomios, R1),
	flatten(R1, R2),
	merge_lista(Variables, VariableValues, R),
	sostituisci(R, R2, Result).

sostituisci([X,Y|Xs], Listavecchia, Risultato) :-
	!,
	replace(X,Y, Listavecchia, Listanuova),
	sostituisci(Xs, Listanuova, Risultato).

sostituisci([], Rs, Rs) :- !.

% Sostituisce ogni occorrenza di un elemento all'interno di una lista
replace(_, _, [], []) :-
	!.

replace(O, R, [O|T], [R|T2]) :-
	!,
	replace(O, R, T, T2).

replace(O, R, [H|T], [H|T2]) :-
	H \= O, replace(O, R, T, T2).

% Unisce due liste alternando gli elementi della prima con quelli della seconda
merge_lista([], _, []) :- !.

merge_lista([X|Xs], [Y|Ys], [X, Y|Zs]) :-
	!,
	merge_lista(Xs, Ys, Zs).

% Data una lista di monomi parsati crea una lista con i valori numerici delle 
% variabili al posto di queste ultime, e aggiunge anche i simboli delle 
% espressioni matematiche per i calcoli successivi
crea_polinomio([], []) :- !.

crea_polinomio([m(Coeff, 0, [])], [Coeff]) :- !.

crea_polinomio([m(Coeff, 0, [])|Xs], [Coeff|Ys]) :-
	!,
	crea_polinomio(Xs, Ys).

crea_polinomio([m(Coeff, _, Vars)|Xs], [Coeff, *, VarsL| Ys]) :-
	!,
	crea_variabili(Vars, VarsL),
	crea_polinomio(Xs, Ys).

crea_variabili([], []) :- !.

crea_variabili([v(Gr, Var)], [Var, ^, Gr]) :- !.

crea_variabili([v(Gr, Var)|Xs], [Var, ^, Gr, *|Ys]) :-
	!,
	crea_variabili(Xs, Ys).

% Somma tra loro i coefficienti di due monomi se questi hanno la lista di 
% variabili uguale
sum_monomials(Monomials, Result) :-
	sum_monomials(Monomials, [], Unordered),
	ordina_monomi(Unordered, Result).

sum_monomials([], [], []) :- !.

sum_monomials([m(C1, T, Vars), m(C2, T, Vars) | Monomials], Rest, Sums) :-
	!,
	C is C1 + C2,
	Sum = m(C, T, Vars),
	sum_monomials([Sum | Monomials], Rest, Sums).

sum_monomials([m(C1, T1, Vs1), m(C2, T2, Vs2) | Monomials], Rest, Sums) :-
	Vs1 \= Vs2,
	!,
	sum_monomials([m(C1, T1, Vs1) | Monomials], [m(C2, T2, Vs2)| Rest], Sums).

sum_monomials([Monomial], [], [Monomial]) :- !.

sum_monomials([Monomial], Rest, [Monomial | Sums]) :-
	Rest \= [],
	!,
	sum_monomials(Rest, [], Sums).

% Cambia il segno di tutti i coefficienti dei monomi presenti in una lista 
% di monomi
cambio_segno([], []) :- !.

cambio_segno(m(Coeff, G, Vars), m(Coeff2, G, Vars)) :-
	!,
	Coeff2 is -Coeff.

cambio_segno([m(Coeff, G, Vars)|Xs], [m(Coeff2, G, Vars)|Ys]) :-
	!,
	Coeff2 is -Coeff,
	cambio_segno(Xs, Ys).

% Elimina tutti i monomi da una liste se questi hanno coefficiente 
% uguale a zero
clean_monomi([], []) :- !.

clean_monomi([m(C, _, _)| Xs], Ys) :-
	C =:= 0,
	!,
	clean_monomi(Xs, Ys).

clean_monomi([m(- C, _, _)| Xs], Ys) :-
	C =:= 0,
	!,
	clean_monomi(Xs, Ys).

clean_monomi([m(Coeff, Grade, Vars)|Xs], [m(Coeff, Grade, Vars)|Ys]) :-
	!,
	clean_monomi(Xs, Ys).

%% Print Utility
% Stampa un monomio a video
print_monomio([]) :- !.

print_monomio([m(Coeff, 0, _) | Xs]) :-
	Coeff \= 1,
	Coeff \= -1,
	arithmetic_expression_value(Coeff, C),
	!,
	write(C),
	write(' '),
	print_monomio(Xs).

print_monomio([m(1, _, Vars) | Xs]) :-
	!,
	write('+ '),
	print_var(Vars),
	write(' '),
	print_monomio(Xs).

print_monomio([m(-1, _, Vars) | Xs]) :-
	!,
	write('- '),
	print_var(Vars),
	write(' '),
	print_monomio(Xs).

print_monomio([m(Coeff, _, Vars) | Xs]) :-
	Coeff > 0,
	!,
	arithmetic_expression_value(Coeff, C),
	write('+ '),
	write(C),
	write(' * '),
	print_var(Vars),
	write(' '),
	print_monomio(Xs).

print_monomio([m(Coeff, _, Vars) | Xs]) :-
	Coeff < 0,
	!,
	arithmetic_expression_value(Coeff, C),
	VA is abs(C),
	write('- '),
	write(VA),
	write(' * '),
	print_var(Vars),
	write(' '),
	print_monomio(Xs).

print_monomio([m(Coeff, _, Vars) | Xs]) :-
	!,
	write(Coeff),
	write(' * '),
	print_var(Vars),
	write(' '),
	print_monomio(Xs).

% Stampa le variabili di un monomio
print_var([]) :- !.

print_var([v(1, Var)]) :-
	!,
	write(Var).

print_var([v(1, Var) | Vs]) :-
	!,
	write(Var),
	write(' * '),
	print_var(Vs).

print_var([v(Exp, Var)]) :-
	!,
	write(Var),
	write(^),
	write(Exp).

print_var([v(Exp, Var) | Vs]) :-
	!,
	write(Var),
	write(^),
	write(Exp),
	write(' * '),
	print_var(Vs).

%% Lista tutti i gradi totali dei monomi.
degree([], []) :- !.

degree([m(_, Td, _)|Resto], [Td | Ys]) :-
	degree(Resto, Ys).

%% Lista tutte le variabili di tutti i monomi.
var([], []) :- !.

var([m(_, _,Var)|Resto], [V|Ys]) :-
	!,
	get_variabili(Var, V),
	var(Resto, Ys).

%% Lista tutte le variabili di un monomio.
get_variabili([], []) :- !.

get_variabili([X | Xs], [Y| Ys]) :-
	arg(2, X, Y),
	get_variabili(Xs, Ys).

get_gradi([], []) :- !.

get_gradi([X | Xs], [Y| Ys]) :-
	arg(1, X, Y),
	get_gradi(Xs, Ys).

%% Restituisce una lista contenente tutti i coefficienti dei monomi di un
%% polinomio.
get_coefficienti([], []) :- !.

get_coefficienti([m(Coeff, _, _)|Resto], [Coeff|Ys]):-
	get_coefficienti(Resto, Ys).

% Esegue il parsing di un polinomio in forma di espressione
parse_polinomio(Resto + Fattore, [Monomio | Monomios]) :-
	!,
	as_monomial(Fattore, Monomio),
	parse_polinomio(Resto, Monomios).

parse_polinomio(Resto - Fattore, [Monomio | Monomios]) :-
	!,
	as_monomial(Fattore, MonomioP),
	MonomioP =.. [Functor, Coefficient| Vars],
	Monomio =.. [Functor, CoefficientN| Vars],
	CoefficientN is	- Coefficient,
	parse_polinomio(Resto, Monomios).

parse_polinomio(Fattore, [Monomio]) :-
	!,
	as_monomial(Fattore, Monomio).

parse_monomio(_C + _X, []) :-
	!,
	fail.
	
parse_monomio(C * X , [X | Xs]) :-
	!,
	parse_monomio(C, Xs).

parse_monomio(X , [X]) :-
	!.

% Compone un monomio restituendolo in forma parsata
componi_monomio([0|_], R) :-
	!,
	R = m(0,0,[]).

componi_monomio(F, R) :-
	!,
	coefficiente(F,P,C),
	potenzavar(P,V),
	gradovar(V, D),
	R = m(C,D,V).

componi_polinomio(Polinomio, Ordinato) :-
	monomials(Polinomio, Monomios),
	ordina_polinomio(Monomios, Ordinato).

%% Utility Liste
%% Elimina tutti i duplicati da una lista
compress([], []).

compress([X|Xs], Z) :-
	member(X, Xs), compress(Xs, Z), !.

compress([X|Xs], [X|Ys]) :- compress(Xs, Ys).

%% Restituisce il massimo numero contenuto in una lista
max([], 0) :- !.

max([X], X) :- !.

max([X|Xs], X) :- max(Xs, Z), X >= Z, !.

max([X|Xs], Z) :- max(Xs, Z), X < Z.

%% Restituisce il minimo numero contenuto in una lista
min([], 0) :- !.

min([X], X) :- !.

min([X|Xs], X) :- min(Xs, Z), X =< Z, !.

min([X|Xs], Z) :- min(Xs, Z), X > Z.

%% Somma tra loro tutti gli elementi di una lista
somma([], 0).

somma([X|Xs], Y) :- somma(Xs, Z), Y is Z + X.

% Utility Monomi
coefficiente([Coeff | R], R, C) :-
	compound(Coeff),
	arithmetic_expression_value(Coeff, C),
	!.

coefficiente([C | R], R, C) :-
	number(C),
	!.

coefficiente([-C | R], R, -C) :-
	number(C),
	!.

coefficiente([-V | R], [V | R], -1) :-
	!.

coefficiente(F,F,1) :-
	!.

potenzavar([],[]) :-
	!.

potenzavar([V ^ P | R], [v(P, V) | Ps]) :-
	!,
	potenzavar(R, Ps).

potenzavar([V | R], [v(1, V) | Ps]) :-
	!,
	potenzavar(R, Ps).

gradovar(Vs, D) :-
	gradovar(Vs, 0, D).

gradovar([], V, V).

gradovar([Vs | Vss], Contatore, Pt) :-
	arg(1, Vs, P),
	ContatoreF is Contatore + P,
	gradovar(Vss, ContatoreF, Pt).

%% Sorting Utility
ordina_monomi([], []).

ordina_monomi([Monomio| Monomios], [Ordinato| Resto]) :-
	ordina_monomio(Monomio, Ordinato),
	ordina_monomi(Monomios, Resto).

ordina_monomio(m(C, PT, V), m(C, PT, VS)) :-
	sort(2, @=<, V, VS).

ordina_polinomio(MonomioNO, Ordinato) :-
	ordina_monomi(MonomioNO, R),
	sort(3, @=<, R, Ordinato).