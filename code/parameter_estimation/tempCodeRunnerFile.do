
    egen d1s_manual=rowtotal(d1s_manual*)
    order d1s_manual, before(d1s_manual1)

