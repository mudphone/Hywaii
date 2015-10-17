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

;; Cons
(defclass Cons []
  [a nil
   d nil]
  (defn --init-- [self a &optional [d nil]]
    (if (nil? a) (raise (ValueError "Cannot store nil (list terminating) value")))
    (setv self.a a)
    (setv self.d d))
  (defn car [self] self.a)
  (defn cdr [self] self.d)
  (defn str-items [self]
    (let [items (if (nil? self.d)
                  [self.a]
                  [self.a self.d])
          s (.join " " (list
                        (map (fn [x]
                               (cond [(nil? x) "nil"]
                                     [(instance? Cons x) (.str-items x)]
                                     [True (.__str__ x)]))
                             items)))]
      s))
  (defn --repr-- [self]
    (let [items (.str-items self)]
      (.join "" ["(" items ")"])))
  (defn --eq-- [self other]
    (and (= (type self) (type other))
         (= (.car self) (.car other))
         (= (.cdr self) (.cdr other))))
  (defn --ne-- [self other]
    (not (.--eq-- self other))))

(defn ccons [a d]
  (clist a d))

(defn ccar [c]
  (.car c))

(defn ccdr [c]
  (.cdr c))

(defn to-cons-list [xs]
  "Creates a list of cons cells from a normal list"
  (cond
   [(empty? xs) nil]
   [(= (len xs) 1) (Cons (first xs))]
   [(= (len xs) 2) (Cons (first xs) (second xs))]
   [True (Cons (first xs) (to-cons-list (list (rest xs))))]))

(defn clist [&rest xs]
  "Creates a list of cons cells from given args"
  (to-cons-list (list xs)))

(defn list? [x]
  "Checks if this is a normal list"
  (instance? list x))

;; Have to check for normal lists too, because the Hy `cons`
;; creates a normal list then cons-ing something to nil.
(defn clist? [x]
  "Checks if this is a list of cons cells or a non-empty normal list"
  ;; (or 
  ;;  (cons? x)
  ;;  (and (list? x) (> (len x) 0)))
  (instance? Cons x))

(defn atom? [x]
  "Test for a atomic value, not a list, and not nil"
  (and (not (clist? x))
       (not (nil? x))))

(defn clen [c]
  (cond
   [(nil? c) 0]
   [(clist? c) (inc (clen (ccdr c)))]
   [True 1]))

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
;; (unify (clist 1 2 3) (clist 1 2 3) (pmap {}))
;; => pmap({})
;;
;; (unify (clist 1 2 3) (clist 1 2 4) (pmap {}))
;; => False
;;
;; (unify (clist 1 2 3) (clist 1 2 3 4) (pmap {}))
;; => False
;;
;; (unify (clist 1 2 3) (clist 1 2 (var 0)) (pmap {}))
;; => pmap({pset([0]): 3})
;;
(defn unify [u1 v1 s1]
  "Unifies terms of the language by walking the state map for instances
   of logic variables

   - If two terms walk to the same variable the state map is returned.
   - When one of the terms walks to a variable, the state is extended.
   - If both walk to clists, the cars and then cdrs are are unified
   recursively.
   - Non-variable, non-clists unify if they are equal.
   - Otherwise unification fails and returns False."
  (let [u (walk u1 s1)
        v (walk v1 s1)
        s s1]
    (cond
     [(and (var? u) (var? v) (= u v)) s]

     [(var? u) (stor-assoc s u v)]
     [(var? v) (stor-assoc s v u)]

     [(and (clist? u) (clist? v))
      (let [s2 (unify (ccar u) (ccar v) s)]
        (and (coll? s2)
             (unify (ccdr u) (ccdr v) s2)))]
     
     [True (and (= u v) s)])))

;; empty result
(def mzero nil)

(defn unit [sc]
  "Lifts state into a stream"
  (ccons sc mzero))

;; ==
;;
;; ((== 1 1) empty-state)
;; => ([pmap({}) 0])
;;
;; ((== 1 2) empty-state)
;; => ()
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

;; (mplus (clist 1 2) (clist 3 4))
;; => (1 2 3 . 4)
;;
(defn mplus [$1 $2]
  "Merges streams and applies some trampolining to avoid the depth
   first search that would be unfun for infinite streams"
  (cond
   [(fn? $1) (fn [] (mplus $2 ($1)))]

   [(atom? $1) (ccons $1 $2)]
   [(clist? $1)
    (ccons (ccar $1) (mplus (ccdr $1) $2))]
   
   [True $2]))

(defn bind [$ g]
  "Invokes a goal on each element of a stream and then either
   merges the results, or if results exhausted returns the empty
   stream"
  (cond
   [(fn? $) (fn [] (bind ($) g))]

   [(atom? $)
    (mplus (g $) mzero)]
   [(clist? $)
    (mplus (g (ccar $)) (bind (ccdr $) g))]

   [True mzero]))

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
  (if (zero? n) nil
      (let [$ (pull $1)]
        (if (nil? $) nil
            (ccons (ccar $)
                   (ptake (dec n) (ccdr $)))))))

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
