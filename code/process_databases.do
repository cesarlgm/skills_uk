*=====================================================================================
*PROCESS DATABASES

*Description: cleans LFS and SES data
*Author: César Garro-Marín
*=====================================================================================

*This file contains the mapping between qualifications and educational classifications
*in the SES
do "code/reconstructionEdlev.do"

*LIKELY DEPRECATED: This file looks at crosswalks between the occupational classifications
do "code/saveOccupationCrossWalks.do"


*Processing of labor force surveys
do "code/process_LFS/process_LFS_database.do" 

*Processing SES databases
do "code/process_SES/process_SES_database.do" 




