*******************************************************************************
* Fact Book
* Chapter: 4 Full-Time Faculty
* 
* Output: 
*	- Faculty_ACM_full_salary_adjusted_2007-2016
*	- Faculty_ACM_assistant_salary_adjusted_2007-2016
*	- Faculty_ACM_associate_salary_adjusted_2007-2016
*	- Faculty_ACM_schools_full_professor_salaries_2017
*	- Faculty_ACM_schools_assistant_professor_salaries_2017
*	- Faculty_ACM_schools_associate_professor_salaries_2017
*
*******************************************************************************


version 14
clear all
set more off
capture log close

global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 4 Full-Time Faculty/input"
global temp "$root/Stata\Chapter 4 Full-Time Faculty/temp"
global png "$root/Stata\Chapter 4 Full-Time Faculty/_png"
global wmf "$root/Stata\Chapter 4 Full-Time Faculty/_wmfs"
global final "$root/Stata\Chapter 4 Full-Time Faculty/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
local comparison 138600 210669 222983 238333 156408 153162 145646 213251 170532 146427 239017 209065 175980 204909 233295 221351 206589 216524 168281 218973
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
local acm 238333 173258 153144 126678 153162 153384 146427 146481 239017 153834 173902 147341 239628 174844
global acm "238333, 173258, 153144, 126678, 153162, 153384, 146427, 146481, 239017, 153834, 173902, 147341, 239628, 174844"
local beloit 238333
global beloit "238333"

****************************************************
* Full professors: Average Salary for ACM schools
****************************************************


*** Import and prepare the data 
import excel using "$input/All Professors Salary.xlsx", sheet("All Professors") firstrow cellrange(A2)

*** Keep the data of comparison schools only 
keep if inlist(UnitID,$acm) 
keep UnitID InstitutionName fullwage* assocwage* assistwage* proftotal*

*rename 
rename InstitutionName Name

replace Name="Beloit" if  Name=="Beloit College"
replace Name="Carleton" if  Name=="Carleton College" 
replace Name="Coe" if  Name=="Coe College" 
replace Name="Colorado" if  Name=="Colorado College" 
replace Name="Cornell" if  Name=="Cornell College" 
replace Name="Grinnell" if  Name=="Grinnell College" 
replace Name="Knox" if  Name=="Knox College" 
replace Name="Luther" if  Name=="Luther College" 
replace Name="Lake Forest" if  Name=="Lake Forest College" 
replace Name="Lawrence" if  Name=="Lawrence University" 
replace Name="Macalester" if  Name=="Macalester College" 
replace Name="Monmouth" if  Name=="Monmouth College" 
replace Name="Ripon" if  Name=="Ripon College" 
replace Name="St Olaf" if  Name=="St Olaf College" 

*** Create salary in real $ using CPI For All Urban Consumers - July*

reshape long fullwage, i(UnitID) j(Year)
rename fullwage Salary

gen inflation=.

replace inflation =233.916 if Year==2014
replace inflation =238.654 if Year==2015
replace inflation =240.628 if Year==2016
replace inflation =244.786 if Year==2017
replace inflation =252.006 if Year==2018
replace inflation =256.571 if Year==2019
replace inflation =259.101 if Year==2020
replace inflation =273.003 if Year==2021
replace inflation =296.276 if Year==2022
replace inflation =305.691 if Year==2023

*** Create inflation relative to June 2016
gen inflator = 305.691/inflation

gen real_salary=Salary*inflator/1000

*** Create median variable
egen med = median(real_salary), by (Year)
sort Year


*** Make charts adjusted for inflation *
graph twoway (scatter real_salary Year if UnitID!= 238333) (scatter real_salary Year if UnitID== 238333)(connected med Year, connect(direct)), ///
	legend(label(1 "ACM Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle("Salary ($, thousands)") ///
	title("Average Full Professor Salaries, Inflation Adjusted", color(black)) ///
	subtitle("ACM Schools") ///
	xtitle("") ///
	xlabel(2014(1) 2023) ///
	note("Source: IPEDS") ///
	graphregion(fcolor(white)) ///
	scheme(s2color) ///
	
  
graph export "$png/Faculty_ACM_full_salary_adjusted.png", as(png) replace
graph export "$wmf/Faculty_ACM_full_salary_adjusted.wmf", as(wmf) replace
graph export "$final/Faculty_ACM_full_salary_adjusted.pdf", as(pdf) replace

clear


****************************************
*Assistant professors: Average Salary for ACM schools
****************************************

*** Import and prepare the data 
import excel using "$input/All Professors Salary.xlsx", sheet("All Professors") firstrow cellrange(A2)

*** Keep the data of comparison schools only 
keep if inlist(UnitID,$acm) 
keep UnitID InstitutionName fullwage* assocwage* assistwage* proftotal*

*rename 
rename InstitutionName Name
replace Name="Beloit" if  Name=="Beloit College"
replace Name="Carleton" if  Name=="Carleton College" 
replace Name="Coe" if  Name=="Coe College" 
replace Name="Colorado" if  Name=="Colorado College" 
replace Name="Cornell" if  Name=="Cornell College" 
replace Name="Grinnell" if  Name=="Grinnell College" 
replace Name="Knox" if  Name=="Knox College" 
replace Name="Luther" if  Name=="Luther College" 
replace Name="Lake Forest" if  Name=="Lake Forest College" 
replace Name="Lawrence" if  Name=="Lawrence University" 
replace Name="Macalester" if  Name=="Macalester College" 
replace Name="Monmouth" if  Name=="Monmouth College" 
replace Name="Ripon" if  Name=="Ripon College" 
replace Name="St Olaf" if  Name=="St Olaf College" 

*** Create salary in real $ using BLS Urban CPI for June 2016 *

reshape long assistwage, i(UnitID) j(Year)
rename assistwage Salary

gen inflation=.

replace inflation =233.916 if Year==2014
replace inflation =238.654 if Year==2015
replace inflation =240.628 if Year==2016
replace inflation =244.786 if Year==2017
replace inflation =252.006 if Year==2018
replace inflation =256.571 if Year==2019
replace inflation =259.101 if Year==2020
replace inflation =273.003 if Year==2021
replace inflation =296.276 if Year==2022
replace inflation =305.691 if Year==2023

*** Create inflation relative to June 2023
gen inflator = 305.691/inflation

gen real_salary=Salary*inflator/1000

*** Create median variable
egen med = median(real_salary), by (Year)
sort Year

*** Make charts adjusted for inflation *

graph twoway (scatter real_salary Year if UnitID!= 238333) (scatter real_salary Year if UnitID== 238333)(connected med Year, connect(direct)), ///
	legend(label(1 "ACM Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle("Salary ($, thousands)") ///
	title("Average Assistant Professor Salaries, Inflation Adjusted", color(black)) ///
	subtitle("ACM Schools") ///
	xtitle("") ///
	xlabel(2014(1) 2023) ///
	note("Source: IPEDS") ///
	graphregion(fcolor(white)) ///
	scheme(s2color) ///
  
  
graph export "$png/Faculty_ACM_assistant_salary_adjusted.png", as(png) replace
graph export "$wmf/Faculty_ACM_assistant_salary_adjusted.wmf", as(wmf) replace
graph export "$final/Faculty_ACM_assistant_salary_adjusted.pdf", as(pdf) replace

clear


****************************************
* Associate professors: Average Salary for ACM schools
****************************************


*** Import and prepare the data 
import excel using "$input/All Professors Salary.xlsx", sheet("All Professors") firstrow cellrange(A2)

*** Keep the data of comparison schools only 
keep if inlist(UnitID,$acm) 
keep UnitID InstitutionName fullwage* assocwage* assistwage* proftotal*

*rename 
rename InstitutionName Name

replace Name="Beloit" if  Name=="Beloit College"
replace Name="Carleton" if  Name=="Carleton College" 
replace Name="Coe" if  Name=="Coe College" 
replace Name="Colorado" if  Name=="Colorado College" 
replace Name="Cornell" if  Name=="Cornell College" 
replace Name="Grinnell" if  Name=="Grinnell College" 
replace Name="Knox" if  Name=="Knox College" 
replace Name="Luther" if  Name=="Luther College" 
replace Name="Lake Forest" if  Name=="Lake Forest College" 
replace Name="Lawrence" if  Name=="Lawrence University" 
replace Name="Macalester" if  Name=="Macalester College" 
replace Name="Monmouth" if  Name=="Monmouth College" 
replace Name="Ripon" if  Name=="Ripon College" 
replace Name="St Olaf" if  Name=="St Olaf College" 


** Create salary in real $ using BLS Urban CPI for July 2016 *

reshape long assocwage, i(UnitID) j(Year)
rename assocwage Salary

gen inflation=.

replace inflation =233.916 if Year==2014
replace inflation =238.654 if Year==2015
replace inflation =240.628 if Year==2016
replace inflation =244.786 if Year==2017
replace inflation =252.006 if Year==2018
replace inflation =256.571 if Year==2019
replace inflation =259.101 if Year==2020
replace inflation =273.003 if Year==2021
replace inflation =296.276 if Year==2022
replace inflation =305.691 if Year==2023

*** Create inflation relative to July 2023
gen inflator = 305.691/inflation

gen real_salary=Salary*inflator/1000

*** Create median variable
egen med = median(real_salary), by (Year)
sort Year

*** Make charts adjusted for inflation 

graph twoway (scatter real_salary Year if UnitID!= 238333) (scatter real_salary Year if UnitID== 238333)(connected med Year, connect(direct)), ///
	legend(label(1 "ACM Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle("Salary ($, thousands)") ///
	title("Average Associate Professor Salaries, Inflation Adjusted", color(black)) ///
	subtitle("ACM Schools") ///
	xtitle("") ///
	xlabel(2014(1) 2023) ///
	note("Note: Inflation adjustment using Bureau of Labor Statistics: CPI-All Urban Consumers in 2023" "Source: IPEDS") ///
	graphregion(fcolor(white)) ///
	scheme(s2color) ///
  
  
graph export "$png/Faculty_ACM_associate_salary_adjusted.png", as(png) replace
graph export "$wmf/Faculty_ACM_associate_salary_adjusted.wmf", as(wmf) replace
graph export "$final/Faculty_ACM_associate_salary_adjusted.pdf", as(pdf) replace

clear


***********************************************
* 2023 Average Full Professor Salaries
*********************************************** 
/*
For this part of the code, this year we did it with IPEDS data cause the factbook was made later into the year, so we had the data. But in other years, take the source from AAUP instead. Thank you and Good luck! -Sahil
*/


*** Import and prepare the data 
import excel using "$input/All Professors Salary.xlsx", sheet("All Professors") firstrow cellrange(A2)

*** Keep the data of comparison schools only 
keep if inlist(UnitID,$acm) 
keep UnitID InstitutionName fullwage2023 assocwage2023 assistwage2023 proftotal2023


rename Institution Name
replace Name="Beloit" if  Name=="Beloit College"
replace Name="Carleton" if  Name=="Carleton College" 
replace Name="Coe" if  Name=="Coe College" 
replace Name="Colorado" if  Name=="Colorado College" 
replace Name="Cornell" if  Name=="Cornell College" 
replace Name="Grinnell" if  Name=="Grinnell College" 
replace Name="Knox" if  Name=="Knox College" 
replace Name="Luther" if  Name=="Luther College" 
replace Name="Lake Forest" if  Name=="Lake Forest College" 
replace Name="Lawrence" if  Name=="Lawrence University" 
replace Name="Macalester" if  Name=="Macalester College" 
replace Name="Monmouth" if  Name=="Monmouth College" 
replace Name="Ripon" if  Name=="Ripon College" 
replace Name="St Olaf" if  Name=="St Olaf College" 


* graph
graph hbar (asis) fullwage2023, over(Name, sort(fullwage2023)) ///
    blabel(bar, pos(inside) color(white) size(2.5) format(%12.0fc )) ///
    title("Average Full Professor Salaries, 2023", color(black)) ///
	subtitle("ACM Schools") ///
	scheme(colorblind) ///
	note("Source: IPEDS") ///
	graphregion(fcolor(white)) ///
	yscale (extend) ///
	ytitle("Salary ($)") ///
    bar(1, color("0 56 107") fintensity(100)) 

graph hbar (asis) fullwage2023, over(Name, sort(fullwage2023)) ///
    blabel(bar, pos(inside) color(white) size(2.5) format(%12.0fc)) ///
    title("Average Full Professor Salaries, 2023", color(black)) ///
    subtitle("ACM Schools") ///
    scheme(colorblind) ///
    note("Source: IPEDS") ///
    graphregion(fcolor(white)) ///
    yscale(extend) ///
    ytitle("Salary ($)") ///
    ylabel(0(25000)150000, format(%12.0fc)) ///
    bar(1, color("0 56 107") fintensity(100))
	

	
graph export "$png/Faculty_ACM_schools_full_professor_salaries.png", as(png) replace
graph export "$wmf/Faculty_ACM_schools_full_professor_salaries.wmf", as(wmf) replace
graph export "$final/Faculty_ACM_schools_full_professor_salaries.pdf", as(pdf) replace

*scheme(s2color) ///


* graph
graph hbar (asis) assistwage2023, over(Name, sort( assistwage2023)) ///
    blabel(bar, pos(inside) color(white) size(2.5) format(%12.0fc)) ///
    title("Average Assistant Professor Salaries, 2023", color(black)) ///
    subtitle("ACM Schools") ///
	note("Source: IPEDS") ///
	scheme(colorblind) ///
	graphregion(fcolor(white)) ///
	yscale (extend) ///
	ytitle("Salary ($)") ///
	ylabel(0(20000)80000, format(%12.0fc)) ///
    bar(1, color("0 56 107") fintensity(100)) 

graph export "$png/Faculty_ACM_schools_assistant_professor_salaries.png", as(png) replace
graph export "$wmf/Faculty_ACM_schools_assistant_professor_salaries.wmf", as(wmf) replace
graph export "$final/Faculty_ACM_schools_assistant_professor_salaries.pdf", as(pdf) replace


* graph
graph hbar (asis) assocwage2023, over(Name, sort(assocwage2023)) ///
    blabel(bar, pos(inside) color(white) size(2.5) format(%12.0fc)) ///
    title("Average Associate Professor Salaries, 2023", color(black)) ///
    subtitle("ACM Schools") ///
	note("Note: Inflation adjustment using Bureau of Labor Statistics: CPI-All Urban Consumers in 2023" "Source: IPEDS") ///
	scheme(colorblind) ///
	graphregion(fcolor(white)) ///
	yscale (extend) ///
	ytitle("Salary ($)") ///
	ylabel(0(25000)120000, format(%12.0fc)) ///
    bar(1, color("0 56 107") fintensity(100)) 

graph export "$png/Faculty_ACM_schools_associate_professor_salaries.png", as(png) replace
graph export "$wmf/Faculty_ACM_schools_associate_professor_salaries.wmf", as(wmf) replace
graph export "$final/Faculty_ACM_schools_associate_professor_salaries.pdf", as(pdf) replace

clear
