;; +-----------------------------------------------------------------+
;; |                            TANNENBAUM                           |
;; +-----------------------------------------------------------------+
;; |                   The Christmas Tree Language.                  |
;; |                     Cameron & Rebecca Swords                    |
;; +-----------------------------------------------------------------+

(load "pmatch.scm")
(load "parser.scm")

;;  $ -> (lexical-var 0)
;; $$ -> (lexical-var 1)
;;  ( -> lambda
;;  ) -> close lambda
;;  @ -> application 
;;  % -> spacing 
;;  0 -> 'this line'
;;  * -> start program
;;  | -> end program
;;  + -> line reference to line 1
;; ++ -> line reference to line 2

(define exec
  (lambda (input)
    (let ((i (remove-these input)))
      ((valof i) (cadar (reverse i)) '()))))

;; Good ol' Dan Friedman-style interpreter. The closures
;; are data structures simply for debugging and more
;; readable return values than you'd otherwise get.
;;
;; The only 'trickery' here is as follows: lenv gets bound
;; and, since it never changes, we avoid passing it around
;; by getting it into ee's closure and then handing back
;; ee itself (which knows about lenv during interpretation
;; without us having to hand it around, using stack space
;; unnecessarily for something that never changes).
(define valof
  (lambda (lenv)
    (letrec ((ee 
               (lambda (exp env)
                 (pmatch exp
                   [(var-ref ,n) (list-ref env n)]
                   [(line-ref ,n) (ee (list-ref lenv n) env)]
                   [(lambda ,body) `(closure ,body ,env)]
                   [(app ,e1 ,e2) (apply-proc (ee e1 env) (ee e2 env))])))
             (apply-proc
               (lambda (p a)
                 (pmatch p
                   [(closure ,body ,env)
                    (ee body (cons a env))]))))
      ee)))

;; Completely functional implementation of the interpreter.
;;
;;  [(var-ref ,n) (list-ref env n)]
;;  [(line-ref ,n) (ee (list-ref lenv n) env)]
;;  [(lambda ,body) (lambda (a) (ee body (cons a env)))]
;;  [(app ,e1 ,e2) ((ee e1 env) (ee e2 env))]))))

;; Takes a filename, parses it in all of that ugliness,
;; and then runs the interpreter on it.
(define run
  (lambda (filename)
    (let* ((input (read-from-file filename))
           (input (parse input))
           (inlen (length input))
           (input (cdr (list-head input (sub1 inlen)))))
      (exec input))))
