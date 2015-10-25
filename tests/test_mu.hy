(import [pyrsistent [pmap]]
        [mu [*]])

;; Cons
(defn test-list? []
  (assert (list? (cons 1 [])))
  (assert (list? (cons 1 [2])))
  (assert (list? (cons 1 nil)))
  (assert (list? (cons 1 '())))
  (assert (list? (cons 1 '(1))))
  (assert (not (list? (cons 1 2))))
  (assert (not (list? (cons 1 (cons 1 2))))))

(defn test-seq? []
  (assert (seq? [1]))
  (assert (seq? [1 2]))
  (assert (seq? (cons 1 nil)))
  (assert (not (seq? (cons 1 2)))))

(defn test-null? []
  (assert (null? nil))
  (assert (null? []))
  (assert (not (null? [1])))
  (assert (not (null? [1 2 3]))))

(defn test-pair? []
  (assert (pair? [1]))
  (assert (not (pair? [])))
  (assert (not (pair? nil)))
  (assert (pair? (cons 1 2))))

(defn test-fn? []
  (assert (fn? (fn [x] x)))
  (assert (not (fn? 1)))
  (assert (not (fn? [1])))
  (assert (not (fn? (cons 1 2))))
  (assert (not (fn? nil))))

(defn test-var []
  "Logic variables must be hashable, to serve as map keys"
  (let [s (stor {(var 0) 5})]
    (assert (= (.get s (var 0)) 5))))

(defn test-var? []
  (assert (var? (var 0))))

(defn test-stor-get []
  (let [s (stor {(var 0) 5})]
    (assert (= (stor-get s (var 0)) 5))))

(defn test-stor-contains? []
  (let [s (stor {(var 0) 5})]
    (assert (stor-contains? s (var 0)))
    (assert (not (stor-contains? s (var 1))))))

(defn test-stor-assoc []
  (let [s (stor-assoc (stor) (var 0) 1)]
    (assert (= (stor-get s (var 0)) 1))))

(defn test-empty-state []
  (assert (= empty-state [(pmap {}) 0]))
  (assert (= (last empty-state) 0)))

(defn test-walk []
  (assert (= (walk 1337    (stor))
             1337))
  (assert (= (walk (var 0) (stor))
             (var 0)))
  (assert (= (walk (var 0) (stor {(var 0) 1337}))
             1337))
  (assert (= (walk (var 1) (stor {(var 0) 1337 (var 1) (var 0)}))
             1337)))

(defn test-unify []
  (assert (= (unify 1337 1337 (stor))
             (stor)))
  (assert (not (unify 1337 1338 (stor))))
  (assert (= (unify [1 2 3] [1 2 3] (stor))
             (stor)))
  (assert (not (unify [1 2 3] [1 2 4] (stor))))
  (assert (not (unify [1 2 3] [1 2 3 4] (stor))))
  (assert (= (unify [1 2 3] [1 2 (var 0)] (stor))
             (stor {(var 0) 3}))))

(defn test-unit []
  (let [$ (unit [(stor) 0])]
    (assert (= (first (car $)) (stor)))
    (assert (= (last (car $)) 0))
    (assert (= (cdr $) []))))

(defn test-== []
  (let [$ ((== 1 1) empty-state)]
    (assert (= (car $) empty-state))
    (assert (= (len $) 1))))

(defn test-callfresh []
  (let [$ ((callfresh (fn [q] (== q 5))) empty-state)]
    (assert (= (car $) [(stor {(var 0) 5}) 1]))
    (assert (= (len $) 1))))

(defn test-mplus []
  (assert (= (mplus [1 2] [3 4]) [1 3 2 4])))

(defn test-disj []
  (let [$ ((callfresh (fn [q] (disj (== q 1) (== q 2)))) empty-state)]
    (assert (= (car $) [(stor {(var 0) 1}) 1]))
    (assert (= (car (cdr $)) [(stor {(var 0) 2}) 1]))))

(defn test-conj []
  (let [$ ((callfresh (fn [q] (conj (== q 1) (== q 1)))) empty-state)]
    (assert (= (car $) [(stor {(var 0) 1}) 1]))
    (assert (= (len $) 1))))

(defn test-callgoal []
  (let [$ (callgoal (callfresh (fn [q] (conj (== q 1) (== q 1)))))]
    (assert (= (car $) [(stor {(var 0) 1}) 1]))
    (assert (= (len $) 1))))

(defn test-ptake []
  (assert (= (len (ptake 10 (callgoal (callfresh fives)))) 10)))

(defn test-trampolining-streams []
  (let [fives-n-sixes (callfresh (fn [x] (disj (fives x) (sixes x))))
        $ (ptake 10 (callgoal fives-n-sixes))]
    (assert (= (len $) 10))
    (assert (= (car $)
               [(stor {(var 0) 5}) 1]))
    (assert (= (car (cdr $))
               [(stor {(var 0) 6}) 1]))))

(defn test-conj-and-disj []
  (let [$ (callgoal
           (conj
            (callfresh (fn [a] (== a 7)))
            (callfresh (fn [b] (disj (== b 5) (== b 6))))))]
    (assert (= (len $) 2))
    (assert (= (car $)
               [(stor {(var 1) 5 (var 0) 7}) 2]))
    (assert (= (car (cdr $))
               [(stor {(var 1) 6 (var 0) 7}) 2]))))
