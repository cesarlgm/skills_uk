*===============================================================================
*PROCESSING SES DATA
*===============================================================================
local occupation 		`1'
local filter			`2'
local obsThresh			`3'
local aggregateSOC		`4'
local educationType		`5'
local chosen_def		`6'


*cleans variables
do "./code/process_SES/clean_SES.do"

do "./code/process_SES/restrict_SES_sample.do" bsoc2000


do "code/process_SES/create_SES_occupation_panel.do"


*This do file creates the skills dataset
do "code/process_SES/select_SES_skills.do"   bsoc2000 	

do "code/process_SES/skill_us_regressions.do" 



/*
*This code creates a skill variable list
do "./code/process_SES/variableList.do"   bsoc2000  `filter' `obsThresh' ///
	`aggregateSOC' `educationType' 	

*Exploring definition of computer use	
do "code/3_sesAnalysis/graphsRoutinePCUse.do"    bsoc2000  `filter' `aggregateSOC' ///
	`educationType'

do "code/3_sesAnalysis/occRoutinePCUse.do"    bsoc2000  `filter' `aggregateSOC' ///
	`educationType'
	
*Compares how the different measures of computer use perform within job
do "code/3_sesAnalysis/regressionsRoutinePCUse.do"    `occupation'  `educationType' ///
	`aggregateSOC'

do "code/3_sesAnalysis/pcUseTables.do"    bsoc2000  `filter' `aggregateSOC' ///
	`educationType'


*This creates dataset for skill use triangles
do "code/3_sesAnalysis/skillUseTriangles.do"   bsoc2000  `filter' `obsThresh' ///
	`aggregateSOC' `educationType'
*/

do "code/3_sesAnalysis/create_average_use_table.do"   bsoc2000  `educationType' ///
	`aggregateSOC' 0

do "code/3_sesAnalysis/create_average_use_table.do"   bsoc2000  `educationType' ///
	`aggregateSOC' 1
	
/*
do "code/3_sesAnalysis/create_did_regressions.do"  `occupation'  `educationType' ///
	`aggregateSOC' `chosen_def'
	

*This part creates the standard regressions
do "code/3_sesAnalysis/createSESSkillRegressions.do"  `occupation'  `educationType' ///
	`aggregateSOC' 0

do "code/3_sesAnalysis/createSESSkillRegressionsFull.do"  `occupation'  `educationType' ///
	`aggregateSOC' 0

do "code/3_sesAnalysis/createSESSkillRegressionsPooled.do"  `occupation'  `educationType' ///
	`aggregateSOC' 0
/*
do "code/3_sesAnalysis/numObservationTables.do"  `occupation'  `educationType' ///
	`aggregateSOC'
