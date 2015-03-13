(defmodule CLEAN-DISTPATH (import AGENT ?ALL) (export ?ALL))

(update-order-distpath ?table ?step 0)

(defrule clean-order-distpath
  (clean-order-distpath)
  ?f1<-(exec-order (distpath ?d))
  (test (> ?d 0))
  =>
  (modify ?f1 (distpath 0))
)

(defrule clean-order-distpath-focuspop
  (clean-order-distpath)
  (exec-order (distpath ?d))
  (not (exec-order (distpath ?d&:(> ?d 0))))
  =>
  (pop-focus)
)
