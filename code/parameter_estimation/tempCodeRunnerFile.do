

global table_options  booktabs noomit nobase  stat(F r2 N) mtitles("Manual" "Social" "Routine") b(2) se(2) replace
esttab fs_*_1 using "results/tables/instrument_lag_table_1.tex", keep(*_1) $table_options
esttab fs_*_2 using "results/tables/instrument_lag_table_2.tex", keep(*_2) $table_options
esttab fs_*_3 using "results/tables/instrument_lag_table_3.tex", keep(*_3) $table_options

