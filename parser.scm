;; +-----------------------------------------------------------------+
;; | Boring parsing garbage. It's a mess :/                          |
;; +-----------------------------------------------------------------+
(load "pmatch.scm")

;; Counts consecutive occurrences of sym in input
(define count-symbol
  (lambda (input sym)
    (cond
      [(null? input) (values input 0)]
      [(eq? sym (car input))
        (let-values (((cdrput count) (count-symbol (cdr input) sym)))
          (values cdrput (add1 count)))]
      [else (values input 0)])))

;; Reads a file in as a string (actually a list of chars).
(define parse-file-as-string
  (lambda (file)
    (with-input-from-file file
      (lambda ()
        (let f ((x (read-char)))
          (cond
            [(eof-object? x) '()]
            [(char=? x #\*) (f (read-char))]
            [(char=? x #\|) '()]
            [else (cons x (f (read-char)))]))))))

;; Splits a list on an element of the list
(define split-on
  (lambda (x ls)
    (define next-occurence
      (lambda (x ls)
        (define find-index
          (lambda (x ls index)
            (cond
              [(null? ls) #f]
              [(eq? (car ls) x) index]
              [else (find-index x (cdr ls) (add1 index))])))
        (find-index x ls 0)))
      (cond
        [(null? ls) '()]
        [else
         (let ((index (next-occurence x ls)))
           (if index
               (cons
                 (list-head ls index) 
                 (split-on x (cdr (list-tail ls index))))
               (list ls)))])))

;; Removes any symbols in symbols from the end of ls until there
;; are no more left. Could be written more efficiently, but I am
;; the laziest.
(define remove-trailing-symbols
  (lambda (ls symbols)
    (reverse (remove-leading-symbols (reverse ls) symbols))))

;; Removes any symbols from the symbols argument list from the
;; front of the list, stopping when a non-matching symbol is
;; encountered... That sentence kind of got away from me.
(define remove-leading-symbols
  (lambda (ls symbols)
    (cond
      [(null? ls) '()]
      [(memq (car ls) symbols) (remove-leading-symbols (cdr ls) symbols)]
      [else ls])))

;; Trims spaces and newlines from the beginning and end of the
;; input, a la perl's trim. (It's a nice tool to have around.)
(define trim
  (lambda (ls)
    (remove-leading-symbols 
      (remove-trailing-symbols ls '(#\space #\newline)) 
      '(#\space #\newline))))

;; Reads from a file, splits it on newlines, trims it, then
;; converts the 'strings' into symbols in the appropriate
;; places via the magix (the 'x' is important) of symbolize
(define read-from-file
  (lambda (file)
    (let ((input (parse-file-as-string file)))
      (map symbolize (map trim (split-on #\newline input))))))

;; It's... it's... I'm so sorry.
(define symbolize
  (lambda (input)
    (cond
      [(null? input) '()]
      [(char=? (car input) #\space) (symbolize (cdr input))]
      [(char=? (car input) #\() (symbolize (cdr input))]
      [(char=? (car input) #\)) (symbolize (cdr input))]
      [(char=? (car input) #\+) (cons '+ (symbolize (cdr input)))]
      [(char=? (car input) #\%) (cons '% (symbolize (cdr input)))]
      [(char=? (car input) #\$) (cons '$ (symbolize (cdr input)))]
      [(char=? (car input) #\@) (cons '@ (symbolize (cdr input)))]
      [(char=? (car input) #\0) (cons 0 (symbolize (cdr input)))]
      [else 
        (error 
          'read-file 
          "Invalid file format with character ~s~n" 
          (car input))]))) 

;; Takes symbolized input and turns it into something 
;; I actually want to write an interpreter for.

(define app-splitter
  (lambda (ls stack1 stack2)
    (cond
      [(null? ls) (cons stack1 stack2)]
      [(eq? (car ls) '+) (app-splitter (cdr ls) (cons '+ stack1) stack2)]
      [(eq? (car ls) '0) (app-splitter (cdr ls) (cons 0 stack1)  stack2)]
      [(eq? (car ls) '$) (app-splitter (cdr ls) (cons '$ stack1) stack2)]
      [(eq? (car ls) '%) (app-splitter (cdr ls) '() (cons stack1 stack2))]
      [(and (eq? (car ls) '@) (null? stack1)) 
       (app-splitter 
         (cdr ls) 
         '() 
         (cons 'app stack2))]
      [(eq? (car ls) '@)
       (app-splitter 
         (cdr ls) 
         '() 
         (cons 'app (cons stack1 stack2)))])))

(define app-builder
  (lambda (ls stack)
    (cond
      [(null? ls) stack]
      [(eq? (car ls) 'app)
        (app-builder 
          (cdr ls) 
          `((app ,(car stack) ,(cadr stack)) . ,(cddr stack)))]
      [else (app-builder (cdr ls) (cons (car ls) stack))])))

(define app-parser
  (lambda (ls)
    (if (null? ls) '()
      (let ((stack (app-splitter ls '() '())))
        (app-builder stack '())))))

(define parse-sym
  (lambda (input)
    (pmatch input
      [() '()]
      [($ . ,rest) `(var-ref ,(sub1 (length input)))]
      [(+ . ,rest) `(line-ref ,(sub1 (length input)))]
      [(0) '(line-ref this)]
      [(app ,e1 ,e2) `(app ,(parse-sym e1) ,(parse-sym e2))]
      [,x (list? x) `(lambda ,(parse-sym (car x)))])))

(trace-define parse
  (lambda (input)
    (map parse-sym (map app-parser input))))

;; Instead of 'relative' addressing using the 0 op,
;; we instate an absolute address for self-reference.
(define remove-this
  (lambda (ls n)
    (pmatch ls
      [(line-ref this) `(line-ref ,n)]
      [(,a . ,d) `(,(remove-this a n) . ,(remove-this d n))]
      [else ls])))

(define remove-these
  (lambda (input)
    (let ((n (length input)))
      (map remove-this input (iota n)))))
