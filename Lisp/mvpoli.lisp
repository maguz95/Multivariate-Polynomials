;;;; 793113 Magalini Filippo
;;;; 794132 Maggiotto Davide
;;;; 793977 Rispoli Claudio

(defun is-monomial (m)
  (and (listp m)
       (eq 'm (first m))
       (let ((mtd (monomial-degree m))
             (vps (varpowers m))
            )
          (and (integerp mtd)
               (>= mtd 0)
               (listp vps)
               (every #'is-varpower vps)))))

(defun is-varpower(vp)
  (and (listp vp)
       (eq 'v (first vp))
       (let ((p (varpower-power vp))
             (v (varpower-symbol vp)))
         (and (integerp p)
              (>= p 0) 
              (symbolp v)))))

(defun is-polynomial (p)
  (and (listp p)
       (eq 'poly (first p))
       (let ((ms (poly-monomials p)))
         (and (listp ms)
              (every #'is-monomial ms)))))

;Restituisce la lista delle varpowers ((V Esp Base) ..) di un monomio parsato
(defun varpowers (m)
  (fourth m))

;Restituisce la lista di variabili di un monomio parsato
(defun vars-of (m)
   (if (is-monomial m)
       (get-vars (fourth m))
     (vars-of (as-monomial m))))

;Restituisce il grado totale di un monomio parsato
(defun monomial-degree (m) 
  (third (as-monomial m)))

;Restituisce il coefficiente di un monomio parsato
(defun monomial-coefficient (m)
  (second (as-monomial m)))

;Restituisce la lista dei coefficienti dei monomi di un polinomio
(defun coefficients (poly)
  (if (is-polynomial poly)
      (if (null (second poly))
          (list 0)
        (extract-coeff (poly-monomials poly)))
    (coefficients (as-polynomial poly))))

;Restituisce la lista delle variabili (prese una volta)  di un polinomio
(defun variables (poly)
  (if (is-polynomial poly)
      (extract-vars (poly-monomials poly))
    (variables (as-polynomial poly))))

;Restituisce la lista ordinata dei monomi di un polinomio
(defun monomials (poly)
  (if (is-polynomial poly)
      (sort-monos (poly-monomials poly))
    (monomials (as-polynomial poly))))

;Restituisce il grado massimo tra le variabili di un polinomio
(defun maxdegree (poly)
  (if (is-polynomial poly)
      (reduce #'max (extract-degree (monomials poly)))
    (maxdegree (as-polynomial poly))))

;Restituisce il grado minimo tra le variabili di un polinomio
(defun mindegree (poly)
  (if (is-polynomial poly)
      (reduce #'min (extract-degree (monomials poly)))
    (mindegree (as-polynomial poly))))

;Restituisce la somma tra due polinomi
(defun polyplus (poly1 poly2)
  (append 
   (list 'poly) 
   (list (clean-monomials 
          (simplify-monomials 
           (sort-monos (append (if (null (monomials poly1))
                                   (list '(M 0 0 NIL))
                                 (monomials poly1))
                               (if (null (monomials poly2))
                                   (list '(M 0 0 NIL))
                                 (monomials poly2)))))))))

;Restituisce la differenza tra due polinomi
(defun polyminus (poly1 poly2)
 (append 
  (list 'poly) 
  (list (clean-monomials 
         (simplify-monomials 
          (sort-monos (append (monomials poly1) 
                              (change-sign (monomials poly2)))))))))

;Restituisce la moltiplicazione ta due polinomi
(defun polytimes (poly1 poly2)
  (if (null (monomials poly1))
      (list 'poly nil)
    (append 
     (list 'poly) 
     (list (sort-monomials
            (clean-monomials
             (simplify-monomials
              (sort-monos 
               (straknapk (monomials poly1) (monomials poly2))))))))))

;Trasforma un monomio in forma (m coeff td vars)
(defun as-monomial (expression)
  (cond 
    ((and (listp expression) (eq '* (first expression))) 
     (if (eql 0 (second expression)) 
         (list 'm 0 0 nil)
       (let ((coeff (get-coeff (second expression))))
            (if (eql coeff (second expression)) 
                (let ((vars (clean-vars 
                             (simplify-vars 
                              (sort-vars 
                               (create-vars (nthcdr 2 expression)))))))
                  (let ((td (get-td vars))) (list 'm (eval coeff) td vars)))
              (let ((vars (clean-vars 
                           (simplify-vars 
                            (sort-vars 
                             (create-vars (nthcdr 1 expression))))))) 
                (let ((td (get-td vars))) (list 'm (eval coeff) td vars)))))))
    
    ((and (listp expression)
          (eq 'expt (first expression))) (as-monomial (append 
                                                       (list '*) 
                                                       (list expression))))

    ((and (listp expression) 
          (numberp (first expression))) (list 'm (first expression) 0 nil))

    ((and (listp expression) 
          (eq 'm (first expression))) expression)

    ((and (listp expression)
          (not (eq '+ (first expression)))
          (fboundp (first expression))) (list 'm expression 0 nil))

    ((and (not (listp expression)) 
          (numberp expression)) (list 'm expression 0 nil))

    ((and (not (listp expression)) 
          (not (numberp expression))) 
     (let ((vars (clean-vars 
                  (simplify-vars 
                   (sort-vars (create-vars (list expression))))))) 
       (let ((td (get-td vars))) (list 'm 1 td vars))))
    (t (error "Deve passare un monomio"))))

;Trasforma un polinomio in forma (poly ((lista di monomi)))
(defun as-polynomial (expression)
  (cond
   ((and (listp expression) (eq '+ (first expression)))
    (if (eql 0 (second expression))
        (list 'poly '())
     (let ((monos (sort-monomials 
                   (clean-monomials 
                    (simplify-monomials 
                     (sort-monos 
                      (clean-monomials 
                       (create-monos (nthcdr 1 expression)))))))))
       (list 'poly monos))))
   ((and (listp expression) (eq '* (first expression)))
    (list 'poly (clean-monomials (list (as-monomial expression)))))
  ((and (listp expression) (eq 'm (first expression)))
    (list 'poly (clean-monomials (list expression))))
  ((not(listp expression)) (list 'poly (clean-monomials (list (as-monomial expression)))))
  (t (error "Deve passare un polinomio"))))

;Restituisce il valore di un polinomio
(defun polyval (polynomial variablesvalue)
  (if (<= (length (variables polynomial)) (length variablesvalue))
      (monosval (monomials polynomial) 
                (createvarlist (variables polynomial) variablesvalue))
    (error "Aumentare i valori delle variabili")))

;Stampa il polinomio come espressione
(defun pprint-polynomial (polynomial) 
  (if (is-polynomial polynomial)
      (format t "~A" (print-monomials (monomials polynomial)))
    (pprint-polynomial (as-polynomial polynomial))))

;Restituisce il grado di una variabile di una vapowers
(defun varpower-power (vp) 
  (second vp))

;Restituisce il simbolo di una variabile di una varpowers
(defun varpower-symbol (vp)
  (third vp))

;Restituisce la lista dei monomi di un polinomio parsato
(defun poly-monomials (p)
  (second p))

;Crea la lista dei coefficienti presi da una lista di monomi
(defun extract-coeff (monomios)
  (if (null monomios)
      ()
    (append 
     (list (second (first monomios))) 
     (extract-coeff (rest monomios)))))

;Restituisce la moltiplicazione tra due liste di monomi
(defun straknapk (monos1 monos2)
  (if (or (null monos1) (null monos2))
      ()
    (append 
     (multiply-monos (first monos1) monos2) 
     (straknapk (rest monos1) monos2))))

;Restituisce la moltiplicazione tra un monomio e una lista di monomi
(defun multiply-monos (mono1 monos2)
  (if (null monos2)
      () 
    (append 
     (list 
      (list 'm 
            (* (second mono1) (second (first monos2))) 
            (+ (third mono1) (third (first monos2))) 
            (clean-vars 
             (simplify-vars 
              (sort-vars (copy-list (append 
                                     (fourth mono1) 
                                     (fourth (first monos2)))))))))
     (multiply-monos mono1 (rest monos2)))))

;Restituisce una lista che alterna i simboli di variabile al loro valore 
(defun createvarlist (var varvalue)
  (if (null var)
      ()
    (append 
     (append (list (first var)) 
             (list(first varvalue))) 
     (createvarlist (rest var) (rest varvalue)))))

;Restituisce il valore numerico della somma tra i valori dei singoli monomi
(defun monosval (monos varsvalue)
  (if (null monos)
      0
    (+ (monoval (first monos) varsvalue) 
       (monosval (rest monos) varsvalue))))

;Restituisce il valore numerico di un monomio
(defun monoval (mono varsvalue) 
  (if (null varsvalue)
      (second mono) 
    (* (second mono) 
       (varsval (fourth mono) varsvalue))))

;Restituisce il valore numerico della moltiplicazione tra i valori delle 
;variabili di un monomio
(defun varsval (monovars varsvalue)
  (if (null monovars)
      1
    (* (varval (first monovars) varsvalue) 
       (varsval (rest monovars) varsvalue))))

;Restituisce il valore numerico di una variabile di un monomio
(defun varval (monovar varsvalue)
  (if (null varsvalue)
      1
    (if (eq (third monovar) (first varsvalue))
        (expt (second varsvalue) (second monovar))
      (varval monovar (nthcdr 2 varsvalue)))))

;Restituisce una stringa contenente i monomi 
(defun print-monomials (monos)
  (if (null monos)
      ()
    (concatenate 'string 
                 (print-mono (first monos))
                 (print-monomials (rest monos)))))

;Restituisce una stringa contenente un monomio
(defun print-mono (monomial)
  (if (eq (second monomial) 1)
      (concatenate 'string 
                   "+ " 
                   (print-vars (fourth monomial)))
    (if (null (fourth monomial))
        (if (> (second monomial) 0)
            (concatenate 'string
                         "+ " 
                         (write-to-string (second monomial))
                         " ")
          (concatenate 'string 
                       (write-to-string (second monomial))
                       " "))
      (if (> (second monomial) 0)
          (concatenate 'string
                       "+ " 
                       (write-to-string (second monomial))
                       " * "
                       (print-vars (fourth monomial))) 
        (concatenate 'string 
                     (write-to-string (second monomial))
                     " * "
                     (print-vars (fourth monomial)))))))

;Restituisce una stringa contenente tutte le variabili di un monomio
(defun print-vars (vars)
  (if (null vars)
      ()
    (concatenate 'string 
                 (print-var (first vars))
                 (if (null (rest vars))
                     ()
                   "* ")
                 (print-vars (rest vars)))))

;Restituisce una stringa contenente una variabile di un monomio
(defun print-var (var)
  (if (eq (second var) 1)
      (concatenate 'string 
                   (write-to-string (third var))
                   " ")
    (concatenate 'string 
                 (write-to-string (third var)) 
                 "^" 
                 (write-to-string (second var))
                 " ")))
  
;Cambia il segno di tutti i coefficienti di una lista di monomi
(defun change-sign (monos)
  (if (null monos)
      ()
    (append (list (list 'm 
                        (- (second (first monos))) 
                        (third (first monos)) 
                        (fourth (first monos)))) 
            (change-sign (rest monos)))))

;Restituisce la lista di tutti gli esponenti delle variabili di una lista 
;di monomi
(defun extract-degree (monos)
  (if (null monos)
      ()
    (append (list (third (first monos))) 
            (extract-degree (rest monos)))))

;Restituisce la lista di tutti gli esponenti delle variabili di un monomio
(defun degree-of (varlist)
  (if (null varlist)
       ()
     (append (list (second (first varlist))) 
             (degree-of (rest varlist)))))

;Restituisce la lista di tutte le variabili di una lista di monomi 
;(senza duplicati)
(defun extract-vars (monos)
  (if (null monos)
      ()
    (remove-duplicates (append (vars-of (first monos)) 
                               (extract-vars (rest monos))))))

;Restituisce il coefficiente di un monomio
(defun get-coeff (coeff)
  (cond
    ((numberp coeff) coeff)
    ((and (listp coeff) 
          (not (eq 'expt (first coeff))) 
          (fboundp (first coeff))) coeff)
    (t 1)))

;Restituisce la lista di variabili di un monomio
(defun get-vars (vars)
   (if (null vars)
       ()
     (append (list (third (first vars))) 
             (get-vars (rest vars)))))

;Restituisci la lista di variabili in forma di varpowers
(defun create-vars (vars)
  (if (null vars) 
      ()
    (if (listp (first vars))
        (append (list (list 'v (third (first vars)) (second (first vars)))) 
                (create-vars (rest vars))) 
      (append (list (list 'v 1 (first vars))) (create-vars (rest vars))))))

;Restituisce la lista delle variabili senza variabili con esponente 0
(defun clean-vars (vars)
  (if (null vars)
      ()
    (if (eql 0 (second (first vars)))
        (append (clean-vars (rest vars)))
      (append (list (first vars)) (clean-vars (rest vars))))))

;Restituisce la lista delle variabili semplificando quelle con base uguale 
(defun simplify-vars (vars)
  (if (null vars)
      ()
    (if (eql (third (first vars)) (third (second vars)))
       (simplify-vars (append (list (list 'v 
                                          (+ (second (first vars)) 
                                             (second (second vars))) 
                                          (third (first vars)))) 
                              (nthcdr 2 vars)))
      (append (list (first vars)) (simplify-vars (rest vars))))))

;Restituisce le variabili in ordine lessicografico
(defun sort-vars (vars)
  (sort vars
        #'string-lessp
        :key #'third))

;Restituisce una lista di monomi in ordine crescente secondo il TD 
;(total degree)
(defun sort-monomials (monos)
  (sort monos #'< :key #'third))

;Calcola il total degree di un monomio
(defun get-td (vars)
  (if (null vars) 
      0 
    (+ (second (first vars)) (get-td (cdr vars)))))

;Elimina i monomi con coefficiente zero (in una lista di monomi)
(defun clean-monomials (monos)
  (if (null monos)
      ()
    (if (eql 0 (second (first monos)))
        (clean-monomials (rest monos))
      (append (list (first monos)) (clean-monomials (rest monos))))))

;Restituisce la somma tra monomi con variabili uguali        
(defun simplify-monomials (monos)
  (cond 
   ((null monos) ())
   ((null (second monos)) (list (first monos)))
   (T (if (equal (fourth (first monos)) (fourth (second monos)))
        (simplify-monomials (append (list (list 'm 
                                                (+ (second (first monos)) 
                                                   (second (second monos))) 
                                                (third (first monos)) 
                                                (fourth (first monos)))) 
                                    (nthcdr 2 monos)))
      (append (list (first monos)) 
              (simplify-monomials (nthcdr 1 monos)))))))

;Restituisce la lista di monomi parsati
(defun create-monos (monos)
  (if (null monos)
      ()
    (append (list (as-monomial (first monos))) 
            (create-monos (rest monos)))))

;Restituisce i monomi in ordine
(defun sort-monos (monos)
  (sort monos #'string-lessp :key #'mono-string))

(defun mono-string (mono)
  (var-string (fourth mono)))

;Converte una variabile in forma BASEESPONENTE
(defun var-string (s)
  (cond ((null s)
         "")
        (t
         (concatenate 'string
                      (concatenate 'string 
                                   (princ-to-string (third (first s)))
                                   (princ-to-string (second (first s))))
                      (var-string (rest s))))))