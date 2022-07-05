*Importing CPI
import excel "data/raw/cpi.xls", sheet("cpi") firstrow clear

rename quarter date

g cpi20=	cpi/108.4*100
drop cpi

g year=		year(date)
g quarter=	quarter(date)
drop date

save "data/raw/cpi", replace
