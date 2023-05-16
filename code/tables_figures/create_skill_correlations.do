*Correlation all variables
do "code/process_SES/save_file_for_minimization.do" $education

rename $education education

foreach variable in $routine {
    replace `variable'=1-`variable'
}

pwcorr $manual $abstract $routine $social


