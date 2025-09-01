*******************************************************************************
* Fact Book
* Chapter: 2 Student Characteristics
* 
* Output: 
*	- StudentCh_pell_recipient_historical
*	- StudentCh_pell_recipient_current

*******************************************************************************


version 14
clear all
set more off
capture log close


global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 2 Student Characteristics/input"
global temp "$root/Stata\Chapter 2 Student Characteristics/temp"
global png "$root/Stata\Chapter 2 Student Characteristics/_png"
global wmf "$root/Stata\Chapter 2 Student Characteristics/_wmfs"
global final "$root/Stata\Chapter 2 Student Characteristics/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"
 

***********************************************
* Prepare the data
***********************************************

* Import and prepare the data
import excel "$input/Pell.xlsx", sheet("Percent recieving pell") cellrange(A2:M1853) firstrow clear 

* Keep the data of comparison schools only 
keep if inlist(UnitID,$comparison)
drop RENAMEDBYIRAP

*keep UnitID InstitutionName Percentoffulltimefirsttime K S AA AI AQ AY BG BO BW PercentagereceivingPellgrants

* Fix names for better graphing
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
replace Name="Linfield" if Name=="Linfield University"
replace Name="Millsaps" if Name=="Millsaps College"
replace Name="Ohio Wesleyan" if Name=="Ohio Wesleyan University"
replace Name="Randolph-Macon" if Name=="Randolph-Macon College"
replace Name="Rhodes" if Name=="Rhodes College"
replace Name="Wooster" if Name=="The College of Wooster"
replace Name="Ursinus" if Name=="Ursinus College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
replace Name="Wofford" if Name=="Wofford College"
compress Name


* Reshape data to add a year variable
reshape long perc_pell_, i(UnitID Name) j(Year)	 string
destring Year, replace
rename perc_pell_ Pell

* create median variable within each year
egen med = median(Pell), by (Year)


* Create mean variable within each school
egen sum_across_time = sum(Pell), by (UnitID)
bysort UnitID: gen num_years = _N
gen average_across_time = sum_across_time / num_years
drop sum_across_time num_years

sort Year
save "$temp/pell.dta", replace

***********************************************
* Graph: Historical
***********************************************

use "$temp/pell.dta", clear
sort Year
*graph Scatter
graph twoway (scatter Pell Year if Name!= "Beloit") (scatter Pell Year  if Name== "Beloit")(connected med Year, connect(direct)), ///
	legend(label(1 "Comparison schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title(Percentage of Freshman Receiving a Pell Grant, color(black)) ///
	scheme(s2color) ///
	xlabel(2014(1) 2023) ///
	note("Source: IPEDS") ///
	graphregion(fcolor(white))
	
graph export "$png/StudentCh_pell_recipient_historical.png", as(png) replace
graph export "$wmf/StudentCh_pell_recipient_historical.wmf", as(wmf) replace
graph export "$final/StudentCh_pell_recipient_historical.pdf", as(pdf) replace

***********************************************
* Graph: Current year
***********************************************

use "$temp/pell.dta", clear 

* Keep most recent year
 keep if Year==2023
 drop Year

*graph hbar
graph hbar (asis) Pell, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f))   ///
  title("Percentage of Freshman Receiving a Pell Grant", color(black)) ///
  subtitle("Fall 2023", color(black)) ///
  ytitle(Percentage) ///
  note("Source: IPEDS") ///
  scheme(colorblind) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(fcolor(white))
  
graph export "$png/StudentCh_pell_recipient_current.png", as(png) replace
graph export "$wmf/StudentCh_pell_recipient_current.wmf", as(wmf) replace
graph export "$final/StudentCh_pell_recipient_current.pdf", as(pdf) replace



*** END OF FILE
