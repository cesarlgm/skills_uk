replace y_var=d_l_wkpay if database==2
regress y_var manual* social* routine* abstract* o_*, vce(cl occupation)