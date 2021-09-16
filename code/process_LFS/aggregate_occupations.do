*Aggregating occupations

local occupation bsoc00Agg //`1'

cap drop occ_1dig
generate occ_1dig=floor(`occupation'/1000)


label define occ_1dig ///
    1 "Managers and Senior Officials" ///
    2 "Professional Occupations" ///
    3 "Associate Professional and Technical Occupations" ///
    4 "Administrative and Secretarial Occupations" ///
    5 "Skilled Trades Occupations" ///
    6 "Personal Service Occupations" ///
    7 "Sales and Customer Service Occupations" ///
    8 "Process, Plant and Machine Operatives" ///
    9 "Elementary Occupations" ///

label values occ_1dig occ_1dig

