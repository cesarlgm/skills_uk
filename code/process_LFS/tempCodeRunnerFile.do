    use "./data/temporary/LFS_industry_occ_file", clear


    gcollapse (sum) people obs, by($occupation  year $education)

