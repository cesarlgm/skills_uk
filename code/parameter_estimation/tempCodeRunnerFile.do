eststo clear
eststo uw: regress y_var sums i.ee_group_id
eststo w: regress y_var sums i.ee_group_id  [aw=weight2]