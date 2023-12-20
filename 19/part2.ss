#!/usr/bin/env scheme-script
; https://cisco.github.io/ChezScheme/csug9.5/csug.html
; https://cisco.github.io/ChezScheme/csug9.5/csug_1.html#./csug:h0

; https://scheme.com/tspl4/
; https://scheme.com/tspl4/tspl_1.html#./tspl:h0

(import (chezscheme))
(include "match.ss")

(define labels (make-eq-hashtable))

;;; ⟨input⟩     ::= ⟨workflow⟩* ⟨blank⟩ ⟨partspec⟩*
;;; ⟨blank⟩     ::= \n
;;; ⟨workflow⟩  ::= ⟨name⟩ { (⟨rule⟩,)* ⟨conseq⟩ }
;;; ⟨name⟩      ::= [a-z]+
;;; ⟨rule⟩      ::= ⟨attr⟩ [><] ⟨posint⟩ : ⟨conseq⟩
;;; ⟨conseq⟩    ::= A | R | ⟨name⟩
;;; ⟨partspec⟩  ::= {(⟨attr⟩=⟨posint⟩,)*⟨attr⟩=⟨posint⟩}
;;; ⟨attr⟩      ::= x | m | a | s
;;; ⟨posint⟩    ::= [1-9][0-9]*

(define (accept alist)
  (set! tot (+ tot (cdr (assq #\x alist))))
  (set! tot (+ tot (cdr (assq #\m alist))))
  (set! tot (+ tot (cdr (assq #\a alist))))
  (set! tot (+ tot (cdr (assq #\s alist))))
  (void))

(define (reject alist)
  (void))

(define (split-workflow chars)
  (let loop ([chars chars] [name '()])
    (if (null? chars)
      (error 'split-workflow "malformed")
      (if (char-alphabetic? (car chars))
        (loop (cdr chars)
              (cons (car chars) name))
        (values
          (Symbol (reverse name))
          chars)))))

(define (split l x)
  (let loop ([l l] [sublist #f] [lists '()])
    (cond
      [(null? l)
       (reverse (if sublist
         (cons (reverse sublist) lists)
         lists))]
      [(eq? x (car l))
       (loop (cdr l)
             '()
             (if sublist
               (cons (reverse sublist) lists)
               lists))]
      [else
        (loop (cdr l)
              (if sublist
                (cons (car l) sublist)
                (list (car l)))
              lists)])))

(define (Symbol l)
  (string->symbol (list->string l)))

(define (Integer l)
  (string->number (list->string l)))
(define (Line l)
  (match l
    [() '(blank)]
    [(#\{ ,x* ... #\})
     `(partspec ,(map Attrspec (split x* #\,)))]
    [,x
      (let-values ([(name chars) (split-workflow x)])
        `(workflow ,name ,(Workflow chars)))]))

(define (Attrspec l)
  (match l
    [(,c #\= ,digit* ...)
     `(,c . ,(Integer digit*))]))

(define (Workflow l)
  (match l
    [(#\{ ,c* ... #\})
     (Rule* (split c* #\,))]))

; The last "rule" is really a conseq
(define (Rule* rules)
  (let ([selur (reverse rules)])
    `(rules ,(reverse (map Rule (cdr selur)))
            ,(Conseq (car selur)))))

(define (Rule l)
  (match l
    [(#\R) `(Reject)]
    [(#\A) `(Accept)]
    [,x
      (apply Conditional (split x #\:))]))
(define (Conditional test conseq)
  (match test
    [(,field #\< ,digit* ...) `(Less ,field ,(Integer digit*) ,(Conseq conseq))]
    [(,field #\> ,digit* ...) `(Greater ,field, (Integer digit*) ,(Conseq conseq))]))

(define (Conseq l)
  (match l
    [(#\R) 'Reject]
    [(#\A) 'Accept]
    [,x `(Goto ,(Symbol x))]))


;;; The strategy for part 2 is to evaluate the same program, but over different inputs.
;;; Instead of evaluating over 4-tuples of integers, we'll use a 4-tuple of
;;; Range values, which represent a set.  The game begins by evaluating a single value:
;;; ((x . (Range 1 4000)) (m . (Range 1 4000)) (a . (Range 1 4000)) (s . (Range 1 4000)))
;;;
;;; Each rule bifurcates the evaluation.  Let's say we evaluate a rule `f <
;;; X:C,r′`, meaning if field `f` is less than `X`, we do consequent `C`.
;;; Otherwise, we do `r′`.  Let's say the input is a 4-tuple of ranges
;;; representing the values in the set S.  Then we evaluate both
;;; `C | S s.t. f < X` and `r′ | S s.t. f > X-1`
;;; Each of these "s.t." clauses can be thought of as a narrowing operation.
;;; So as long as we have primitives that take a Range and a Less or Greater
;;; rule, we can produce a new corresponding Range.
;;;
;;; Also, each set is disjoint from the other.  Meaning we can just count up
;;; the size of each subset and sum as we go.

(define (make-range lo hi)
  `(range ,lo ,hi))

(define empty-range '(range 4001 0))

(define (empty-range? r)
  (> (range-lo r)
     (range-hi r)))

(define (range-size r)
  (if (empty-range? r)
    0
    (add1 (- (range-hi r) (range-lo r)))))

(define range-lo cadr)
(define range-hi caddr)
(define (range-intersect-< range x)
  (make-range (range-lo range)
              (min (sub1 x) (range-hi range))))
(define (range-intersect-> range x)
  (make-range (max (add1 x) (range-lo range))
              (range-hi range)))
(define (range-diff-< range x)
  (make-range (max x (range-lo range))
              (range-hi range)))
(define (range-diff-> range x)
  (make-range (range-lo range)
              (min x  (range-hi range))))

(define (make-tup)
  (vector
    (make-range 1 4000)
    (make-range 1 4000)
    (make-range 1 4000)
    (make-range 1 4000)))

(define empty-tup
  (vector
    empty-range
    empty-range
    empty-range
    empty-range))

(define (empty-tup? tup)
  (and (vector? tup)
       (exists empty-range? (vector->list tup))))

(define (tup-field-index f)
  (case f
    [(#\x x) 0]
    [(#\m m) 1]
    [(#\a a) 2]
    [(#\s s) 3]))

(define (tup-with-field t f v)
  (let ([t′ (vector-copy t)])
    (vector-set! t′ (tup-field-index f) v)
    t′))

(define (tup-field t f)
  (vector-ref t (tup-field-index f)))

(define (tup-intersect-< t f x)
  (tup-with-field
    t f (range-intersect-< (tup-field t f) x)))

(define (tup-intersect-> t f x)
  (tup-with-field
    t f (range-intersect-> (tup-field t f) x)))

(define (tup-diff-< t f x)
  (tup-with-field
    t f (range-diff-< (tup-field t f) x)))

(define (tup-diff-> t f x)
  (tup-with-field
    t f (range-diff-> (tup-field t f) x)))

(define (tup-size tup)
  (fold-left * 1 (map range-size (vector->list tup))))

(define (Eval-rule r tup)
  (match r
    [(Less ,field ,x ,conseq)
     (let ([conseq-tup (tup-intersect-< tup field x)]
           [altern-tup (tup-diff-< tup field x)])
       (values
         conseq-tup
         conseq
         altern-tup))]
    [(Greater ,field ,x ,conseq)
     (let ([conseq-tup (tup-intersect-> tup field x)]
           [altern-tup (tup-diff-> tup field x)])
       (values
         conseq-tup
         conseq
         altern-tup))]))

(define (Eval-conseq c tup)
  (match c
    [(Goto ,sym) (Eval-workflow (hashtable-ref labels sym #f) tup)]
    [Accept (tup-size tup)]
    [Reject 0]))

(define (Eval-workflow w tup)
  (match w
    [(rules () ,otherwise) (Eval-conseq otherwise tup)]
    [(rules (,r ,r* ...) ,otherwise)
     (let-values ([(conseq-tup conseq altern-tup)
                   (Eval-rule r tup)])
       (+ (Eval-conseq conseq conseq-tup)
          (Eval-workflow `(rules ,r* ,otherwise) altern-tup)))]))

(define (Eval-tup tup)
  (Eval-workflow (hashtable-ref labels 'in #f) tup)
  )
(define (Eval expr)
  (match expr
    [(workflow ,name ,val) (hashtable-set! labels name val)]
    [(blank) (void)]
    [(partspec ,alist) (void)]
    [#(,x ...) (Eval-tup expr)]))

(define (main)
  (let loop ()
    (let ([l (get-line (current-input-port))])
      (cond
        [(eof-object? l) #t]
        [else
          (let ([parsed (Line (string->list l))])
            (printf "~a~n" parsed)
            (Eval parsed))
          (loop)])))
  (let ([result (Eval (make-tup))])
    (printf "~n")
    (pretty-print result)
    (printf "~n")))
(main)
