*******************************************************************************
* Fact Book
* Chapter: 1 Enrollment
* 
* Output: 
*	-	Enrollment_FTFT_current
*	- 	Enrollment_FTFT_historical_beloit

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
global input "$root/Stata\Chapter 1 Enrollment/input"
global temp "$root/Stata\Chapter 1 Enrollment/temp"
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
import excel "$cds/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part C First-Year Admission") firstrow cellrange(B23) clear
keep if inlist(UnitID,$comparison)
keep UnitID N
gen Fall2023 = N
drop N
sort UnitID
save "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen_current_year.dta", replace

//This part of the code is only relevant when 2024 data becomes available through the HEDS

************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************

import excel "$root/Stata/Chapter 1 Enrollment/input/Admission and enrolled 3.xlsx", clear firstrow
keep UnitID InstitutionName Enrolledtotal*
sort UnitID
keep if inlist(UnitID,$comparison)
rename EnrolledtotalADM* Fall*
rename EnrolledtotalIC* Fall*
rename *_RV *
save "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen_historical.dta", replace

*** NOTE: The IPEDS variable names might change from year to year, but
*			 you are looking for the variables that mean first-time freshman
*			 and match the first column here: 
*       https://www.beloit.edu/live/files/1009-graduation-and-persistence-rates-2024-25
* For 2024, the one you want is: Enrolled total (ADM2023_RV)

**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen_historical.dta", clear
merge 1:1 UnitID using "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen_current_year.dta"
drop _merge

* Rename Institution name
drop Fall2013 Fall2012
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
save "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen.dta", replace

*************************************
* Graph: Current year, all schools
*************************************

use "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen.dta", replace

* Drop out any school with no current year data (missing in CDS)
drop if missing(Fall2023)

* Graph
graph hbar (asis) Fall2023, over(Name, sort(1)) ///
    blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
    title("Full-Time Freshmen Fall Enrollment, 2023", color(black)) ///
    ytitle("Number of Students") ///
    scheme(colorblind) ///
    note("Source: Common Data Set", size(small)) ///
    bar(1, color("0 56 107") fintensity(100)) ///
    graphregion(color(white) margin(medium)) ///
    plotregion(margin(medium)) ///
    ysize(6) xsize(10) //

graph export "$png/Enrollment_FTFT_current.png", as(png) replace
graph export "$pdf/Enrollment_FTFT_current.pdf", as(pdf) replace


**********************************
* Graph: Over time for Beloit
**********************************

use "$root/Stata/Chapter 1 Enrollment/temp/FirstTimeFreshmen.dta", clear
keep if Name == "Beloit"

* Reshape data long, for easier graphing
reshape long Fall, i(UnitID) j(year)

* Drop data older than 10 years
drop if year <= 2012


graph bar (asis) Fall, over (year, sort (year)) ///
  blabel(bar, pos(inside) color(white) size(2.5) format(%9.0f)) ///
  title("Beloit Full-Time Freshmen Fall Enrollment", color(black)) ///
  ytitle("Number of Students") ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Source: IPEDS; Common Data Set") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Enrollment_FTFT_historical_beloit.png", as(png) replace
graph export "$pdf/Enrollment_FTFT_historical_beloit.pdf", as(pdf) replace

** END OF FILE
