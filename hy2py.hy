(import autopep8)
(import [utils [hypprint :as pp]])

(defn h2p [c]
  (.fix_code autopep8
             (disassemble c true)))
