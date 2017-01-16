793113 Magalini Filippo
794132 Maggiotto Davide
793977 Rispoli Claudio

INTRODUZIONE
Lo scopo di questo progetto e' la costruzione di una libreria Common Lisp per la manipolazione di polinomi multivariati.

FUNZIONALITA'
La libreria Common Lisp da noi sviluppata si occupa della rappresentazione e della manipolazione di polinomi multivariati. 
Un monomio viene rappresentato come - (M Coefficiente GradoTotale ((V GradoVar SimboloVar) ...)). 
Un polinomio viene rappresentato come - (POLY ((M Coefficiente GradoTotale ((V GradoVar SimboloVar) ...)) ...)). 
La manipolazione prevede:
	- somma tra due polinomi;
	- differenza tra due polinomi;
	- prodotto tra due polinomi;
	- calcolo del valore numerico di un polinomio in un punto n-dimensionale;
	- ordinamento di un polinomio;
	- stampa a video della rappresentazione tradizionale del polinomio;
	- estrapolazione di coefficiente, grado massimo, grado minimo e simboli di variabile di un polinomio.

ESEMPI DI PREDICATO
Per una spiegazione dei predicati riferirsi ai commenti nel file mvpoli.lisp.

	- as-monomial Expression ⟶ Monomial
	CL-USER 2 > (as-monomial '(* 42 x y x))
		(M 42 3 ((V 2 X) (V 1 Y)))
	
	- as-polynomial Expression ⟶ Polynomial
	CL-USER 3 > (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 2))))
		(POLY ((M 3 1 ((V 1 X))) (M 1.0 2 ((V 2 X)))))
		
	- coefficients Poly ⟶ Coefficients
	CL-USER 4 > (coefficients (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 2)))))
		(3 1.0)
	
	- variables Poly ⟶ Variables
	CL-USER 5 > (variables (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 2)))))
		(X)
			
	- monomials Poly ⟶ Monomials
	CL-USER 6 > (monomials (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 2)))))
		((M 3 1 ((V 1 X))) (M (COS 0) 2 ((V 2 X))))
		
	- maxdegree Poly ⟶ Degree
	CL-USER 7 > (maxdegree (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 2)))))
		2
		
	CL-USER 8 > (maxdegree (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 3) x))))
		4
	
	- mindegree Poly ⟶ Degree
	CL-USER 9 > (mindegree (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 2)))))
		1
		
	CL-USER 10 > (mindegree (as-polynomial '(+ (* 3 x) (* 4 (expt y 2)) (* (cos 0) (expt x 2)) (* -4 (expt y 3) x))))
		1

	- polyplus Poly1, Poly2 ⟶ Result
	CL-USER 11 > (polyplus (as-polynomial '(+ (* 42 x y) (* 37 x))) (as-polynomial '(+ (* 5 x) (* -42 x y))))
		(POLY ((M 42 1 ((V 1 X)))))
	
	- polyminus Poly1, Poly2 ⟶ Result
	CL-USER 1 > (polyminus (as-polynomial '(+ (* 42 x y) (* 37 x))) (as-polynomial '(+ (* 5 x) (* -42 x y))))
		(POLY ((M 32 1 ((V 1 X))) (M 84 2 ((V 1 X) (V 1 Y)))))
		
	CL-USER 3 > (polyminus (as-polynomial '(+ (* 42 x y) (* 37 x))) (as-polynomial '(+ (* 37 x) (* 42 x y))))
		(POLY NIL)
		
	- polytimes Poly1, Poly2 ⟶ Result
	CL-USER 3 > (polytimes (as-polynomial '(+ (* 42 x y) (* 37 x))) (as-polynomial '(+ (* 37 x) (* 42 x y))))
		(POLY ((M 1369 2 ((V 2 X))) (M 3108 3 ((V 2 X) (V 1 Y))) (M 1764 4 ((V 2 X) (V 2 Y)))))
		
	- polyval Polynomial, VariableValues ⟶ Value
	CL-USER 4 > (polyval (as-polynomial '(+ (* 42 x y) (* 37 x))) '(1 1 2))
		79
	
	- pprint-polynomial Polynomial ⟶ NIL
	CL-USER 5 > (pprint-polynomial (as-polynomial '(+ (* 42 x y) (* 37 x))))
		+ 37 * X + 42 * X * Y 
		NIL