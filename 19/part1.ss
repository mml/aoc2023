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
;;; ⟨workflow⟩  ::= ⟨name⟩ { (⟨rule⟩,)* ⟨rule⟩ }
;;; ⟨name⟩      ::= [a-z]+
;;; ⟨rule⟩      ::= A
;;;               | R
;;;               | ⟨attr⟩ [><] ⟨posint⟩
;;; ⟨partspec⟩  ::= {(⟨attr⟩=⟨posint⟩,)*⟨attr⟩=⟨posint⟩}
;;; ⟨attr⟩      ::= x | m | a | s
;;; ⟨posint⟩    ::= [1-9][0-9]*

(define tot 0)
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

(define (Eval-rule r alist)
  (match r
    [(Less ,field ,x ,conseq)
      (if (< (cdr (assq field alist)) x)
        conseq
        #f)]
    [(Greater ,field ,x ,conseq)
      (if (> (cdr (assq field alist)) x)
        conseq
        #f)]))

(define (Eval-conseq c alist)
  (match c
    [(Goto ,sym) (Eval-workflow (hashtable-ref labels sym #f) alist)]
    [Accept (accept alist)]
    [Reject (reject alist)]))

(define (Eval-workflow w alist)
  (match w
    [(rules () ,otherwise) (Eval-conseq otherwise alist)]
    [(rules (,r ,r* ...) ,otherwise)
     (let ([result (Eval-rule r alist)])
       (if result (Eval-conseq result alist)
         (Eval-workflow `(rules ,r* ,otherwise) alist)))]))

(define (Eval-part alist)
  (Eval-workflow (hashtable-ref labels 'in #f) alist))

(define (Eval expr)
  (match expr
    [(workflow ,name ,val) (hashtable-set! labels name val)]
    [(blank) (void)]
    [(partspec ,alist) (Eval-part alist)]))
(let loop ()
  (let ([l (get-line (current-input-port))])
    (cond
      [(eof-object? l) #t]
      [else
        (let ([parsed (Line (string->list l))])
          (printf "~a~n" parsed)
          (Eval parsed))
        (loop)])))
(printf "~n~a~n" tot)
