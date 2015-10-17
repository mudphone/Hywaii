(import [pyrsistent [pmap]])
(import [mu [*]])

;; Cons
(defn test-to-cons-list []
  (assert (nil? (to-cons-list [])))

  (let [cell1 (to-cons-list [1])]
    (assert (= (car cell1) 1))
    (assert (= (cdr cell1) '())))

  (let [cell2 (to-cons-list [1 2])]
    (assert (= (car cell2) 1))
    (assert (= (cdr cell2) 2)))

  (let [cell3 (to-cons-list [1 2 3])]
    (assert (= (car cell3) 1))
    (assert (= (cdr cell3) (to-cons-list [2 3])))
    (assert (= (car (cdr cell3)) 2))
    (assert (= (cdr (cdr cell3)) 3))))

(defn test-clist []
  (assert (nil? (clist)))

  (let [cell1 (clist 1)]
    (assert (= (car cell1) 1))
    (assert (= (cdr cell1) '())))

  (let [cell2 (clist 1 2)]
    (assert (= (car cell2) 1))
    (assert (= (cdr cell2) 2)))

  (let [cell3 (clist 1 2 3)]
    (assert (= (car cell3) 1))
    (assert (= (cdr cell3) (clist 2 3)))
    (assert (= (car (cdr cell3)) 2))
    (assert (= (cdr (cdr cell3)) 3))))

(defn test-list? []
  (assert (list? '()))
  (assert (list? '(1))))

(defn test-clist? []
  (assert (not (clist? (clist))))
  (assert (not (clist? '())))
  (assert (clist? (clist 1)))
  (assert (clist? (clist 1 2)))
  (assert (clist? (clist 1 2 3))))

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
  (assert (= (walk 1337    (stor))                                1337))
  (assert (= (walk (var 0) (stor))                                (var 0)))
  (assert (= (walk (var 0) (stor {(var 0) 1337})) 1337))
  (assert (= (walk (var 1) (stor {(var 0) 1337 (var 1) (var 0)})) 1337)))

(defn test-unify []
  (assert (= (unify 1337 1337 (stor))                   (stor)))
  (assert (not (unify 1337 1338 (stor))))
  (assert (= (unify (clist 1 2 3) (clist 1 2 3) (stor)) (stor)))
  (assert (not (unify (clist 1 2 3) (clist 1 2 4) (stor))))
  (assert (not (unify (clist 1 2 3) (clist 1 2 3 4) (stor))))
  (assert (= (unify (clist 1 2 3) (clist 1 2 (var 0)) (stor))
             (stor {(var 0) 3}))))

(defn test-unit []
  (let [$ (unit [(stor) 0])]
    (assert (= (car (car $)) (stor)))
    (assert (= (last (car $)) 0))
    (assert (= (cdr $) mzero))))

(defn test-== []
  (let [$ ((== 1 1) empty-state)]
    (assert (= (car $) empty-state))
    (assert (= (len $) 1))))

(defn test-callfresh []
  (let [$ ((callfresh (fn [q] (== q 5))) empty-state)]
    (assert (= (car $) [(stor {(var 0) 5}) 1]))
    (assert (= (len $) 1))))

(defn test-fn? []
  (assert (fn? (fn [q] q))))

(defn test-atom? []
  (assert (atom? 1))
  (assert (atom? (fn [x] x)))
  (assert (not (atom? '())))
  (assert (not (atom? '(1))))
  (assert (not (atom? '(1 2))))
  (assert (not (atom? (clist))))
  (assert (not (atom? (clist 1))))
  (assert (not (atom? (clist 1 2))))
  (assert (not (atom? (clist 1 2 3))))
  (assert (atom? (cdr (clist 1 2)))))

(defn test-mplus []
  (assert (= (mplus (clist 1 2) (clist 3 4)) (clist 1 2 3 4))))

(defn test-disj []
  (let [$ ((callfresh (fn [q] (disj (== q 1) (== q 2)))) empty-state)]
    (assert (= (car $) [(stor {(var 0) 1}) 1]))
    (assert (= (last $) [(stor {(var 0) 2}) 1]))))

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
    (assert (= (car $)    [(stor {(var 0) 5}) 1]))
    (assert (= (second $) [(stor {(var 0) 6}) 1]))))

(defn test-conj-and-disj []
  (let [$ (callgoal
           (conj
            (callfresh (fn [a] (== a 7)))
            (callfresh (fn [b] (disj (== b 5) (== b 6))))))]
    (assert (= (len $) 2))
    (assert (= (car $)  [(stor {(var 1) 5 (var 0) 7}) 2]))
    (assert (= (last $) [(stor {(var 1) 6 (var 0) 7}) 2]))))
