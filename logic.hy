(import [user-mu [*]])
(require user-mu)

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
