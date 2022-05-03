    use "./data/temporary/LFS_industry_occ_file", clear


    tab $education year if inlist(year, 2001,2017) [aw=people], col nofreq

    gcollapse (sum) people obs, by($occupation  year $education)

    egen total_people=sum(people), by(year $occupation)

    generate empshare=people/total_people