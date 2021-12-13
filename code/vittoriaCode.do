clear all
clear matrix
set more off, permanently
capture log close 

set maxvar 23767 
set scheme s1color, permanently

global directory "C:\Users\César\Dropbox\Boston University\8-Research Assistantship\ukData"

use "${directory}\UKDA-7467-stata11\stata11\ses_combined_revised_may2014.dta"
 
sort dataset crosspid
recode asex (1=0) (2=1) (3=.)
label def asex 0 "Male", modify
label def asex 1 "Female", modify
recode awork (3=.) 

*Whether onejob or more than one
recode bjobs (5=.) (-2=.) (-1=.) (1=0) (2=1)

*Whether job involves use of computerised or automated equipment
recode bauto (5=.) (-2=.) (-1=.) (2=0)

*class of worker
recode bemptype (3=.) (1=0) (2=1)

*Whether paid salary or wage by employer
recode bpdwage (5=.) (-2=.) (-1=.) (2=0)

*Type of self-employment
recode bselfem1 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem2 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem3 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem4 (11=.) (-2=.) (-1=.) (10=0) 
recode bselfem5 (11=.) (-2=.) (-1=.) (10=0) 

*Employee status: LFS definition
recode bempsta (3=.) (1=0) (2=1)
*=
*Whether supervisor or manager
gen bmanageall=bmanage
************************************************************************
*Here there is harmonization across waves of the variables 
recode bmanage (6=.) (-2=.) (-1=.) (3=0) (2=1)
recode bmanage_ (2=0)
recode bmanage0 (2=0)
replace bmanageall=bmanage_ if dataset==1986
replace bmanageall=bmanage0 if dataset==1992
***********************************************************************
*Whether have other working for him
recode bothers (5=.) (-2=.) (-1=.) (2=0)

*Whether job is permanent or not
recode bperm (5=.) (-2=.) (-1=.) (2=0)

*Way in which job is not permanent
recode btemp (5=.) (6=.) (7=.) (8=.) (9=.) (-1=.) 

*Whether working fulltime or parttime
recode bfultime (5=.) (-2=.) (-1=.) (2=0)


*THIS IS LIKE DISCRETION
*How much choive have over way in which job is done
replace bchoice=. if bchoice<1 | bchoice>4

*How often work involves short repetitive tasks
replace brepeat=. if brepeat<1 | brepeat>5

*How much variety in job
replace bvariety=. if bvariety<1 | bvariety>5

*How closely supervised in job
replace bsuper=. if bsuper<1 | bsuper>4
forval x=1/4{
replace bme`x'=. if bme`x'<1 | bme`x'==7
}

/*
recode brepeat (4=6) (3=7) (2=8) (1=9)
recode brepeat (5=1) (6=2) (7=3) (8=4) (9=5)
*/

*Recoding value 6 to missing in 
local X 	cdetail cpeople cteach cspeech cpersuad cselling ccaring cteamwk clisten ///
			cstrengt cstamina chands ctools cproduct cspecial corgwork cusepc cfaults ccause ///
			csolutn canalyse cnoerror cmistake cplanme cplanoth cmytime cahead cread ///
			cshort clong cwrite cwritesh cwritelg ccalca cpercent cstats 
			
foreach x of local X{
	recode `x' (6=.)
}
local X skverb sknumber skphys skprofco skplanni skclicom skprobso skcheck 
foreach x of local X{
	recode `x' (3=5) (2=6) (1=7) (0=8)
	recode `x' (4=1) (5=2) (6=3) (7=4) (8=5)
}
rename asex sex
rename aage age
rename awork work
rename b_isco isco88
rename bauto comp
rename bemptype emptype

keep 	dataset crosspid isco88 edlev sex age region emptype bchoice brepeat ///
		bvariety bsuper bme1 bme2 bme3 bme4 cdetail cpeople cteach cspeech ///
		cpersuad cselling ccaring cteamwk clisten cstrengt cstamina chands ///
		ctools cproduct cspecial corgwork cusepc cfaults ccause csolutn ///
		canalyse cnoerror cmistake cplanme cplanoth cmytime cahead cread ///
		cshort clong cwrite cwritesh cwritelg ccalca cpercent cstats ///
		skverb sknumber skphys skprofco skplanni skclicom skprobso skcheck 

drop if dataset <1997
*the reason why we drop previous datasets is that there are no skills variable of interest

*all values are changed so that the range is 0-10, with 10 meaning the use or importance of a skill is higher
recode bchoice bsuper bme1 bme2 bme3 bme4 (1=10) (2=6.66667) (3=3.33333) (4=0)

local recodeList 	brepeat cdetail cpeople cteach cspeech cpersuad cselling ///
					ccaring cteamwk clisten cstrengt cstamina chands ctools cspecial ///
					cproduct corgwork cfaults cusepc ccause csolutn cnoerror canalyse ///
					cmistake cplanme cmytime cplanoth cahead cread cshort clong cwrite ///
					clong cwritelg cwritesh ccalca cpercent cstats 
recode `recodeList'  	(1=0) (1=2.5) (3=5) (4=7.5) (5=10)
recode bvariety       	(1=10) (2=7.5) (3=5) (4=2.5) (5=0)
local X 			skverb sknumber skphys skprofco skplanni skclicom skprobso
foreach x of local X{
replace `x'=`x'*2
}


sort dataset isco88 edlev

*isco88 is the occupation variable of interest because it is the one with finer categories
*edlev is the most simply coded ed variable. it corresponds to nvq uk qualification, which go from 1 to 5. 
*here, 4 level is = 4 and 5 nvq. There are other measures as well in the dataset but they are less clean

*see https://en.wikipedia.org/wiki/National_Vocational_Qualification

*Level 4 is equivalent to bachelors degree
*Level 3 is post high-school education
*Level 2 would be like secondary education
*Level 1 below high-school diploma


/*
*I first perform a factor analysis for all the variables that could be considered skills/tasks. 
*What is in here is arguable. I was conservative in non excluding any of the variables, so there is info
*on how these cahracteristics/tasks/skills matter in one's job, but this was exploratory work, so it might make sense
*to take some of these out. I only show 6 fators because from previous analysis I saw only 6 factors matter.
*I also only show variables that have loadings of at least 0.4 because if lower it is likely not to be relevant for the
*definition of what the factor is. We use oblique rotation because it seems more reasonable to believe that 
*skill are not orthogonal with one another.   
factor bchoice brepeat bvariety bsuper bme1 bme2 bme3 bme4 ///
cpeople cteach cspeech cpersuad cselling ccaring cteamwk clisten cstrengt cstamina chands ctools cproduct ///
cspecial corgwork cusepc cfaults ccause csolutn canalyse cplanme cplanoth cmytime cahead cread ///
cshort clong cwrite cwritesh cwritelg ccalca cpercent cstats ///
skverb sknumber skphys skprofco skplanni skclicom skprobso skcheck, blanks(0.4) factor(6)
rotate, oblique oblimin factor(6) blanks(0.4)

*After a first exploratory run, I exclude variable that have uniqueness >0.6 because this implies
*that they are not "explained" much by the factors, so they are less relevant.  I then predict the 
*values of the 6 factors. 
factor bme2 bme3 cteach cspeech cpersuad  clisten cstrengt cstamina chands ctools ///
cusepc cfaults ccause csolutn canalyse cplanme cplanoth cmytime cahead cread ///
cshort clong cwrite cwritesh cwritelg ccalca cpercent cstats, blanks(0.4) factor(6)
greigen
rotate, oblique oblimin factor(6) blanks(0.4)
predict obl1 obl2 obl3 obl4 obl5 obl6 

*I attempted drawing a triangle graph with the factors obtained above, but there seemed to be too little variation.
*(obviously using a combination of the 6 factors - 1+2+3, 4+5, 6) As Costas pointed out, there might be a way in which we can 
*rescale these variables and solve the issue. I haven't tried that yet.

*I decided then to pick only one of the variables per each relevant group of 1 factor.
*2 ways to do it: 
*A) perform a factor analysis on the subgroups of relevant variables in every factor
*and pick the variable that has the highest loading in the factor component
*B) pick the variable in the subgroups of relevant variables that is most highly correlated 
*to the factor component, they are kind of very similar thought so nothing really changes (row 162)
factor cshort clong cwrite cwritesh cwritelg  
factor cteach cspeech cpersuad  clisten 
factor cplanme cplanoth cmytime cahead bme2 bme3   
factor cfaults ccause csolutn canalyse 
factor ccalca cpercent cstats   
factor cstrengt cstamina chands ctools cusepc  

corr cwritesh obl1  
corr cpersuad obl2  
corr cplanme obl3
corr ccause obl4
corr cpercent obl5   
corr cstrengt obl6  
corr cwritesh cpersuad cplanme ccause cpercent cstrengt

*measures by occupation and year of observation
collapse cwritesh cpersuad cplanme ccause cpercent cstrengt, by(isco88 dataset)
gen f1=(cplanme +cwritesh +cpersuad)/3
gen f2=(cpercent + ccause)/2
gen f3=cstrengt
gen tot=f1+f2+f3
forval x=1/3{
gen fac`x'=f`x'/tot
}
label var fac1 "Communication"
label var fac2 "Analytical"
label var fac3 "Manual"
triplot fac1 fac2 fac3 , y grid() symbol(O Th) msize(tiny tiny) mcolor(gs5 gs10) by(dataset) 

*B) 
corr obl1 obl2 obl3 obl4 obl5 obl6 ///
bme2 bme3 cteach cspeech cpersuad  clisten cstrengt cstamina chands ctools ///
cusepc cfaults ccause csolutn canalyse cplanme cplanoth cmytime cahead cread ///
cshort clong cwrite cwritesh cwritelg ccalca cpercent cstats

corr cshort cspeech cplanme ccause cpercent cstrengt
