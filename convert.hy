(import autopep8)
;; (import [utils [hypprint :as pp]])
(import sys io)

(import [hy [HyExpression HySymbol HyInteger HyString HyDict
             HyKeyword HyCons]]
        [sys])

(defn -hystringify [value]
  (let [sv (string value)]
    (if (.startswith sv "is_")
      (+ (cut sv 3) "?")
      (if (= sv "None")
        "nil"
        sv))))

(defn -pprint [form]
  (cond
   [(instance? HyExpression form)
    (+ "(" (.join " " (map -pprint form)) ")")]
   [(instance? HySymbol form)
    (-hystringify form)]
   [(or (instance? HyInteger form) (integer? form))
    (string form)]
   [(instance? HyKeyword form)
    (-hystringify (rest (rest form)))]
   [(or (instance? HyString form) (string? form))
    (string (+ "\"" (string form) "\""))]
   [(or (instance? HyDict form) (instance? dict form))
    (+ "{" (.join " " (map -pprint form)) "}")]
   [(instance? list form)
    (+ "[" (.join " " (map -pprint form)) "]")]
   [(coll? form)
    (-pprint (list form))]
   [(cons? form)
    (+ "(" (-pprint (first form)) " . " (-pprint (rest form)) ")")]
   [true
    nil]))

(defn hypprint [form &optional [outermost false]]
  (if outermost
    (list (map hypprint form))
    (print (-pprint form))))

(defn hypformat [form &optional [outermost false]]
  (if outermost
    (list (map hypformat form))
    (+ (-pprint form) "\n")))

(defmacro pretty/simplify [expr &rest args]
  `(hypprint (simplify '~expr ~@args)))


(defn h2p [c]
  (.fix_code autopep8
             (disassemble c true)))

(def buffer (io.StringIO (nth sys.argv 1)))

;; (print "codes: " (nth sys.argv 1))
;; (print "python: " (h2p (apply read [] {"from_file" buffer})))

(print (h2p (apply read [] {"from_file" buffer})))
