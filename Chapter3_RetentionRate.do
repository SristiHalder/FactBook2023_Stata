*******************************************************************************
* Fact Book
* Chapter: 3 Student Experience
* 
* Output: 
*	- StudentEx_retention_rate_historical
*	- StudentEx_retention_rate_current
*
*******************************************************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 3 Student Experience/input"
global temp "$root/Stata\Chapter 3 Student Experience/temp"
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

import excel "$root/Stata/Chapter 3 Student Experience/input/Retention Data IPEDS.xlsx", cellrange(B2) firstrow clear 
keep if inlist(UnitID,$comparison)
keep UnitID InstitutionName retention_2023
gen stufacratio_2023 = StudenttofacultyratioEF2023
drop StudenttofacultyratioEF2023

**Clean data to merge all the same UnitID
collapse (mean) retention_2023, by(UnitID)
save "$root/Stata/Chapter 3 Student Experience/temp/Retention_current.dta", replace


************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************

*Import Data
import excel "$input/Retention Data IPEDS.xlsx", cellrange(B2) firstrow clear 
keep if inlist(UnitID,$comparison) 
sort UnitID
keep UnitID InstitutionName retention* 

**Clean data to merge all the same UnitID
  collapse (firstnm) InstitutionName (mean) retention*, by(UnitID)
	
save "$root/Stata/Chapter 3 Student Experience/temp/Retention_historical.dta", replace

**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$root/Stata/Chapter 3 Student Experience/temp/Retention_historical.dta"
merge 1:1 UnitID using "$root/Stata/Chapter 3 Student Experience/temp/Retention_current.dta" 
drop _merge


** Format names for graphing
rename InstitutionName Name 
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Cornell" if Name=="Cornell College"
replace Name="Juniata" if Name=="Juniata College"
replace Name="Linfield" if Name=="Linfield University-McMinnville Campus"
replace Name="Wooster" if Name=="The College of Wooster"
replace Name="Allegheny" if Name=="Allegheny College"
replace Name="Millsaps" if Name=="Millsaps College"
replace Name="Ohio Wesleyan" if Name=="Ohio Wesleyan University"
replace Name="Randolph-Macon" if Name=="Randolph-Macon College"
replace Name="Ursinus" if Name=="Ursinus College"
replace Name="Wofford" if Name=="Wofford College"
replace Name="Rhodes" if Name=="Rhodes College"
replace Name="Austin" if Name=="Austin College"
replace Name="Beloit" if Name=="Beloit College"
replace Name="Lawrence" if Name=="Lawrence University"
compress Name


** Reshape long
	reshape long retention_, i(Name UnitID) j(Year)	string
	rename retention_ Retention
	destring Year, replace
	
** Find Yearly Median	
	egen med = median(Retention), by (Year)
	sort Year

** Assign blank label for graphing	
label variable Year " "

* Sort by each school, then by year
sort UnitID Year

* Setting as time series and calculating trailing average
tsset UnitID Year //setting data as time series
gen threeyearavg = .
replace threeyearavg = (Retention+L1.Retention+L2.Retention)/3
drop if threeyearavg == .
sort Year


save "$root/Stata/Chapter 3 Student Experience/temp/Retention.dta", replace

*************************************
* Graph: Current year, all schools
*************************************

use "$root/Stata/Chapter 3 Student Experience/temp/Retention.dta", replace

* Restrict to current year
keep if Year==2023

* Drop if data is not available
drop if missing(Retention)
 
graph hbar (asis) Retention, over (Name, sort (Retention)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title ("Sophomore Retention Rate, 2023", color(black)) ///
  ytitle(Percentage) ///
  scheme(colorblind) ///
  yscale(extend) ///
  note("Note: Data unavailable for Illinois Wesleyan" "Source: IPEDS" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

  
graph export "$png/StudentEx_retention_rate_current.png", as(png) replace
graph export "$wmf/StudentEx_retention_rate_current.wmf", as(wmf) replace //Stata for MAC cannot produce wmf
graph export "$pdf/StudentEx_retention_rate_current.pdf", as(pdf) replace


**********************************
* Graph: Over time, all schools 
**********************************


use "$root/Stata/Chapter 3 Student Experience/temp/Retention.dta", replace

** Restrict to 10 years
drop if Year <= 2012

** Graph
graph twoway (scatter Retention Year if Name!= "Beloit") (scatter Retention Year if Name == "Beloit") (connected med Year, connect(direct))(line threeyearavg Year if Name=="Beloit"), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median") label(4 "Beloit's 3-year trailing average")) ///
	ytitle(Percentage) ///
	title("Sophomore Retention Rate", color(black)) ///
	scheme(s2color) ///
	xlabel(2016(1) 2023) ///
	note("Source: IPEDS") ///
	ylabel(70 75 80 85 90 95) ///
    graphregion(fcolor(white))
   
graph export "$png/StudentEx_retention_rate_historical.png", as(png) replace
graph export "$wmf/StudentEx_retention_rate_historical.wmf", as(wmf) replace //Stata for MacOS cannot produce wmf
graph export "$pdf/StudentEx_retention_rate_historical.pdf", as(pdf) replace


*** END OF FILE
