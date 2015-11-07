(import [user-mu [*]])
(require user-mu)

;; Mostly translated from Scheme examples in "The Reasoned Schemer,"
;; by Daniel P. Friedman, William E. Byrd, and Oleg Kiselyov.

(defn caro [p a]
  (fresh [d]
         (== (cons a d) p)))

(defn cdro [p d]
  (fresh [a]
         (== (cons a d) p)))

(defn conso [a d p]
  (== (cons a d) p))

(defn nullo [x]
  (== [] x))


;; (run 1 (fresh [q] (appendo/l [1 2] [3 4] q)))
;; => [[1, 2, 3, 4]]
;;
;; (ptake 1 (callgoal (fresh [q] (appendo/l [1 2] [3 4] q))))
;; => [[pmap({pset([2]): [2], pset([6]): [3, 4], pset([0]): (pset([1]) . pset([3])), pset([4]): 2, pset([1]): 1, pset([3]): (pset([4]) . pset([6])), pset([5]): []}) 7]]
;;
;; (run 6 (fresh [q a b] (== q [a b]) (appendo/l a b [1 2 3 4 5])))
;; (run* (fresh [q a b] (== q [a b]) (appendo/l a b [1 2 3 4 5])))
;; => [[[], [1 2 3 4 5]], [[1], [2 3 4 5]], [[1 2], [3 4 5]], [[1 2 3], [4 5]], [[1 2 3 4], [5]], [[1 2 3 4 5], []]]
;;
(defn appendo/l [l r out]
  "Just like `appendo`, but uses logic fns (conde, nullo, conso)"
  (conde
   ((nullo l) (== r out))
   ((fresh [a d res]
           (conso a d l)
           (conso a res out)
           (appendo/l d r res)))))

(defn pairo [p]
  (fresh [a d]
         (conso a d p)))

(defn unwrapo [x out]
  (conde
   [(== x out)]
   [(pairo x) (fresh [a]
                     (caro x a)
                     (unwrapo a out))]))

