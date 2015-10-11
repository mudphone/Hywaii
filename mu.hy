(import [pyrsistent [pvector :as pvec
                     pmap :as pmap
                     pset :as pset]]
        [pyrsistent :as pyr])

;; This is my attempt at implementing μKanren in Hy.
;; All credit for μKanren to Jason Hemann and Daniel P. Friedman:
;; http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf


;; Variables "are represented as vectors that hold their variable index."
(defn var [c] (pset #{c}))

(defn var? [x]
  "Test if is var type"
  (issubclass (type x) (type (var 0))))

;; State
(def empty-state [(pmap {}) 0])


;; (walk 1337 {})
;; => 1337
;;
;; (walk (var 0) {})
;; => pset([0])
;;
;; (walk (var 0) (pmap {(var 0) 1337}))
;; => 1337
;;
;; (walk (var 1) (pmap {(var 0) 1337 (var 1) (var 0)}))
;; => 1337
(defn walk [u s]
  ""
  (if (and (var? u) (.__contains__ s u))
    (walk (.get s u) s)
    u))

