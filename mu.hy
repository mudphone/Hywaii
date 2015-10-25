(import [pyrsistent [pmap :as pmap
                     pset :as pset]]
        [types])

;; This is my attempt at implementing μKanren in Hy.
;; All credit for μKanren to Jason Hemann and Daniel P. Friedman:
;; http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf

;; Much appreciation to Bodil Stokke for explaining things clearly:
;; μKanren: Running the Little Things Backwards
;; EuroClojure, Barcelona, Spain, 25 June 2015.
;; https://www.youtube.com/watch?v=2e8VFSSNORg

(defn list? [x]
  "Checks if this is a normal list"
  (instance? list x))

(defn seq? [x]
  "Checks for non-empty list"
  (and (list? x)
       (not (empty? x))))

(defn null? [c]
  (or (nil? c)
      (and (list? c)
           (empty? c))))

(defn pair? [c]
  (or (seq? c)
      (cons? c)))

(defn fn? [f]
  "Tests for a function"
  (instance? types.FunctionType f))


;; Variables "are represented as vectors that hold their variable index."
(defn var [c]
  "Creates a logic variable"
  (pset [c]))

(defn var? [x]
  "Test if is logic var"
  (instance? (type (var 0)) x))

;; State
(defn stor [&optional [m {}]]
  (pmap m))

(defn stor-get [s k]
  (.get s k))

(defn stor-contains? [s k]
  (.__contains__ s k))

(defn stor-assoc [s k v]
  "Associates key with value in a given state map, returning updated
   map"
  (.set s k v))

(def empty-s (stor))
(def empty-state [empty-s 0])


;; walk
;;
;; (walk 1337 (pmap {}))
;; => 1337
;;
;; (walk (var 0) (pmap {}))
;; => pset([0])
;;
;; (walk (var 0) (pmap {(var 0) 1337}))
;; => 1337
;;
;; (walk (var 1) (pmap {(var 0) 1337 (var 1) (var 0)}))
;; => 1337
;;
(defn walk [u s]
  "Recursive lookup of logic var keys in a state map"
  (if (and (var? u) (stor-contains? s u))
    (walk (stor-get s u) s)
    u))

;; unify
;;
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
;; (unify [1 2 3] [1 2 (var 0)] (pmap {}))
;; => pmap({pset([0]): 3})
;;
(defn unify [u1 v1 s1]
  "Unifies terms of the language by walking the state map for instances
   of logic variables

   - If two terms walk to the same variable the state map is returned.
   - When one of the terms walks to a variable, the state is extended.
   - If both walk to non-empty lists, the cars and then cdrs are are 
     unified recursively.
   - Non-variable, non-seqs unify if they are equal.
   - Otherwise unification fails and returns False."
  (let [u (walk u1 s1)
        v (walk v1 s1)
        s s1]
    (cond
     [(and (var? u) (var? v) (= u v)) s]

     [(var? u) (stor-assoc s u v)]
     [(var? v) (stor-assoc s v u)]

     [(and (pair? u) (pair? v))
      (let [s2 (unify (car u) (car v) s)]
        (and (coll? s2)
             (unify (cdr u) (cdr v) s2)))]
     
     [True (and (= u v) s)])))

;; empty result
(def mzero nil)

(defn unit [sc]
  "Lifts state into a stream"
  (cons sc mzero))

;; ==
;;
;; ((== 1 1) empty-state)
;; => ([pmap({}) 0])
;;
;; ((== 1 2) empty-state)
;; => nil
;;
(defn == [u v]
  "Takes two terms as args and returns a goal"
  (fn [[s c]]
    (let [s1 (unify u v s)]
      (if (coll? s1) (unit [s1 c]) mzero))))

;; ((callfresh (fn [q] (== q 5))) empty-state)
;; => ([pmap({pset([0]): 5}), 1])
;;
(defn callfresh [f]
  "Take a fn f with a goal body and returns a fn takes a state and
   applies the f to a newly created logic variable"
  (fn [[s c]]
    ((f (var c)) [s (inc c)])))


;; "or" and "and" | "and" and "or"

;; (mplus [1 2] [3 4])
;; => (1 2 3 . 4)
;;
(defn mplus [$1 $2]
  "Merges streams and applies some trampolining to avoid the depth
   first search that would be unfun for infinite streams"
  (cond
   [(null? $1) $2]

   [(fn? $1) (fn [] (mplus ($1) $2))]
   
   [True (cons (car $1) (mplus $2 (cdr $1)))]))

(defn bind [$ g]
  "Invokes a goal on each element of a stream and then either
   merges the results, or if results exhausted returns the empty
   stream"
  (cond
   [(null? $) mzero]
   
   [(fn? $) (fn [] (bind ($) g))]

   [True (mplus (g (car $)) (bind (cdr $) g))]))

;; ((callfresh (fn [q] (disj (== q 1) (== q 2)))) empty-state)
;; => ([pmap({pset([0]): 1}), 1] [pmap({pset([0]): 2}), 1])
;;
(defn disj [g1 g2]
  "Goal constructor like a logical `or`"
  (fn [sc] (mplus (g1 sc) (g2 sc))))

;; ((callfresh (fn [q] (conj (== q 1) (== q 1)))) empty-state)
;; => ([pmap({pset([0]): 1}), 1])
;;
(defn conj [g1 g2]
  "Goal constructor like a logical `and`"
  (fn [sc] (bind (g1 sc) g2)))

;; Works the same:
;; (callgoal (callfresh (fn [q] (conj (== q 1) (== q 1)))))
;; => ([pmap({pset([0]): 1}), 1])
;;
(defn callgoal [g]
  "Helper to which applies the given goal to the empty state"
  (g empty-state))


;; (callgoal (callfresh fives))
;; => RecursionError: maximum recursion depth exceeded
;; (defn fives [x]
;;   (disj (== x 5) (fn [sc] ((fives x) sc))))

;; Wrap the return in a closure:
;; (callgoal (callfresh fives))
;; => ([pmap({pset([0]): 5}), 1] <function fives.<locals>._hy_anon_fn_2.<locals>._hy_anon_fn_1 at 0x10a967048>)
(defn fives [x]
  "An infinite goal constructor of fives"
  (disj (== x 5) (fn [sc] (fn [] ((fives x) sc)))))

(defn sixes [x]
  "An infinite goal constructor of sixes"
  (disj (== x 6) (fn [sc] (fn [] ((sixes x) sc)))))

(defn pull [$]
  "Automatically invokes an immature stream, advancing the stream
   until it matures"
  (if (fn? $) (pull ($)) $))

;; (ptake 10 (callgoal (callfresh fives)))
;; => ([pmap({pset([0]): 5}) 1] ... x10
(defn ptake [n $1]
  "Invokes pull a given number of times to return the desired number
   of results from a stream"
  (if (zero? n) []
      (let [$ (pull $1)]
        (if (null? $) []
            (cons (car $)
                  (ptake (dec n) (cdr $)))))))

;; (ptake 10 (callgoal fives-and-sixes))
;; => ([pmap({pset([0]): 5}), 1] [pmap({pset([0]): 6}), 1] ...
;;    alternating ... x5 pairs
(def fives-and-sixes (callfresh (fn [x] (disj (fives x) (sixes x)))))

;; (callgoal a-and-b)
;; => ([pmap({pset([1]): 5, pset([0]): 7}) 2] [pmap({pset([1]): 6, pset([0]): 7}) 2])
(def a-and-b
  (conj
   (callfresh (fn [a] (== a 7)))
   (callfresh (fn [b] (disj (== b 5) (== b 6))))))
