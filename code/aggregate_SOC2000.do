*===============================================================================
*AGGREGATION OF BSOC2000 CODES
*===============================================================================

*Here I am aggregating based on the number of observations in the SES
*====================================================================
g bsoc00Agg=bsoc2000
label copy bsoc2000 bsoc00Agg, replace
label values bsoc00Agg bsoc00Agg

*This creates the aggregation for problematic 2001 codes
replace bsoc00Agg=1122 if inlist(bsoc2000,1122,1123)
replace bsoc00Agg=1141 if inlist(bsoc2000,1141,1142)
replace bsoc00Agg=1172 if inlist(bsoc2000,1172,1173,1174)
replace bsoc00Agg=1181 if inlist(bsoc2000,1181,1183,1184,1185)
replace bsoc00Agg=1221 if inlist(bsoc2000,1221,1223)
replace bsoc00Agg=3111 if inlist(bsoc2000,3111,3113,3114,3115,3119)
replace bsoc00Agg=3131 if inlist(bsoc2000,3131,3132)
replace bsoc00Agg=3212 if inlist(bsoc2000,3212,3213,3214,3217,3218)
replace bsoc00Agg=3312 if inlist(bsoc2000,3313,3314,3319)
replace bsoc00Agg=3411 if inlist(bsoc2000,3411,3412,3413,3415,3416)
replace bsoc00Agg=3442 if inlist(bsoc2000,3442,3443)
replace bsoc00Agg=3511 if inlist(bsoc2000,3511,3512,3513,3514)
replace bsoc00Agg=3532 if inlist(bsoc2000,3532,3533)
replace bsoc00Agg=3534 if inlist(bsoc2000,3534,3535)
replace bsoc00Agg=3537 if inlist(bsoc2000,3537,3539)
replace bsoc00Agg=3541 if inlist(bsoc2000,3541,3542,3543,3544)
replace bsoc00Agg=3565 if inlist(bsoc2000,3565,3566,3567,3568)
replace bsoc00Agg=4111 if inlist(bsoc2000,4111,4112,3568)
replace bsoc00Agg=4135 if inlist(bsoc2000,4135,4136,4137)
replace bsoc00Agg=5221 if inlist(bsoc2000,5221,5222,5223,5224)
replace bsoc00Agg=5232 if inlist(bsoc2000,5232,5234)
replace bsoc00Agg=5242 if inlist(bsoc2000,5242,5243,5244)
replace bsoc00Agg=5312 if inlist(bsoc2000,5312,5313)
replace bsoc00Agg=5421 if inlist(bsoc2000,5421,5422,5423)
replace bsoc00Agg=5432 if inlist(bsoc2000,5432,5434)
replace bsoc00Agg=5492 if inlist(bsoc2000,5492,5499)
replace bsoc00Agg=6111 if inlist(bsoc2000,6111,6112,6113)
replace bsoc00Agg=6131 if inlist(bsoc2000,6131,6139)
replace bsoc00Agg=6211 if inlist(bsoc2000,6211,6212,6213,6214)
replace bsoc00Agg=6221 if inlist(bsoc2000,6221,6222)
replace bsoc00Agg=1222 if inlist(bsoc2000,1222,1224,1225)
replace bsoc00Agg=3431 if inlist(bsoc2000,3431,3432,3433,3434)
replace bsoc00Agg=5321 if inlist(bsoc2000,5321,5322,5323)
replace bsoc00Agg=8215 if inlist(bsoc2000,8215,8217,8219)
replace bsoc00Agg=1151 if inlist(bsoc2000,1151,1152)
replace bsoc00Agg=1231 if inlist(bsoc2000,1231,1232,1233)
replace bsoc00Agg=2121 if inlist(bsoc2000,2121,2122,2123,2124)
replace bsoc00Agg=2126 if inlist(bsoc2000,2126,2127,2128)
replace bsoc00Agg=3121 if inlist(bsoc2000,3121,3122)
replace bsoc00Agg=3531 if inlist(bsoc2000,3531,3532,3533)
replace bsoc00Agg=3561 if inlist(bsoc2000,3561,3562)
replace bsoc00Agg=6114 if inlist(bsoc2000,6114,6115)
replace bsoc00Agg=6122 if inlist(bsoc2000,6122,6123,6124)
replace bsoc00Agg=7122 if inlist(bsoc2000,7122,7123,7124,7125,7129)
replace bsoc00Agg=1161 if inlist(bsoc2000,1161,1162)
replace bsoc00Agg=1221 if inlist(bsoc2000,1221,1222,1224,1225)
replace bsoc00Agg=4131 if inlist(bsoc2000,4132,4133,4134,4135,4136,4137)
replace bsoc00Agg=4211 if inlist(bsoc2000,4212,4213,4214,4215,4216)
replace bsoc00Agg=5213 if inlist(bsoc2000,5213,5214,5215)
replace bsoc00Agg=5231 if inlist(bsoc2000,5231,5232,5234)
replace bsoc00Agg=5241 if inlist(bsoc2000,5241,5242,5245,5249,5243,5244)
replace bsoc00Agg=7211 if inlist(bsoc2000,7211,7212)
replace bsoc00Agg=8121 if inlist(bsoc2000,8122,8123,8125,8126,8129)
replace bsoc00Agg=4113 if inlist(bsoc2000,4113,4114)
replace bsoc00Agg=4211 if inlist(bsoc2000,4211,4217)
replace bsoc00Agg=5111 if inlist(bsoc2000,5111,5113,5112)
replace bsoc00Agg=5312 if inlist(bsoc2000,5312,5314,5315,5316,5319)
replace bsoc00Agg=8142 if inlist(bsoc2000,8142,8143)
replace bsoc00Agg=4121 if inlist(bsoc2000,4121,4122)


*RELABELLING
label define bsoc00Agg  1122 "1122 managers in construction, mining and energy", modify
label define bsoc00Agg  1141 "1141 quality assurance and customer care managers", modify
label define bsoc00Agg  1172 "1172 protective service officers", modify
label define bsoc00Agg  1181 "1181 healthcare and social service managers", modify
label define bsoc00Agg  1221 "1221 hotel, accomodation, restaurant, and catering mngers", modify
label define bsoc00Agg  3111 "3111 laboratory, engineering, and quality assurance tech.", modify
label define bsoc00Agg  3131 "3131 it technitians", modify
label define bsoc00Agg  3212 "3212 healthcare techinitians, except nurses", modify
label define bsoc00Agg  3312 "3312 police, fire, and prison officers", modify
label define bsoc00Agg  3411 "3411 artistic professionals", modify
label define bsoc00Agg  3442 "3442 Sports And Fitness Occupations", modify
label define bsoc00Agg  3511 "3511 Transport Associate Professionals", modify
label define bsoc00Agg  3532 "3532 brokers and insurance underwriters", modify
label define bsoc00Agg  3534 "3534 fin., invest, and taxation analysts and advisers", modify
label define bsoc00Agg  3537 "3537 finantial and accounting techs, and profs nec", modify
label define bsoc00Agg  3541 "3541 sales representatives, marketing profs, estate agents, actioneers", modify
label define bsoc00Agg  3565 "3565 inspects fact, utils & trading standards, statutory examiners", modify
label define bsoc00Agg  4111 "4111 civil service officers and assistants", modify
label define bsoc00Agg  4135 "4135 library and database assistant and clerks / market research interviewers", modify
label define bsoc00Agg  5221 "5221 Metal Machining, Fitting And Instrument Making Trades", modify
label define bsoc00Agg  5232 "5232 vehicle body builders and repairers / vehicle spray painters", modify
label define bsoc00Agg  5242 "5242 telecommunication engineers, lines repairers, tv/audio engineers", modify
label define bsoc00Agg  5312 "5312 bricklayers, masons, roofers", modify
label define bsoc00Agg  5321 "5321 building trades", modify
label define bsoc00Agg  5421 "5421 printing trades", modify
label define bsoc00Agg  5432 "5432 chefs, cooks, bakers, flour confectioners", modify
label define bsoc00Agg  5492 "5492 Skill trades nec", modify
label define bsoc00Agg  6111 "6111 nursing aux, amb staff, dental nurses", modify
label define bsoc00Agg  6131 "6131 veterinary nurses and assistants, other aniimal care occ", modify
label define bsoc00Agg  6211 "6211 Leisure And Travel Service Occupations", modify
label define bsoc00Agg  6221 "6221 Hairdressers And Related Occupations", modify
label define bsoc00Agg  1222 "1222 Managers And Proprietors In Hospitality And Leisure Services except hotels and restaurants", modify
label define bsoc00Agg  3431 "3431 Media Associate Professionals", modify
label define bsoc00Agg  8215 "8215 Transport operatives nec", modify
label define bsoc00Agg  1151 "1151 Financial institution and office managers", modify
label define bsoc00Agg  1231 "1231 Managers And Proprietors In Other Service Industries except retail", modify
label define bsoc00Agg  2121 "2121 civil, mechanical, electrical and electronics engineers", modify
label define bsoc00Agg  2126 "2126 design, development, production and process engineers", modify
label define bsoc00Agg  3121 "3121 Draughtspersons And Building Inspectors", modify
label define bsoc00Agg  3531 "3531 Estimators, valuers, assessors, brokers and insurance underwriters", modify
label define bsoc00Agg  3561 "3561 public service associates, personnel and industrial relations officers", modify
label define bsoc00Agg  3567 "3567 occupl hygnists, health sfty offs, and environmental health offs", modify
label define bsoc00Agg  6114 "6114 houseprnts, residential wardens, care assistants and home carers", modify
label define bsoc00Agg  6122 "6122 childminders, playgroup leaders and educational assistants", modify
label define bsoc00Agg  7122 "7122 Sales related occupations", modify
label define bsoc00Agg  1161 "1161 Transport, distribution, storage and warehouse managers", modify
label define bsoc00Agg  1221 "1221 Managers and proprietors in hospitality and leisure services", modify
label define bsoc00Agg  4131 "4131 Administrative occupations: records", modify
label define bsoc00Agg  4211 "4211 Secretarial and related occupations", modify
label define bsoc00Agg  5213 "5213 Metal forming, welding and related trades", modify
label define bsoc00Agg  5231 "5231 Vehicle trades", modify
label define bsoc00Agg  5241 "5241 Electrical trades", modify
label define bsoc00Agg  7211 "7211 Customer sevice occupations", modify
label define bsoc00Agg  8121 "8121 Plant and machine operatives", modify
label define bsoc00Agg  4113 "4113 local gov clerical offs & assists / officers in NGOs", modify
label define bsoc00Agg  4211 "4211 Secretarial and related occupations", modify
label define bsoc00Agg  5111 "5111 Farmers, gardeners and ground women", modify
label define bsoc00Agg  5311 "5311 Construction trades", modify
label define bsoc00Agg  8142 "8142 Road and ail construction operatives", modify
label define bsoc00Agg  4121 "4121 Credit controllers, accnts wages cleark, bookkeeper", modify
