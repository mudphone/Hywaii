(import [mu [*]]
        [logic [*]])
(require user-mu)

(defn test-caro-acorn []
  (let [$ (run* (fresh [r] (caro ['a 'c 'o 'r 'n] r)))]
    (assert (= $ ['a]))))

(defn test-caro-true []
  (let [$ (run* (fresh [q]
                       (caro [1 2 3 4 5] 1)
                       (== True q)))]
    (assert (= $ [True]))))

(defn test-caro-pear []
  (let [$ (run* (fresh [r x y]
                       (caro [r y] x)
                       (== 'pear x)))]
    (assert (= $ ['pear]))))

(defn test-caro-grape []
  (let [$ (run* (fresh [r x y]
                       (caro ['grape 'raisin 'pear] x)
                       (caro [['a] ['b] ['c]] y)
                       (== (cons x y) r)))]
    (assert (= $ [['grape 'a]]))))

(defn test-caro []
  (let [$ (run* (fresh [q] (caro [1 2] 1)))]
    (assert (= $ ['_.0]))))

(defn test-caro-fail []
  (assert (null? (ptake 1 (callgoal (caro [1 2] 1000))))))

(defn test-cdro-acorn []
  (let [$ (run* (fresh [r v]
                       (cdro ['a 'c 'o 'r 'n] v)
                       (caro v r)))]
    (assert (= $ ['c]))))

(defn test-cdro-true []
  (let [$ (run* (fresh [q]
                       (cdro ['a 'c 'o 'r 'n] ['c 'o 'r 'n])
                       (== True q)))]
    (assert (= $ [True]))))

(defn test-cdro-nested []
  (let [$ (run* (fresh [x] (cdro ['c 'o 'r 'n] [x 'r 'n])))]
    (assert (= $ ['o]))))

(defn test-caro-cdro []
  (let [$ (run* (fresh [l x]
                       (cdro l ['c 'o 'r 'n])
                       (caro l x)
                       (== 'a x)))]
    (assert (= $ [['a 'c 'o 'r 'n]]))))

(defn test-cdro []
  (let [$ (run* (fresh [q] (cdro [1 2] [2])))]
    (assert (= $ ['_.0]))))

(defn test-cdro-fail []
  (assert (null? (ptake 1 (callgoal (cdro [1 2] [1000]))))))

(defn test-conso []
  (let [$ (run* (fresh [l]
                       (conso [1 2 3] [4 5] l)))]
    (assert (= $ [[[1 2 3] 4 5]]))))

(defn test-conso-2 []
  (let [$ (run* (fresh [x]
                       (conso x [1 2 3] [0 1 2 3])))]
    (assert (= $ [0]))))

(defn test-conso-nested []
  (let [$ (run* (fresh [r x y z]
                       (== [1 2 3 x] r)
                       (conso y [2 z 4] r)))]
    (assert (= $ [[1 2 3 4]]))))

(defn test-conso-first []
  (let [$ (run* (fresh [x] (conso x [1 2 3] [0 1 2 3])))]
    (assert (= $ [0]))))

(defn test-conso-match []
  (let [$ (run* (fresh [l x]
                       (== [1 2 x 4] l)
                       (conso x [2 x 4] l)))]
    (assert (= $ [[1 2 1 4]]))))

(defn test-conso-match-reverse-order []
  (let [$ (run* (fresh [l x]
                       (conso x [2 x 4] l)
                       (== [1 2 x 4] l)))]
    (assert (= $ [[1 2 1 4]]))))

(defn test-conso-with-cons []
  (let [$ (run* (fresh [q] (conso q 2 (cons 1 2))))]
    (assert (= $ [1]))))

(defn test-conso-with-cons2 []
  (let [$ (run* (fresh [q] (conso 1 q (cons 1 2))))]
    (assert (= $ [2]))))

(defn test-conso-with-list []
  (let [$ (run* (fresh [q] (conso q [2] [1 2])))]
    (assert (= $ [1]))))

(defn test-conso-with-list2 []
  (let [$ (run* (fresh [q] (conso 1 q [1 2])))]
    (assert (= $ [[2]]))))

(defn test-caro-cdro-conso []
  (let [$ (run* (fresh [l d x y w s]
                       (conso w ['a 'n 's] s)
                       (cdro l s)
                       (caro l x)
                       (== 'b x)
                       (cdro l d)
                       (caro d y)
                       (== 'e y)))]
    (assert (= $ [['b 'e 'a 'n 's]]))))

(defn test-nullo []
  (let [$ (run* (fresh [q] (nullo q)))]
    (assert (= $ [[]]))))

(defn test-nullo-empty []
  (let [$ (run* (fresh [q]
                       (nullo [1 2 3])
                       (== True q)))]
    (assert (= $ []))))

(defn test-nullo-true []
  (let [$ (run* (fresh [q]
                       (nullo [])
                       (== True q)))]
    (assert (= $ [True]))))

(defn test-appendo/l []
  (assert (= (run 1 (fresh [q] (appendo/l [1 2] [3 4] q)))
             [[1 2 3 4]])))

(defn test-appendo/l-two-lists []
  (let [$ (run 6 (fresh [q a b]
                        (== q [a b])
                        (appendo/l a b [1 2 3 4 5])))]
    (assert (= (len $) 6))
    (assert (= (nth $ 0) [[] [1 2 3 4 5]]))
    (assert (= (nth $ 1) [[1] [2 3 4 5]]))
    (assert (= (nth $ 2) [[1 2] [3 4 5]]))
    (assert (= (nth $ 3) [[1 2 3] [4 5]]))
    (assert (= (nth $ 4) [[1 2 3 4] [5]]))
    (assert (= (nth $ 5) [[1 2 3 4 5] []]))))

(defn test-pairo-true-cons []
  (let [$ (run* (fresh [q]
                       (pairo (cons q q))
                       (== True q)))]
    (assert (= $ [True]))))

(defn test-pairo-true-list []
  (let [$ (run* (fresh [q]
                       (pairo [q q])
                       (== True q)))]
    (assert (= $ [True]))))

(defn test-pairo-fail []
  (let [$ (run* (fresh [q]
                       (pairo [])
                       (== True q)))]
    (assert (= $ []))))

(defn test-pairo-fail-2 []
  (let [$ (run* (fresh [q]
                       (pairo 'pair)
                       (== True q)))]
    (assert (= $ []))))

(defn test-pairo-fresh []
  (let [$ (run* (fresh [x] (pairo x)))]
    (assert (= $ [(cons '_.0 '_.1)]))))

(defn test-pairo-fresh-cons []
  (let [$ (run* (fresh [r] (pairo (cons r 'pear))))]
    (assert (= $ ['_.0]))))
