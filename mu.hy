(import [pyrsistent [pvector :as pvec
                     pmap :as pmap
                     pset :as pset]]
        [pyrsistent :as pyr])

;; This is my attempt at implementing μKanren in Hy.
;; All credit for μKanren to Jason Hemann and Daniel P. Friedman:
;; http://webyrd.net/scheme-2013/papers/HemannMuKanren2013.pdf

;; Much appreciation to Bodil Stokke for explaining things clearly:
;; μKanren: Running the Little Things Backwards
;; EuroClojure, Barcelona, Spain, 25 June 2015.
;; https://www.youtube.com/watch?v=2e8VFSSNORg

;; Variables "are represented as vectors that hold their variable index."
(defn var [c] (, c))

(defn var? [x]
  "Test if is var type"
  (instance? (type (var 0)) x))

;; State
(def empty-state [{} 0])


;; walk
;;
;; (walk 1337 {})
;; => 1337
;;
;; (walk (, 0) {})
;; => (0,)
;;
;; (walk (, 0) {(, 0) 1337})
;; => 1337
;;
;; (walk (, 1) {(, 0) 1337, (, 1) (, 0)})
;; => 1337
(defn walk [u s]
  ""
  (if (and (var? u) (.__contains__ s u))
    (walk (.get s u) s)
    u))

;; unify
(def mzero nil)
(defn unit [sc] (cons sc mzero))

(defn list? [x] (instance? list x))
(defn assocr [m k v]
  (assoc m k v)
  m)

;; (unify 1337 1337 {})
;; => {}
;;
;; (unify 1337 1338 {})
;; => False
;;
;; (unify [1 2 3] [1 2 3] {})
;; => {}
;;
;; (unify [1 2 3] [1 2 4] {})
;; => False
;;
;; (unify [1 2 3] [1 2 3 4] {})
;; => False
;;
;; (unify [1 2 3] [1 2 (, 0)] {})
;; => {(,0) 3}
;;
;;
(defn unify [u1 v1 s1]
  (let [u (walk u1 s1)
        v (walk v1 s1)
        s s1]
    (cond
     [(and (var? u) (var? v) (= u v)) s]

     [(var? u) (assocr s u v)]
     [(var? v) (assocr s v u)]

     [(and (list? u) (list? v)
           (not (every? empty? [u v])))
      (let [s2 (unify (first u) (first v) s)]
        (and (coll? s2)
             (unify (cdr u) (cdr v) s2)))]
     
     [True (and (= u v) s)])))
