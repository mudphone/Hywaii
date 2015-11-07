;; TOP SLIDES

;; SLIDE 26
(run*
 (fresh [q]
        (== q 5)))

;; SLIDE 27
(run* 
 (fresh [q] 
        (== 1 1)))

;; SLIDE 28
(run* 
 (fresh [q] 
        (== 1 2)))

;; SLIDE 29
(run* 
 (fresh [x y] 
        (== y 6) 
        (== x y)))

;; SLIDE 30
(run* 
 (fresh [q] 
        (conde [(== q 5)] 
               [(== q 6)])))

;; SLIDE 31
(run*
 (fresh [x y]
        (conde [(== y 5) (== x y)]
               [(== x 6)])))

;; SLIDE 32
(defn caro [p a]
  (fresh [d]
         (== (cons a d) p)))

(defn cdro [p d]
  (fresh [a]
         (== (cons a d) p)))

(defn conso [a d p]
  (== (cons a d) p))

(defn nullo [x]
  (== [] x))

;; SLIDE 33
(defn appendo [l r out]
  (conde
   ((== [] l) (== r out))
   ((fresh [a d res]
           (== (cons a d) l)
           (== (cons a res) out)
           (appendo d r res)))))

(run*
 (fresh [q]
        (appendo [1 2] [3 4] q)))

(run*
 (fresh [q] 
        (appendo [1 2] q [1 2 3 4])))

;; SLIDE 34
(run*
 (fresh [q x y]
        (appendo x y [1 2 3 4])))

(run* 
 (fresh [q x y]
        (appendo x y [1 2 3 4]) 
        (== [x y] q)))

;; SLIDE 35
(defn append [l r]
  "Join two lists"
  (cond
   [(= l []) r]

   [True
    (cons (car l) (append (cdr l) r))]))

;; SLIDE 36
(defn appendo [l r out]
 (conde
   [(== [] l) (== r out)]

   [(fresh [a d res]
      (== (cons a d) l)
      (== (cons a res) out)
      (appendo d r res))]))
