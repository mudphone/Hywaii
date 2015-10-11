(import [pyrsistent [pvector :as pvec
                     pmap :as pmap
                     pset :as pset]]
        [pyrsistent :as pyr])

;; This is my attempt at implementing μKanren in Hy.
;; All credit for μKanren to Jason Hemann and Daniel P. Friedman:
;; http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf

;; Much appreciation to Bodil Stokke for explaining things clearly:
;; μKanren: Running the Little Things Backwards
;; EuroClojure, Barcelona, Spain, 25 June 2015.
;; https://www.youtube.com/watch?v=2e8VFSSNORg

;; Variables "are represented as vectors that hold their variable index."
(defn var [c] (, c))

(defn var? [x]
  "Test if is var type"
  (instance? (type (var 0)) x))

;; State
(def empty-s (pmap {}))
(def empty-state [empty-s 0])


;; walk
;;
;; (walk 1337 {})
;; => 1337
;;
;; (walk (, 0) {})
;; => (0,)
;;
;; (walk (, 0) {(, 0) 1337})
;; => 1337
;;
;; (walk (, 1) {(, 0) 1337, (, 1) (, 0)})
;; => 1337
(defn walk [u s]
  (if (and (var? u) (.__contains__ s u))
    (walk (.get s u) s)
    u))

;; unify
(defn list? [x] (instance? list x))
(defn assocr [m k v]
  (.set m k v))

;; (unify 1337 1337 (pmap {}))
;; => pmap({})
;;
;; (unify 1337 1338 (pmap {}))
;; => False
;;
;; (unify [1 2 3] [1 2 3] (pmap {}))
;; => pmap({})
;;
;; (unify [1 2 3] [1 2 4] (pmap {}))
;; => False
;;
;; (unify [1 2 3] [1 2 3 4] (pmap {}))
;; => False
;;
;; (unify [1 2 3] [1 2 (, 0)] (pmap {}))
;; => pmap({(,0): 3})
;;
;;
(defn non-empty-list? [xs]
  (and (list? xs) (not (empty? xs))))

(defn unify [u1 v1 s1]
  (let [u (walk u1 s1)
        v (walk v1 s1)
        s s1]
    (cond
     [(and (var? u) (var? v) (= u v)) s]

     [(var? u) (assocr s u v)]
     [(var? v) (assocr s v u)]

     [(and (non-empty-list? u) (non-empty-list? v))
      (let [s2 (unify (first u) (first v) s)]
        (and (coll? s2)
             (unify (cdr u) (cdr v) s2)))]
     
     [True (and (= u v) s)])))

;; ==
(def mzero nil)
(defn unit [sc] (cons sc mzero))

(defn == [u v]
  (fn [[s c]]
    (let [s1 (unify u v s)]
      (if (coll? s1) (unit [s1 c]) mzero))))

;; ((== 1 1) empty-state)
;; => ([pmap({}) 0])
;;
;; ((== 1 2) empty-state)
;; => nil
;;
;; ((callfresh (fn [q] (== q 5))) empty-state)
;; => ([pmap({(0,): 5}) 1])
;;
;; 
(defn callfresh [f]
  (fn [[s c]]
    ((f (var c)) [s (inc c)])))


;; "or" and "and" | "and" and "or"
;;
(defn fn? [f]
  (instance? (type identity) f))

;; (mplus [1 2] [3 4])
;; => [1 2 3 4]
(defn mplus [$1 $2]
  (cond
   [(fn? $1) (fn [] (mplus ($1) $2))]

   [(non-empty-list? $1)
    (cons (first $1) (mplus $2 (cdr $1)))]
   
   [True $2]))

(defn bind [$ g]
  (cond
   [(fn? $) (fn [] (bind ($) g))]
   
   [(non-empty-list? $)
    (mplus (g (first $)) (bind (cdr $) g))]

   [True mzero]))

;; ((callfresh (fn [q] (disj (== q 1) (== q 2)))) empty-state)
;; => ([pmap({(0,): 1}) 1] [pmap({(0,): 2}) 1])
;;
(defn disj [g1 g2]
  (fn [sc] (mplus (g1 sc) (g2 sc))))

;; ((callfresh (fn [q] (conj (== q 1) (== q 1)))) empty-state)
;; => ([pmap({(0,): 1}) 1])
;;
(defn conj [g1 g2]
  (fn [sc] (bind (g1 sc) g2)))

;; Works the same:
;; (callgoal (callfresh (fn [q] (conj (== q 1) (== q 1)))))
;; => ([pmap({(0,): 1}) 1])
;;
(defn callgoal [g]
  (g empty-state))


;; (callgoal (callfresh fives))
;; => RecursionError: maximum recursion depth exceeded
;; (defn fives [x]
;;   (disj (== x 5) (fn [sc] ((fives x) sc))))

;; Wrap the retur in a closure:
;; (callgoal (callfresh fives))
;; => ([pmap({(0,): 5}) 1] . <function fives.<locals>._hy_anon_fn_2.<locals>._hy_anon_fn_1 at 0x1058c9048>)
(defn fives [x]
  (disj (== x 5) (fn [sc] (fn [] ((fives x) sc)))))

(defn sixes [x]
  (disj (== x 6) (fn [sc] (fn [] ((sixes x) sc)))))

(defn pull [$]
  (if (fn? $) (pull ($)) $))

;; (ptake 10 (callgoal (callfresh fives)))
;; => ([pmap({(0,): 5}) 1] ... x10
(defn ptake [n $1]
  (if (zero? n)
    nil
    (let [$ (pull $1)]
      (if (nil? $)
        nil
        (cons (first $)
              (ptake (dec n) (cdr $)))))))

(def fives-and-sixes (callfresh (fn [x] (disj (fives x) (sixes x)))))
