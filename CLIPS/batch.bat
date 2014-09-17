(clear)
(load "1_main.clp")

(load "2_env.clp")
(set-break forward-north-bump)
(set-break forward-south-bump)
(set-break forward-east-bump)
(set-break forward-west-bump)
(set-break msg-order-accepted-KO1)
(set-break msg-order-delayed-KO1)
(set-break msg-order-rejected-KO1)
(set-break msg-order-rejected-KO2)
(set-break msg-mng-KO1)
(set-break msg-mng-KO2)
(set-break CheckFinish_useless-1)
(set-break CheckFinish_useless-2)
(set-break CheckFinish_Useless-3)
(set-break CheckFinish_useless-4)
(set-break CheckFinish_KO_1)
(set-break CheckFinish_KO_2)
(set-break CleanTable_K0_1)
(set-break CleanTable_K0_2)
(set-break CleanTable_KO_3)
(set-break CleanTable_KO_4)
(set-break CleanTable_KO_5)
(set-break EmptyFood_KO1)
(set-break EmptyFood_KO2)
(set-break EmptyFood_KO3)
(set-break Release_KO1)
(set-break Release_KO2)
(set-break Release_KO3)
(set-break load-food_KO1)
(set-break load-food_KO2)
(set-break load-food_KO3)
(set-break load-food_KO4)
(set-break load-drink_KO1)
(set-break load-drink_KO2)
(set-break load-drink_KO3)
(set-break load-drink_KO4)
(set-break delivery-food_WRONG_2)
(set-break delivery-food_WRONG_3)
(set-break delivery-drink_WRONG_2)
(set-break delivery-drink_WRONG_3)
(set-break delivery_WRONG_4)
(set-break delivery_WRONG_5)

(load "3_agent.clp")

(load "4_percept.clp")
(load "5_strategy_FIFO.clp")
;(set-break strategy-re-execute-phase3)
;(set-break strategy-re-execute-phase5)
;(set-break strategy-go-phase1)
;(set-break strategy-change-order-in-phase3)
(set-break strategy-change-order-in-phase5)
(load "6_exec-plane.clp")
(load "7_a_star.clp")
;(set-break clean)

(reset)
(run 257)
(assert(stop-at-step 61))
