clear all
set more off
capture log close

global dirdata "/Users/benreynolds/Documents/Dissertation/data/NTS/stata"
global dirresults "/Users/benreynolds/Documents/Dissertation/results"
cd "/Users/benreynolds/Documents/Dissertation"

log using "$dirresults/data_clean.log", replace
import excel using "/Users/benreynolds/Documents/Dissertation/Master_Data", ///
 sheet("Sheet1") firstrow case(lower) clear

*Data cleanup


encode region, generate(region2)

replace lightrailjourney = 0 if lightrailjourney == -1
replace underground = 0 if underground == -1
gen urban_rail = lightrailjourney + underground
rename busjourney bus
rename railjourney rail 
rename uberpresent uber

gen bus2 = bus*1000000
gen rail2 = rail*1000
gen urban_rail2 = urban_rail*1000000
gen total_journey=bus2+rail2+urban_rail2
gen total_journey2 = bus2+rail2+urban_rail2

gen bus3 = bus2/100000
gen rail3 = rail2/100000
gen urban_rail3= urban_rail2/100000
replace urban_rail3 = . if urban_rail3==0
gen total_journey3 = total_journey2/100000
rename unemploymentrate unemploy


*Control Variables 
gen area2 = 0
replace area2 = 15607 if region2 == 1
replace area2 = 19109 if region2 == 2
replace area2 = 1572 if region2 == 3
replace area2 = 8573 if region2 == 4
replace area2 = 14106 if region2 == 5
replace area2 = 19069 if region2 == 6
replace area2 = 23837 if region2 == 7
replace area2 = 12998 if region2 == 8
replace area2 = 15408 if region2 == 9
label var area2 "Area km^2"
replace gdp = gdp*1000000
rename populationestimates population
replace population = population*1000000
label var population "Population Estimates"
gen pop_density = population/area2
label var pop_density "Population Density"
replace gdp = gdp/population 
*Logging Control Variables
gen log_gdp = ln(gdp)
gen log_unemploy = ln(unemploy)
gen log_pop = ln(population)
gen log_density =ln(pop_density)
gen log_area2 = ln(area2)
gen log_gdhi = ln(gdhi)


*Logging Dependent Variables 

gen log_bus = ln(bus2)
gen log_urban= ln(urban_rail3)
gen log_rail = ln(rail2)
gen log_total = ln(total_journey2)



save "$dirresults/masterdata.dta", replace 



