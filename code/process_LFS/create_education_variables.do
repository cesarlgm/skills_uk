*Create education definition
generate educ_4=edlevLFS 
replace educ_4=1 if         edlevLFS==0

label define educ_4 ///
    1 "GCSE D-" ///
    2 "GCSE A-C" ///
    3 "A* level / trade" ///
    4 "Bachelor +"

label values educ_4 educ_4


generate educ_3_low=educ_4
replace educ_3_low=2 if    educ_4==1
replace educ_3_low=educ_3_low-1 

label define educ_3_low ///
    1"GCSE C-" ///
    2 "A* level / trade" ///
    3 "Bachelor +"

label values educ_3_low educ_3_low


generate educ_3_mid=educ_4
replace educ_3_mid=3 if edlevLFS==2
replace educ_3_mid=educ_3_mid-1 if educ_3_mid>=3

label define educ_3_mid ///
    1 "GCSE G-" ///
    2 "GCSE A-A* level" ///
    3 "Bachelor +"

label values educ_3_mid educ_3_mid

