(import [pyrsistent [pvector :as vec]]
        [pyrsistent :as pyr])

;; This is my attempt at implementing μKanren in Hy.
;; All credit for μKanren to Jason Hemann and Daniel P. Friedman:
;; http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf


;; Variables "are represented as vectors that hold their variable index."
(def var vec)

(defn var? [v]
  "Test if is var type"
  (issubclass (type v) pyr.PVector))

(defn var=? [x1 x2]
  (and (var? x1)
       (var? x2)
       (= (first x1) (first x2))))


;;
