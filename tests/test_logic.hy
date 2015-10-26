(import [mu [*]]
        [logic [*]])

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
