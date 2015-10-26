(import [mu [*]]
        [logic [*]])
(require user-mu)

(defn test-caro []
  (let [$ (ptake 1 (callgoal (caro [1 2] 1)))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 [2]))))

(defn test-caro-fail []
  (assert (null? (ptake 1 (callgoal (caro [1 2] 1000))))))

(defn test-cdro []
  (let [$ (ptake 1 (callgoal (cdro [1 2] [2])))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 1))))

(defn test-cdro-fail []
  (assert (null? (ptake 1 (callgoal (cdro [1 2] [1000]))))))

(defn test-conso-with-cons []
  (let [$ (ptake 1 (callgoal (fresh [q] (conso q 2 (cons 1 2)))))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 1))))

(defn test-conso-with-cons2 []
  (let [$ (ptake 1 (callgoal (fresh [q] (conso 1 q (cons 1 2)))))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 2))))

(defn test-conso-with-list []
  (let [$ (ptake 1 (callgoal (fresh [q] (conso q [2] [1 2]))))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 1))))

(defn test-conso-with-list2 []
  (let [$ (ptake 1 (callgoal (fresh [q] (conso 1 q [1 2]))))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 [2]))))

(defn test-nullo []
  (let [$ (ptake 1 (callgoal (fresh [q] (nullo q))))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (= v0 []))))

(defn test-nullo-empty []
  (let [$ (ptake 1 (callgoal (fresh [q]
                                    (nullo [1 2 3])
                                    (== True q))))]
    (assert (= $ []))))

(defn test-nullo-true []
  (let [$ (ptake 1 (callgoal (fresh [q]
                                    (nullo [])
                                    (== True q))))
        state (car $)
        v0 (walk (var 0) (car state))]
    (assert (and (instance? bool v0)
                 v0))))
