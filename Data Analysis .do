clear all
set more off
capture log close

global dirdata "/Users/benreynolds/Documents/Dissertation/data/NTS/stata"
global dirresults "/Users/benreynolds/Documents/Dissertation/results"
cd "/Users/benreynolds/Documents/Dissertation"

log using "$dirresults/analysis.log", replace  

use "$dirresults/masterdata", clear

*Summary Statistics and Correlation Matrix
estpost sum uber population area2 pop_density gdp unemploy gdhi, quietly 
est sto sum1
esttab sum1 using "$dirresults/sum1.rtf", cells("mean sd min max count") ///
	noobs replace /// 
	title("Table 2: Summary Statistics of Control Variables") ///
	coeflabel(uber "Uber" population "Population" area2 "Area Km^2" ///
		pop_density "Population Density" gdp "GDPpc" unemploy /// 
			"Unemployment Rate" gdhi "GDHI") 

estpost sum total_journey3 bus3 rail3 urban_rail3, quietly
est sto sum2
esttab sum2 using "$dirresults/sum2.rtf", cells("mean sd min max count") ///
	 noobs replace ///
	 title("Table 1: Summary Statistics of Dependent Variables") coeflabel( ///
		total_journey3 "Total Journeys (100,000)" bus3 "Bus (100,000)" ///
			rail3 "Rail(100,000)" urban_rail3 "Urban Rail (100,000)") dp(3)


// Correlation Matrix		
estpost correlate total_journey uber unemploy gdp gdhi pop_density, /// 
	matrix
esttab . using "$dirresults/cor_matrix1.rtf", replace unstack compress nostar ///
	not title( ///
	"Figure 1: Cross-Correlation between total journeys and control variables") ///
	coeflabel(total_journey "Total Journeys" uber "Uber" ///
		unemploy "Unemployment Rate" gdp "GDP" gdhi "GDHI" ///
		pop_density "Population Density") dp(3)

estpost correlate unemploy gdp gdhi pop_density, matrix 
esttab . using "$dirresults/cor_matrix2.rtf", replace unstack compress nostar ///
	not title("Figure 2: Cross-Correlations between control variables") ///
	coeflabel(uber "Uber" unemploy "Unemployment Rate" gdp "GDP" gdhi "GDHI" ///
		pop_density "Population Density")
			


esttab cor_matrix using "$dirresults/cor_matrix.rtf", replace 


*Telling stata that dataset is panel 
xtset region2 year


*Graphs
ssc install blindschemes, replace all
set scheme plottig
//line graphs		
graph set window fontface "CMU Serif"
xtline total_journey3 if region2 !=3, i(region2) t(year) overlay ///
	title("Figure 1: Total Journeys by region") ///
	ytitle("Total Journeys") xtitle("Year") ///
	note("Graph of total journeys made per(100,000)" ///
	"London's Total Journey found in appendix Figure A2")
	
xtline total_journey3 if region2 !=3, i(region2) t(year) overlay ///
	title("Figure A1: Total Journeys by region") ///
	ytitle("Total Journeys") xtitle("Year") ///
	note("Graph of total journeys made per(100,000)" ///
	"London's Total Journey found in appendix Figure A2")
	



xtline total_journey3 if region2 ==3 , i(region2) t(year) ///
	title("Figure A2: London") ///
	ytitle("Total Journeys in London") xtitle("Year") ///
	note("Graph of total journeys made per(100,000)")
export graph "$dirresults/figure4.png"
		
//Histograms
histogram log_gdp, normal xtitle("Log GDP") ///
	title("Figure A3: Histogram of Log GDP") 
histogram log_gdhi, normal xtitle("Log GDHI") ///
	title("Figure A4: Histogram Log GDHI")
histogram log_unemploy, normal xtitle("Log Unemployment") ///
	title("Figure A5: Histogram Log Unemployment Rate")
histogram log_density, normal xtitle("Log Pop Density") ///
	title("Figure A6: Histogram Log Population Density")


			
			

*Regression of total trips
quietly xtreg log_total i.uber log_gdp log_density log_unemploy log_gdhi, re
est store random_effects

quietly xtreg log_total i.uber log_gdp log_density log_unemploy log_gdhi, fe
est store fixed_effects

hausman fixed_effects random_effects


quietly xtreg log_total i.uber log_gdp, vce(r) fe
est sto m1

quietly xtreg log_total i.uber log_gdp log_density, vce(r) fe 
est sto m2

quietly xtreg log_total i.uber log_gdp log_density log_unemploy, ///
	vce(r) fe
est sto m3

quietly xtreg log_total i.uber log_gdp log_density log_unemploy log_gdhi ///
	, vce(r) fe
est sto m4

esttab m1 m2 m3 m4 using "$dirresults/reg_results.rtf", ///
	title("Table 3: Effect on Uber on Total Passenger Journeys") ///
	coeflabel(log_gdp "GDPpc" log_density "Pop Density" log_unemploy ///
		"Unemployment" log_gdhi "GDHI") se ar2 replace onecell compress ///
	drop(0.uber)
		


*Breaking down by the three different modes

xtreg log_bus i.uber log_gdp log_density log_unemploy log_gdhi, vce(r) fe
est sto bus_model

xtreg log_rail i.uber log_gdp log_density log_unemploy log_gdhi, vce(r) fe
est sto rail_model

xtreg log_urban i.uber log_gdp log_density log_unemploy log_gdhi, vce(r) fe
est sto urban_model

esttab m4 bus_model rail_model urban_model using "$dirresults/mode_results.rtf" ///
	, title("Table 4: Effect on Uber by Transit Mode") ///
	mtitles("Total" "Bus" "Rail" "Urban Rail") ///
	coeflabel(log_gdp "GDPpc" log_density "Pop Density" log_unemploy ///
		"Unemployment" log_gdhi "GDHI") replace onecell ar2 se compress ///
	drop(0.uber)
	
	






sort region2
by region2: reg log_total i.uber log_gdp log_density log_unemploy log_gdhi, ///
	vce(r)
est sto total_region

by region2: reg log_bus i.uber log_gdp log_density log_unemploy log_gdhi, ///
	vce(r) 
est sto bus_region
	
by region2: reg log_rail i.uber log_gdp log_density log_unemploy log_gdhi, ///
	vce(r)
est sto rail_region

by region2: reg log_urban i.uber log_gdp log_density log_unemploy log_gdhi, ///
	vce(r) 
est sto urban_region


esttab total_region bus_region rail_region urban_region using ///
	"$dirresults/region_var.rtf", keep(1.uber) onecell replace 






save using "$dirresults/results_data.dta", replace 
