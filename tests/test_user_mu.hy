(import [user-mu [*]])
(require user-mu)

(defn test-zzz []
  (let [$ (callgoal (callfresh sevens))
        state (car $)
        counter (last state)]
    (assert (= (first state) (pmap {(var 0) 7})))
    (assert (= (last state) 1))
    (assert (fn? (cdr $)))))

(defn test-appendo []
  (assert (= (run 1 (fresh [q] (appendo [1 2] [3 4] q)))
             [[1 2 3 4]])))

(defn test-appendo-two-lists []
  (let [$ (run 5 (fresh [q a b]
                        (== q [a b])
                        (appendo a b [1 2 3 4 5])))]
    (assert (= (len $) 5))
    (assert (= (nth $ 0) [[] [1 2 3 4 5]]))
    (assert (= (nth $ 1) [[1] [2 3 4 5]]))
    (assert (= (nth $ 2) [[1 2] [3 4 5]]))
    (assert (= (nth $ 3) [[1 2 3] [4 5]]))
    (assert (= (nth $ 4) [[1 2 3 4] [5]]))))


