(import [mu [*]])

(defn seq? [x]
  (or (and (clist? x)
           (> (clen x) 0))
      (and (list? x)
           (not (empty? x)))))

;; (defmacro zzz [g]
;;   `(fn [sc#] (fn [] (~g sc#))))
(defmacro/g! zzz [g]
  "The snooze macro"
  `(fn [g!sc] (fn [] (~g g!sc))))

;; (callgoal (callfresh sevens))
;; => ([pmap({pset([0]): 7}) 1] . <function sevens.<locals>._hy_anon_fn_2.<locals>._hy_anon_fn_1 at 0x10f59abf8>)
;;
(defn sevens [x]
  "An inifinte goal constructor of sevens, using the snooze macro"
  (disj (== x 7) (zzz (sevens x))))

;; (defmacro conj+ [g0 & gs]
;;   (if (seq gs)
;;     `(conj (zzz ~g0) (conj+ ~@gs))
;;     `(zzz ~g0)))
;; (defmacro conj+ [g0 &rest gs]
;;   (if (seq? gs)
;;     `(conj (zzz ~g0) (conj+ ~@gs))
;;     `(zzz ~g0)))
(defmacro conj+ [&rest gs]
  (if (= (len gs) 1)
    `(zzz ~(car gs))
    `(conj (zzz ~(car gs)) (conj+ ~@(cdr gs)))))

;; (defmacro disj+ [g0 & gs]
;;   (if (seq gs)
;;     `(disj (zzz ~g0) (disj+ ~@gs))
;;     `(zzz ~g0)))
(defmacro disj+ [g0 &rest gs]
  (if (seq? gs)
    `(disj (zzz ~g0) (disj+ ~@gs))
    `(zzz ~g0)))

;; (defmacro fresh [vars & body]
;;   `(callfresh
;;     (fn [~(first vars)]
;;       ~(if (seq (rest vars))
;;          `(fresh ~(rest vars) (conj+ ~@body))
;;          `(conj+ ~@body)))))
;; (defmacro fresh [vars &rest body]
;;   `(callfresh
;;     (fn [~(car vars)]
;;       ~(if (seq? (cdr vars))
;;          `(fresh ~(cdr vars) (conj+ ~@body))
;;          `(conj+ ~@body)))))

;; (defmacro fresh [vars &rest body]
;;   `(callfresh
;;     (fn [~(car vars)]
;;       ~(if (seq? (cdr vars))
;;          `(fresh ~(cdr vars) (conj+ ~@body))
;;          `(conj+ ~@body)))))
;; (defmacro fresh [vars &rest body]
;;   (if (seq? vars)
;;     `(callfresh
;;       (fn [~(car vars)]
;;         (fresh ~(cdr vars) (conj+ ~@body))))
;;     `(conj+ ~@body)))
(defmacro fresh [vars &rest body]
  (if (empty? vars)
    `(conj+ ~@body)
    `(callfresh
      (fn [~(car vars)]
        (fresh ~(cdr vars) ~@body)))))

;; (defn walk* [v s]
;;   (let [v (walk v s)]
;;     (cond
;;       (lvar? v) v

;;       (list? v)
;;       (cons (walk* (car v) s) (walk* (cdr v) s))

;;       :else v)))
(defn walk* [v1 s]
  (let [v (walk v1 s)]
    (cond
     [(var? v) v]
     
     [(pair? v)
      (cons (walk* (ccar v) s)
            (walk* (ccdr v) s))]

     [True v])))

;; (defn reify-1st [[s c]]
;;   (walk* (lvar 0) s))
(defn reify-1st [[s c]]
  (walk* (var 0) s))

;; (defn run [n g]
;;   (map reify-1st (take n (callgoal g))))
;;
;; (cmap reify-1st (ptake 5 (callgoal (fresh [q a b] (== q (clist a b)) (appendo a b (clist 1 2 3 4 5))))))
;;
(defn run [n g]
  (cmap reify-1st (ptake n (callgoal g))))

;; (defmacro conde [& gs]
;;   `(disj+ ~@(map (fn [l] `(conj+ ~@l)) gs)))
(defmacro conde [&rest gs]
  `(disj+ ~@(cmap (fn [l] `(conj+ ~@l)) gs)))

(defn appendo [l r out]
  (disj
   (conj (== l nil) (== r out))
   (fresh [a d res]
          (== (ccons a d) l)
          (== (ccons a res) out)
          (appendo d r res))))

;; (defn appendo [l r out]
;;   (disj+
;;    (conj+ (== l nil) (== r out))
;;    (fresh [a d rest]
;;           (== (ccons a d) l)
;;           (== (ccons a res) out)
;;           (appendo d r res))))

;; (defn appendo [l r out]
;;   (conde
;;    ((== nil l) (== r out))
;;    ((fresh [a d res]
;;       (== (ccons a d) l)
;;       (== (ccons a res) out)
;;       (appendo d r res)))))

;; (run 1 (fresh [q] (appendo (clist 1 2) (clist 3 4) q)))
;; (ptake 1 (callgoal (fresh [q] (appendo (clist 1 2) (clist 3 4) q))))
;; => ([pmap({pset([2]): 2, pset([1]): 1}), 4])

;; (ptake 1 (callgoal (fresh [q a b] (== q (clist a b)) (appendo a b (clist 1 2 3 4 5)))))
;; => ([pmap({pset([2]): (1 2 3 4 5), pset([1]): None, pset([0]): (pset([1]) pset([2]))}), 3])
;;
;; (ptake 5 (callgoal (fresh [q a b] (== q (clist a b)) (appendo a b (clist 1 2 3 4 5)))))
;; => ([pmap({pset([2]): (1 2 3 4 5),
;;            pset([1]): None,
;;            pset([0]): (pset([1]) pset([2]))}), 3]
;;     [pmap({pset([2]): (2 3 4 5),
;;            pset([0]): (pset([1]) pset([2])),
;;            pset([4]): None,
;;            pset([1]): (pset([3]) pset([4])),
;;            pset([3]): 1,
;;            pset([5]): (2 3 4 5)}), 6]
;;     [pmap({pset([2]): (3 4 5),
;;            pset([7]): None,
;;            pset([6]): 2,
;;            pset([0]): (pset([1]) pset([2])),
;;            pset([4]): (pset([6]) pset([7])),
;;            pset([1]): (pset([3]) pset([4])),
;;            pset([3]): 1,
;;            pset([8]): (3 4 5),
;;            pset([5]): (2 3 4 5)}), 9]
;;     [pmap({pset([7]): (pset([9]) pset([10])),
;;            pset([9]): 3,
;;            pset([6]): 2,
;;            pset([0]): (pset([1]) pset([2])),
;;            pset([4]): (pset([6]) pset([7])),
;;            pset([3]): 1,
;;            pset([8]): (3 4 5),
;;            pset([5]): (2 3 4 5),
;;            pset([2]): (4 5),
;;            pset([11]): (4 5),
;;            pset([10]): None,
;;            pset([1]): (pset([3]) pset([4]))}), 12]
;;     [pmap({pset([7]): (pset([9]) pset([10])),
;;            pset([9]): 3,
;;            pset([6]): 2,
;;            pset([0]): (pset([1]) pset([2])),
;;            pset([4]): (pset([6]) pset([7])),
;;            pset([14]): 5,
;;            pset([3]): 1,
;;            pset([8]): (3 4 5),
;;            pset([5]): (2 3 4 5),
;;            pset([2]): 5,
;;            pset([12]): 4,
;;            pset([11]): (4 5),
;;            pset([13]): None,
;;            pset([10]): (pset([12]) pset([13])),
;;            pset([1]): (pset([3]) pset([4]))}), 15])

;; (run 5 (fresh [q a b] (== q (clist a b)) (appendo a b (clist 1 2 3 4 5))))
;; => (('None' 1 2 3 4 . 5) ((1) 2 3 4 . 5) ((1 2) 3 4 . 5) ((1 2 3) 4 . 5) ((1 2 3 4) . 5))







;; ground-appendo
;; SCHEME:
;; (test-check "ground appendo"
;;   (car ((ground-appendo empty-state)))
;;   '(((#(2) b) (#(1)) (#(0) . a)) . 3))
;;
;; (ptake 1 (callgoal (appendo (clist 'a) (clist 'b) (clist 'a 'b))))
;; 
;; (def ground-appendo (appendo (clist 'a) (clist 'b) (clist 'a 'b)))
