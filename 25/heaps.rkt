#!/usr/bin/env racket
#lang racket
(provide (all-defined-out))

; binheap implementation as a max-heap since that's what the problem I'm
; working on needs.

(require (only-in rnrs/base-6 div))
(require racket/trace)

(define (make-binheap size)
  (let ([v (make-vector (add1 size))])
    (binheap-set-end! v 1)
    v))
(define (binheap-end h)
  (vector-ref h 0))
(define (binheap-set-end! h end)
  (vector-set! h 0 end))

(define (binheap-empty? h)
  (= 1 (binheap-end h)))
(define (binheap-parent i)
  (div i 2))
(define (binheap-child0 i)
  (* 2 i))
(define (binheap-child1 i)
  (add1 (* 2 i)))

(define (make-ent elt key)
  (mcons elt key))
(define ent-key mcdr)
(define ent-elt mcar)
(define ent-key-set! set-mcdr!)
(define (ent-< a b)
  (< (ent-key a)
     (ent-key b)))
(define (ent-> a b)
  (> (ent-key a)
     (ent-key b)))
(define (binheap-valid-index? h i)
  (and (positive? i)
       (< i (binheap-end h))))
(define (binheap-< h i j)
  (and (binheap-valid-index? h i)
       (binheap-valid-index? h j)
       (ent-< (vector-ref h i)
              (vector-ref h j))))
(define (binheap-> h i j)
  (and (binheap-valid-index? h i)
       (binheap-valid-index? h j)
       (ent-> (vector-ref h i)
              (vector-ref h j))))
(define (binheap-swap! h i j)
  (let ([ci (vector-ref h i)]
        [cj (vector-ref h j)])
    (vector-set! h i cj)
    (vector-set! h j ci)))

(define (binheap-children? h i)
  (or (binheap-valid-index? h (binheap-child0 i))
      (binheap-valid-index? h (binheap-child1 i))))

(define (binheap-max-child h i)
  (let ([j0 (binheap-child0 i)]
        [j1 (binheap-child1 i)])
    (cond
      [(and (binheap-valid-index? h j0)
            (binheap-valid-index? h j1))
       (if (binheap-> h j0 j1)
         j0
         j1)]
      [(binheap-valid-index? h j0) j0]
      [else j1])))

(define (binheap-correct-order? h i)
  (and
    (not (binheap-< h i (binheap-child0 i)))
    (not (binheap-< h i (binheap-child1 i)))))

(define (binheap-insert! h e k)
  (let ([i (binheap-end h)])
    (vector-set! h i (make-ent e k))
    (binheap-set-end! h (add1 i))
    (binheap-swim-up! h i)))

(define (binheap-swim-up! h i)
  (let ([j (binheap-parent i)])
    (cond
      [(binheap-< h j i)
       (binheap-swap! h j i)
       (binheap-swim-up! h j)]
      [else h])))

(define (sorted-children h i)
  (let* ([end (binheap-end h)]
         [jc* (map
                (lambda (j) (cons j (vector-ref h j)))
                (filter (lambda (j) (<= j end))
                        (list (binheap-child0 i) (binheap-child1 i))))])
    (let loop ([jc* jc*] [vj '()] [vc '()])
      (if (null? jc*) (values vj vc)
        (let ([max-jc (argmax cdr jc*)])
          (loop (cdr jc*) (cons (car max-jc) vj) (cons (cdr max-jc) vc)))))))

(define (binheap-sink-down! h i)
  (cond
    [(binheap-correct-order? h i) h]
    [else
      (let ([j (binheap-max-child h i)])
        (binheap-swap! h i j)
        (binheap-sink-down! h j))]))

(define (binheap-extract! h)
  (let* ([root (vector-ref h 1)]
         [last (sub1 (binheap-end h))]
         [e (vector-ref h last)])
    (vector-set! h 1 e)
    (vector-set! h last #f)
    (binheap-set-end! h last)
    (binheap-sink-down! h 1)
    (ent-elt root)))

(define (binheap-increase-key! h i dk)
  (let ([e (vector-ref h i)])
    (ent-key-set! e (+ dk (ent-key e)))
    (binheap-swim-up! h i)))

(define (binheap-indices h)
  (let loop ([l '()] [i (sub1 (binheap-end h))])
    (if (zero? i) l
      (loop (cons i l) (sub1 i)))))

(define (binheap-elt h i)
  (ent-elt (vector-ref h i)))

(define (make-test-heap)
  (let ([h (make-binheap 100)])
    (binheap-insert! h 'h 2)
    (binheap-insert! h 'f 7)
    (binheap-insert! h 'g 3)
    (binheap-insert! h 'a 100)
    (binheap-insert! h 'd 19)
    (binheap-insert! h 'e 17)
    (binheap-insert! h 'b 36)
    (binheap-insert! h 'c 25)
    (binheap-insert! h 'i 1)
    h))

#;(let loop ([h (make-test-heap)])
  (printf "~a~n" h)
  (cond
    [(binheap-empty? h) (void)]
    [else
      (printf "~a~n" (binheap-extract! h))
      (printf "---~n")
      (loop h)]))
