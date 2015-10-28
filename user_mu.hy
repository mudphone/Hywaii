(import [mu [*]])

(defmacro/g! zzz [g]
  "The snooze macro"
  `(fn [g!sc] (fn [] (~g g!sc))))

;; (callgoal (callfresh sevens))
;; => ([pmap({pset([0]): 7}) 1] . <function sevens.<locals>._hy_anon_fn_2.<locals>._hy_anon_fn_1 at 0x10f59abf8>)
;;
(defn sevens [x]
  "An inifinte goal constructor of sevens, using the snooze macro"
  (disj (== x 7) (zzz (sevens x))))

(defmacro conj+ [&rest gs]
  (if (= (len gs) 1)
    `(zzz ~(car gs))
    `(conj (zzz ~(car gs)) (conj+ ~@(cdr gs)))))

(defmacro disj+ [g0 &rest gs]
  (if (> (len gs) 0)
    `(disj (zzz ~g0) (disj+ ~@gs))
    `(zzz ~g0)))

;; (run* (fresh [q x y] (== [x 5 y] q) (== [x y] [4 6])))
;; => [[4, 5, 6]]
;;
;; `fresh` is like *and*
(defmacro fresh [vars &rest body]
  "Used to declare an `and` relation"
  (if (empty? vars)
    `(conj+ ~@body)
    `(callfresh
      (fn [~(car vars)]
        (fresh ~(cdr vars) ~@body)))))

(defn walk* [v1 s]
  (let [v (walk v1 s)]
    (cond
     [(var? v) v]
     
     [(pair? v)
      (cons (walk* (car v) s)
            (walk* (cdr v) s))]

     [True v])))

(defn reify-1st [[s c]]
  (walk* (var 0) s))

;; (list (map reify-1st (ptake 6 (callgoal (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5]))))))
;; => [[[], [1 2 3 4 5]], [[1], [2 3 4 5]], [[1 2], [3 4 5]], [[1 2 3], [4 5]], [[1 2 3 4], [5]], [[1 2 3 4 5], []]]
;;
;; (ptake 6 (callgoal (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5]))))
;; => [[pmap({pset([2]): [1, 2, 3, 4, 5], pset([1]): [], pset([0]): [pset([1]), pset([2])]}) 3], ... x6 states ... ]
(defn run [n g]
  (list (map reify-1st (ptake n (callgoal g)))))

;; (take-all (callgoal (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5]))))
;; => ... same as `ptake 6` ...
;;
(defn take-all [$1]
  "See also `ptake`, this consumes the entire stream"
  (let [$ (pull $1)]
    (if (null? $) [] (cons (car $) (take-all (cdr $))))))

;; (run* (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5])))
;; => [[[], [1 2 3 4 5]], [[1], [2 3 4 5]], [[1 2], [3 4 5]], [[1 2 3], [4 5]], [[1 2 3 4], [5]], [[1 2 3 4 5], []]]
;;
(defn run* [g]
  "See also `run`, this one provides all solutions"
  (list (map reify-1st (take-all (callgoal g)))))

;; (take-all (callgoal (fresh [q] (conde [(== q 5)] [(== q 6)]))))
;; => [[pmap({pset([0]): 5}) 1], [pmap({pset([0]): 6}) 1]]
;;
;; (run* (fresh [q] (conde [(== q 5)] [(== q 6)])))
;; => [5, 6]
;;
;; (run* (fresh [q x] (conde [(== q x) (== x 5)] [(== q 6)])))
;; => [5, 6]
;;
(defmacro conde [&rest gs]
  "Used to declare a series of `or` relations
   Each relation (clause) can contain one or many `and` goals"
  `(disj+ ~@(list (map (fn [l] `(conj+ ~@l)) gs))))

(defn appendo [l r out]
  (disj
   (conj (== l []) (== r out))
   (fresh [a d res]
          (== (cons a d) l)
          (== (cons a res) out)
          (appendo d r res))))

(defn appendo/e [l r out]
  "Just like `appendo`, but uses `conde`"
  (conde
   ((== [] l) (== r out))
   ((fresh [a d res]
           (== (cons a d) l)
           (== (cons a res) out)
           (appendo d r res)))))

;; (run 1 (fresh [q] (appendo [1 2] [3 4] q)))
;; => [[1, 2, 3, 4]]
;;
;; (ptake 1 (callgoal (fresh [q] (appendo [1 2] [3 4] q))))
;; => [[pmap({pset([2]): [2], pset([6]): [3, 4], pset([0]): (pset([1]) . pset([3])), pset([4]): 2, pset([1]): 1, pset([3]): (pset([4]) . pset([6])), pset([5]): []}) 7]]

;; (ptake 1 (callgoal (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5]))))
;; => [[pmap({pset([2]): [1, 2, 3, 4, 5], pset([1]): [], pset([0]): [pset([1]), pset([2])]}) 3]]
;;
;; (take-all (callgoal (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5]))))
;; => [[pmap({
;;            pset([0]): [pset([1]), pset([2])]
;;            pset([1]): [],
;;            pset([2]): [1, 2, 3, 4, 5],
;;           }) 3],
;;     [pmap({
;;            pset([0]): [pset([1]), pset([2])],
;;            pset([1]): (pset([3]) . pset([4])),
;;            pset([2]): [2, 3, 4, 5],
;;            pset([3]): 1,
;;            pset([4]): [],
;;            pset([5]): [2, 3, 4, 5]
;;           }) 6],
;;     [pmap({
;;            pset([0]): [pset([1]), pset([2])],
;;            pset([1]): (pset([3]) . pset([4])),
;;            pset([2]): [3, 4, 5],
;;            pset([3]): 1,
;;            pset([4]): (pset([6]) . pset([7])),
;;            pset([5]): [2, 3, 4, 5]
;;            pset([6]): 2,
;;            pset([7]): [],
;;            pset([8]): [3, 4, 5],
;;           }) 9],
;;     [pmap({
;;            pset([0]): [pset([1]), pset([2])],
;;            pset([1]): (pset([3]) . pset([4]))
;;            pset([2]): [4, 5],
;;            pset([3]): 1,
;;            pset([4]): (pset([6]) . pset([7])),
;;            pset([5]): [2, 3, 4, 5],
;;            pset([6]): 2,
;;            pset([7]): (pset([9]) . pset([10])),
;;            pset([8]): [3, 4, 5],
;;            pset([9]): 3,
;;            pset([10]): [],
;;            pset([11]): [4, 5],
;;           }) 12],
;;     [pmap({
;;            pset([0]): [pset([1]), pset([2])],
;;            pset([1]): (pset([3]) . pset([4]))
;;            pset([2]): [5],
;;            pset([3]): 1,
;;            pset([4]): (pset([6]) . pset([7])),
;;            pset([5]): [2, 3, 4, 5],
;;            pset([6]): 2,
;;            pset([7]): (pset([9]) . pset([10])),
;;            pset([8]): [3, 4, 5],
;;            pset([9]): 3,
;;            pset([10]): (pset([12]) . pset([13])),
;;            pset([11]): [4, 5],
;;            pset([12]): 4,
;;            pset([13]): [],
;;            pset([14]): [5],
;;           }) 15],
;;     [pmap({
;;            pset([0]): [pset([1]), pset([2])],
;;            pset([1]): (pset([3]) . pset([4]))
;;            pset([2]): [],
;;            pset([3]): 1,
;;            pset([4]): (pset([6]) . pset([7])),
;;            pset([5]): [2, 3, 4, 5],
;;            pset([6]): 2,
;;            pset([7]): (pset([9]) . pset([10])),
;;            pset([8]): [3, 4, 5],
;;            pset([9]): 3,
;;            pset([10]): (pset([12]) . pset([13])),
;;            pset([11]): [4, 5],
;;            pset([12]): 4,
;;            pset([13]): (pset([15]) . pset([16])),
;;            pset([14]): [5],
;;            pset([15]): 5,
;;            pset([16]): [],
;;            pset([17]): [],
;;           }) 18]]


;; (run 6 (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5])))
;; (run* (fresh [q a b] (== q [a b]) (appendo a b [1 2 3 4 5])))
;; => [[[], [1 2 3 4 5]], [[1], [2 3 4 5]], [[1 2], [3 4 5]], [[1 2 3], [4 5]], [[1 2 3 4], [5]], [[1 2 3 4 5], []]]


;; ground-appendo
;; SCHEME:
;; (test-check "ground appendo"
;;   (car ((ground-appendo empty-state)))
;;   '(((#(2) b) (#(1)) (#(0) . a)) . 3))
;;
;; (def ground-appendo (appendo ['a] ['b] ['a 'b]))
;; (take-all (callgoal ground-appendo))
;; => [[pmap({pset([2]): ['b'], pset([1]): [], pset([0]): 'a'}) 3]]
