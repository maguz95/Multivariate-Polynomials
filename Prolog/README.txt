793113 Magalini Filippo
794132 Maggiotto Davide
793977 Rispoli Claudio

INTRODUZIONE
Lo scopo di questo progetto e' la costruzione di una libreria Prolog per la manipolazione 
di polinomi multivariati.

FUNZIONALITA'
La libreria Prolog da noi sviluppata si occupa della rappresentazione e della manipolazione di polinomi multivariati.
Un monomio viene rappresentato come - m(Coefficiente, GradoTotale, [v(GradoVar, SimboloVar) ...]).
Un polinomio viene rappresentato come - poly([m(Coefficiente, GradoTotale, [v(GradoVar, SimboloVar) ...])... ]). 
La manipolazione prevede:
	- somma tra due polinomi;
	- differenza tra due polinomi;
	- prodotto tra due polinomi;
	- calcolo del valore numerico di un polinomio in un punto n-dimensionale;
	- ordinamento di un polinomio;
	- stampa a video della rappresentazione tradizionale del polinomio;
	- estrapolazione di coefficiente, grado massimo, grado minimo e simboli di variabile di un polinomio.

ESEMPI DI PREDICATO
Per una spiegazione dei predicati riferirsi ai commenti nel file mvpoli.pl.

	- as_monomial(Expression, Monomial).
		?- as_monomial(42 * x * y * x, X).
		X = m(42, 3, [v(2, x), v(1, y)]).
	
	- as_polynomial(Expression, Polynomial).
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 2, X).
		X = poly([m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])]).
		
	- coefficients(Poly, Coefficients).
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 2, X),  coefficients(X,Y).
		X = poly([m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])]),
		Y = [3, 1.0].
	
	- variables(Poly, Variables).
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 2, X), variables(X, Y).
		X = poly([m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])]),
		Y = [x].
			
	- monomials(Poly, Monomials).
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 2, X), monomials(X, Y).
		X = poly([m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])]),
		Y = [m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])].
		
	- maxdegree(Poly, Degree).
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 2, X), maxdegree(X, Y).
		X = poly([m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])]),
		Y = 2.
		
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 3 * x, X), maxdegree(X, Y). 
		X = poly([m(3, 1, [v(1, x)]), m(-4, 4, [v(1, x), v(3, y)]), m(1.0, 2, [v(2, x)]), m(4, 2, [v(2, y)])]),
		Y = 4.
	
	- mindegree(Poly, Degree).
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 2, X), mindegree(X, Y).
		X = poly([m(3, 1, [v(1, x)]), m(1.0, 2, [v(2, x)])]),
		Y = 1.
		
		?- as_polynomial(3 * x + 4 * y ^ 2 + cos(0) * x ^ 2 - 4 * y ^ 3 * x, X), mindegree(X, Y). 
		X = poly([m(3, 1, [v(1, x)]), m(-4, 4, [v(1, x), v(3, y)]), m(1.0, 2, [v(2, x)]), m(4, 2, [v(2, y)])]),
		Y = 1.
	
	- polyplus(Poly1, Poly2, Result).
		?- as_polynomial(42 * x * y + 37 * x, X), as_polynomial(5 * x - 42 * x * y, Y), polyplus(X, Y, Z).
		X = poly([m(37, 1, [v(1, x)]), m(42, 2, [v(1, x), v(1, y)])]),
		Y = poly([m(5, 1, [v(1, x)]), m(-42, 2, [v(1, x), v(1, y)])]),
		Z = poly([m(42, 1, [v(1, x)])]).
	
	- polyminus(Poly1, Poly2, Result).
		?-  as_polynomial(42 * x * y + 37 * x, X), as_polynomial(5 * x - 42 * x * y, Y), polyminus(X, Y, Z).
		X = poly([m(37, 1, [v(1, x)]), m(42, 2, [v(1, x), v(1, y)])]),
		Y = poly([m(5, 1, [v(1, x)]), m(-42, 2, [v(1, x), v(1, y)])]),
		Z = poly([m(32, 1, [v(1, x)]), m(84, 2, [v(1, x), v(1, y)])]).
		
		?-  as_polynomial(42 * x * y + 37 * x, X), as_polynomial(37 * x + 42 * x * y, Y), polyminus(X, Y, Z).
		X = Y, Y = poly([m(37, 1, [v(1, x)]), m(42, 2, [v(1, x), v(1, y)])]),
		Z = poly([]).
		
	- polytimes(Poly1, Poly2, Result).
		?- as_polynomial(42 * x * y + 37 * x, X), as_polynomial(5 * x - 42 * x * y, Y), polytimes(X, Y, Z).
		X = poly([m(37, 1, [v(1, x)]), m(42, 2, [v(1, x), v(1, y)])]),
		Y = poly([m(5, 1, [v(1, x)]), m(-42, 2, [v(1, x), v(1, y)])]),
		Z = poly([m(185, 2, [v(2, x)]), m(-1344, 3, [v(2, x), v(1, y)]), m(-1764, 4, [v(2, x), v(2, y)])]).
		
	- polyval(Polynomial, VariableValues, Value).
		?- as_polynomial(42 * x * y + 37 * x, X), polyval(X, [1, 1, 2], Y).
		X = poly([m(37, 1, [v(1, x)]), m(42, 2, [v(1, x), v(1, y)])]),
		Y = 79.
	
	- pprint_polynomial(Polynomial).
		?- as_polynomial(42 * x * y + 37 * x, X), pprint_polynomial(X).
		+ 37 * x + 42 * x * y 
		X = poly([m(37, 1, [v(1, x)]), m(42, 2, [v(1, x), v(1, y)])]).