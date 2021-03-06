(import [user-mu [*]]
        pytest)
(require user-mu)

(defn test-zzz []
  (let [$ (callgoal (callfresh sevens))
        state (car $)
        counter (last state)]
    (assert (= (first state) (pmap {(var 0) 7})))
    (assert (= (last state) 1))
    (assert (fn? (cdr $)))))

(defn test-fresh []
  (assert (= (run* (fresh [q] (== q 5))) [5]))
  (assert (= (run* (fresh [q] (== 5 q))) [5]))
  (assert (= (run* (fresh [q x] (== q x) (== x 6))) [6]))
  (assert (= (run* (fresh [q x] (== x q) (== 6 x))) [6])))

(defn test-reify-s []
  (let [s (run*
           (fresh [q x y]
                  (== q [x y])
                  (conde [(== x 5)]
                         [(== y 6)])))]
    (assert (= (first s)  [5 (HySymbol "_.0")]))
    (assert (= (second s) [(HySymbol "_.0") 6]))))

(defn test-conde []
  (let [$ (take-all (callgoal (fresh [q]
                                     (conde
                                      [(== q 5)]
                                      [(== q 6)]))))
        s/c0 (nth $ 0)
        s/c1 (nth $ 1)
        v0 (walk (var 0) (car s/c0))
        v1 (walk (var 0) (car s/c1))
        results [v0 v1]]
    (assert (= (len $) 2))
    (assert (= (len (list (filter (fn [x] (= x 5)) results)))
               1)) ;; Result order doesn't matter
    (assert (= (len (list (filter (fn [x] (= x 6)) results)))
               1))))

(defn test-conde-run []
  (let [$ (run* (fresh [q] (conde [(== q 5)]
                                  [(== q 6)])))]
    (assert (= (len $) 2))
    (assert (some (fn [x] (= x 5)) $)) ;; Result order doesn't matter
    (assert (some (fn [x] (= x 6)) $))))

(defn test-conde-run-3 []
  (let [$ (run* (fresh [q] (conde [(== q 5)]
                                  [(== q 6)]
                                  [(== q 7)])))]
    (assert (= (len $) 3))))

(defn test-conde-run-and-or []
  (let [$ (run* (fresh [q x] (conde [(== q x)
                                     (== x 5)]
                                    [(== q 6)])))]
    (assert (= (len $) 2))
    (assert (some (fn [x] (= x 5)) $)) ;; Result order doesn't matter
    (assert (some (fn [x] (= x 6)) $))))

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

(defn test-appendo/e []
  (assert (= (run 1 (fresh [q] (appendo/e [1 2] [3 4] q)))
             [[1 2 3 4]])))

(defn test-appendo/e-two-lists []
  (let [$ (run 6 (fresh [q a b]
                        (== q [a b])
                        (appendo/e a b [1 2 3 4 5])))]
    (assert (= (len $) 6))
    (assert (= (nth $ 0) [[] [1 2 3 4 5]]))
    (assert (= (nth $ 1) [[1] [2 3 4 5]]))
    (assert (= (nth $ 2) [[1 2] [3 4 5]]))
    (assert (= (nth $ 3) [[1 2 3] [4 5]]))
    (assert (= (nth $ 4) [[1 2 3 4] [5]]))
    (assert (= (nth $ 5) [[1 2 3 4 5] []]))))


