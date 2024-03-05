
eststo est1: regress net_dlnq rhs 
eststo est2: regress net_dlnq rhs [aw=adj_obs]
eststo est3:  regress net_dlnq rhs [aw=obs]

esttab est1 est2 est3, se

