(import [mu [*]])

(defn seq? [x]
  (and (list? x)
       (not (empty? x))))

;; (defmacro zzz [g]
;;   `(fn [sc#] (fn [] (~g sc#))))
(defmacro/g! zzz [g]
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
(defmacro conj+ [g0 &rest gs]
  (if (seq? gs)
    `(conj (zzz ~g0) (conj+ ~@gs))
    `(zzz ~g0)))

;; (defmacro fresh [vars & body]
;;   `(callfresh
;;     (fn [~(first vars)]
;;       ~(if (seq (rest vars))
;;          `(fresh ~(rest vars) (conj+ ~@body))
;;          `(conj+ ~@body)))))
(defmacro fresh [vars &rest body]
  `(callfresh
    (fn [~(car vars)]
      ~(if (seq? (cdr vars))
         `(fresh ~(cdr vars) (conj+ ~@body))
         `(conj+ ~@body)))))

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
     [(atom? v)
      (cons (walk* v s) v) ]
     [(clist? v)
      (cons (walk* (car v) s) (walk* (cdr v) s))]
     [True v])))

;; (defn reify-1st [[s c]]
;;   (walk* (lvar 0) s))
(defn reify-1st [[s c]]
  (walk* (var 0) s))

;; (defn run [n g]
;;   (map reify-1st (take n (callgoal g))))
(defn run [n g]
  (list (map reify-1st (ptake n (callgoal g)))))

(defn appendo [l r out]
  (disj
   (conj (== l nil) (== r out))
   (fresh [a d res]
          (== (cons a d) l)
          (== (cons a res) out)
          (appendo d r res))))
