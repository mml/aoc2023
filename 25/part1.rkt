#!/usr/bin/env racket
#lang racket
;(require racket/set)
(require racket/trace)
(require graph)
(require "heaps.rkt")

(define (read-graph)
  (let loop ([l (read-line)] [edges '()])
    (cond
      [(eof-object? l)
       (undirected-graph edges (map (lambda (edge) 1) edges))]
      [else
        (let* ([sides (string-split l ": ")]
               [lhs (string->symbol (car sides))]
               [rhs* (map string->symbol
                          (string-split (cadr sides)))])
          (loop (read-line)
                (append edges
                        (map (lambda (rhs) (list lhs rhs)) rhs*))))])))

(define (make-cut u v wgt) (cons (list u v) wgt))
(define cut-edge car)
(define cut-weight cdr)
(define (cuts-weight cuts)
  (apply + (map cut-weight cuts)))
(define (cuts-< cuts1 cuts2)
  (< (cuts-weight cuts1)
     (cuts-weight cuts2)))

(define (replace-edges-w! g u v uv)
  (let loop ([neighbors (get-neighbors g u)] [cuts '()])
    (if (null? neighbors) cuts
      (let ([w (car neighbors)])
        (cond
          [(or (eq? u w) (eq? v w)) (loop (cdr neighbors) cuts)]
          [else
            (let ([w0 (edge-weight g w u)])
              (remove-edge! g w u)
              (let ([w1 (edge-weight g w uv #:default 0)])
                (add-edge! g w uv (+ w0 w1)))
              (loop (cdr neighbors)
                    (cons (make-cut w u w0) cuts)))])))))

(define (subset-edge-weight g A y)
  (apply +
         (map (lambda (v) (edge-weight g v y))
              (filter (lambda (v) (memq v A)) (get-neighbors g y)))))

(define (merge-vertices! g u v)
  (let ([uv (string->symbol (string-append (symbol->string u)
                                           (symbol->string v)))])
    (add-vertex! g uv)
    (replace-edges-w! g u v uv)
    (replace-edges-w! g v u uv)
    (remove-vertex! g u)
    (remove-vertex! g v)))

(define (get-cuts g v)
  (let loop ([ns (get-neighbors g v)] [cuts '()])
    (if (null? ns) cuts
      (loop (cdr ns)
            (cons (make-cut v (car ns) (edge-weight g v (car ns))) cuts)))))

(define (update-heap g h A z)
  (for-each
    (lambda (i)
      (let ([v (binheap-elt h i)])
        (binheap-increase-key!
          h i (edge-weight g v z #:default 0))))
    (binheap-indices h))
  h)

(define (make-heap size g A Z)
  (let ([h (make-binheap size)])
    (for-each (lambda (v)
                (binheap-insert! h v (subset-edge-weight g A v)))
              Z)
    h))

; https://en.wikipedia.org/wiki/Stoer%E2%80%93Wagner_algorithm
(define (minimum-cut g)
  (let ([g (graph-copy g)]
        [a (car (get-vertices g))])
    (let loop ([cuts* '()])
      (printf "|V|=~v~n" (length (get-vertices g)))
      (if (<= (length (get-vertices g)) 1) (sort cuts* cuts-<)
        (let ([cph (minimum-cut-phase g a)])
          (loop (cons cph cuts*)))))))

(define (minimum-cut-phase g a)
  (let ([A (list a)]
        [Z (remove a (get-vertices g))])
    (let loop ([A A] [Z Z] [h (make-heap (length Z) g A Z)])
      (if (null? Z)
        (let ([cuts (get-cuts g (car A))])
          (merge-vertices! g (car A) (cadr A))
          cuts)
        (let* ([z (binheap-extract! h)])
          (loop (cons z A) (remove z Z) (update-heap g h A z)))))))

(define (chunks l n)
  (if (null? l) '()
    (cons (take l n)
          (chunks (drop l n) n))))

(define (reconstruct-vertices v)
  (map string->symbol
       (map list->string
            (chunks (string->list (symbol->string v)) 3))))

(define (reconstruct-edges g u v*)
  (let loop ([v* v*])
    (if (null? v*) '()
      (let ([v (car v*)])
        (if (has-edge? g u v)
          (cons (make-cut u v (edge-weight g u v))
                (loop (cdr v*)))
          (loop (cdr v*)))))))

(define (reconstruct-cut g cut)
  (let* ([edge (cut-edge cut)]
         [u* (reconstruct-vertices (car edge))]
         [v* (reconstruct-vertices (cadr edge))])
    (apply append
           (map (lambda (u)
                  (reconstruct-edges g u v*)) u*))))

(let ([g (read-graph)])
  (let ([mc* (minimum-cut g)])
    (let ([mc (map (lambda (c) (reconstruct-cut g c)) (car mc*))])
      (let ([g (graph-copy g)])
        (for-each (lambda (edge)
                    (let ([u (car edge)]
                          [v (cadr edge)])
                      (remove-edge! g u v)))
                  (map caar mc))
        (let ([c* (cc g)])
          (printf "~v~n" (apply * (map length c*))))))))
