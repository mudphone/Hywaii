(import [pyrsistent [pmap]])
(import [mu [empty-state]])

(defn test-empty-state []
  (assert (= empty-state [(pmap {}) 0])))

