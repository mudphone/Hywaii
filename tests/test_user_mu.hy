(import [user-mu [*]])
(require user-mu)

(defn test-zzz []
  (let [$ (callgoal (callfresh sevens))
        state (car $)
        counter (last state)]
    (assert (= (first state) (pmap {(var 0) 7})))
    (assert (= (last state) 1))
    (assert (fn? (cdr $)))))

(defn test-conde []
  (let [$ (take-all (callgoal (fresh [q]
                                     (conde
                                      [(== q 5)]
                                      [(== q 6)]))))
        s/c0 (nth $ 0)
        s/c1 (nth $ 1)]
    (assert (= (walk (var 0) (car s/c0)) 5))
    (assert (= (walk (var 0) (car s/c1)) 6))))

(defn test-conde-run []
  (let [$ (run* (fresh [q] (conde [(== q 5)] [(== q 6)])))]
    (assert (= $ [5 6]))))

(defn test-appendo []
  (assert (= (run 1 (fresh [q] (appendo [1 2] [3 4] q)))
             [[1 2 3 4]])))

(defn test-appendo-two-lists []
  (let [$ (run 6 (fresh [q a b]
                        (== q [a b])
                        (appendo a b [1 2 3 4 5])))]
    (assert (= (len $) 6))
    (assert (= (nth $ 0) [[] [1 2 3 4 5]]))
    (assert (= (nth $ 1) [[1] [2 3 4 5]]))
    (assert (= (nth $ 2) [[1 2] [3 4 5]]))
    (assert (= (nth $ 3) [[1 2 3] [4 5]]))
    (assert (= (nth $ 4) [[1 2 3 4] [5]]))
    (assert (= (nth $ 5) [[1 2 3 4 5] []]))))


