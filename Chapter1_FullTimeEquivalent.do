*******************************************************************************
* Fact Book
* Chapter: 1 Enrollment
* 
* Output: 
* 	- Enrollment_fall_time_equivalent
* 	- Enrollment_fall_time_equivalent_beloit
*******************************************************************************


***********************************************
* Set up
***********************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here


** The rest of these globals should work independent of the path above
global input "$root/Stata/Chapter 1 Enrollment/input"
global temp "$root/Stata/Chapter 1 Enrollment/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"


*************************************************
* Import and prepare the current year data (CDS)
*************************************************

*Import and prepare current year data
import excel "$root/Stata/Chapter 1 Enrollment/input/Admission and enrolled 3.xlsx", clear firstrow
keep UnitID InstitutionName Full*

** Restrict to comparison schools 
keep if inlist(UnitID,$comparison)

**rename the variable
gen FTEFall2023 = Fulltimeequivalentfallenroll
drop Fulltimeequivalentfallenroll
keep UnitID FTEFall2023
sort UnitID

save "$root/Stata/Chapter 1 Enrollment/temp/FTE_current_year.dta", replace

/* 
Note: I edited from Admissions and Enrolled directly because FTE is directly calculated here for 2023,
and the Fall2024 data was not available in HEDS either. You might have to take the data out of HEDS Comparison file 
for the other years.
*/

************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************


* Import and prepare the historical data
import excel "$input/Admission and enrolled 3.xlsx", firstrow clear

** Restrict to comparison schools 
keep if inlist(UnitID,$comparison)

** Label FTE
rename Fulltimeequivalentfallenroll FTEFall2023
rename I FTEFall2022
rename N FTEFall2021
rename S FTEFall2020
rename X FTEFall2019
rename AC FTEFall2018
rename AH FTEFall2017
rename AM FTEFall2016
rename AR FTEFall2015
rename AW FTEFall2014

keep UnitID InstitutionName FTE*

save "$root/Stata/Chapter 1 Enrollment/temp/FTE_historical.dta", replace


**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$root/Stata/Chapter 1 Enrollment/temp/FTE_historical.dta", clear
merge 1:1 UnitID using "$root/Stata/Chapter 1 Enrollment/temp/FTE_current_year.dta"

drop _merge

* Rename Institution name
rename InstitutionName Name
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Allegheny" if Name=="Allegheny College"
replace Name="Austin" if Name=="Austin College"
replace Name="Beloit" if Name=="Beloit College"
replace Name="Centre" if Name=="Centre College"
replace Name="Cornell" if Name=="Cornell College"
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Juniata" if Name=="Juniata College"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Knox" if Name=="Knox College"
replace Name="Lawrence" if Name=="Lawrence University"
replace Name="Linfield" if Name=="Linfield College-McMinnville Campus"
replace Name="Millsaps" if Name=="Millsaps College"
replace Name="Ohio Wesleyan" if Name=="Ohio Wesleyan University"
replace Name="Randolph-Macon" if Name=="Randolph-Macon College"
replace Name="Rhodes" if Name=="Rhodes College"
replace Name="Ursinus" if Name=="Ursinus College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
replace Name="Wooster" if Name=="The College of Wooster"
replace Name="Wofford" if Name=="Wofford College"
compress Name

aorder
order UnitID Name

** Save final data for both graphs
save "$root/Stata/Chapter 1 Enrollment/temp/FTE.dta", replace


*************************************
* Graph: Current year, all schools
*************************************

use "$root/Stata/Chapter 1 Enrollment/temp/FTE.dta", clear

* Drop out any school with no current year data (missing in CDS)
drop if missing(FTEFall2023)

* Graph
* Graph: Full-Time Equivalent Fall Enrollment, 2023
graph hbar (asis) FTEFall2023, over(Name, sort(1) label(labsize(vsmall))) ///
    blabel(bar, pos(inside) color(white) size(vsmall) format(%9.0f)) ///
    title("Full-Time Equivalent Fall Enrollment, 2023", color(black)) ///
    ytitle("Number of Students") ///
    scheme(colorblind) ///
    note("Source: Common Data Set", size(small)) ///
    bar(1, color("0 56 107") fintensity(100)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    ysize(6) xsize(10)


graph export "$png/Enrollment_FTE_current.png", as(png) replace
graph export "$pdf/Enrollment_FTE_current.pdf", as(pdf) replace

**********************************
* Graph: Over time for Beloit
**********************************


use "$root/Stata/Chapter 1 Enrollment/temp/FTE.dta", clear
keep if Name == "Beloit"

* Reshape data long, for easier graphing
reshape long FTEFall, i(UnitID) j(year)


*Remove data that are more than 10 years old
drop if year <= 201


*Graph
graph bar (asis) FTEFall, over (year, sort (year)) ///
  blabel(bar, pos(inside) color(white) size(2.5) format(%9.0f)) ///
  title("Beloit Full-Time Equivalent Fall Enrollment", color(black)) ///
  ytitle("Number of Students") ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Source: IPEDS; Common Data Set") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))
  
graph export "$png/Enrollment_FTE_historical_beloit.png", as(png) replace
graph export "$final/Enrollment_FTE_historical_beloit.pdf", as(pdf) replace



** END OF FILE
