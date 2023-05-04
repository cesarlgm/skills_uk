*cleans variables
do "./code/process_SES/clean_SES.do"

do "./code/process_SES/restrict_SES_sample.do" bsoc2000

do "code/process_SES/create_SES_occupation_panel.do"

