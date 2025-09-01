*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_avgNTR14-17
*
*******************************************************************************


version 14
clear all
set more off
capture log close


global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 6 Finance and Operations/input"
global temp "$root/Stata\Chapter 6 Finance and Operations/temp"
global png "$root/Stata\Chapter 6 Finance and Operations/_png"
global wmf "$root/Stata\Chapter 6 Finance and Operations/_wmfs"
global final "$root/Stata\Chapter 6 Finance and Operations/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

		/* For reference: 
		138600	Agnes Scott College
		210669	Allegheny College
		222983	Austin College
		238333	Beloit College
		156408	Centre College
		153162	Cornell College
		145646	Illinois Wesleyan University
		213251	Juniata College
		170532	Kalamazoo College
		146427	Knox College
		239017	Lawrence University
		209065	Linfield College-McMinnville Campus
		175980	Millsaps College
		204909	Ohio Wesleyan University
		233295	Randolph-Macon College
		221351	Rhodes College
		206589	The College of Wooster
		216524	Ursinus College
		168281	Wheaton College (Mass.)
		218973	Wofford College
		*/

*********************************************************************************
* Import most recent year of data
*********************************************************************************

* Import dataset
 import excel "$input/IPEDS - net price.xlsx", sheet("data") firstrow cellrange(A2) clear
 
* Restrict to comparison schools
destring UnitID, replace 
keep if inlist(UnitID,$comparison) 


* Keep variables of interest
rename InstitutionName Name

*replace  NPSFA*=round( NPSFA*,1)

*Standardize Institution Name for Graphing
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

save "$temp/npsfa.dta", replace


*********************************************************************************
* Graph most recent year of data for Beloit and comparison schools
*********************************************************************************

use "$temp/npsfa.dta", clear
keep UnitID Name NPSFA2022
save "$temp/npsfa2022.dta", replace


use "$temp/npsfa2022.dta", clear
* Drop any schools without NTR
drop if NPSFA2022==.

graph hbar (asis) NPSFA2022, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%8.0g)) ///
  title("Average net price-students awarded grant or scholarship aid", size(medium) color(black)) ///
  subtitle("Freshman, 2022", color(black)) ///
  ytitle("") ///
  scheme(colorblind) ///
  yscale() ///
  ylabel(0(10000) 32000) ///
  note("Note: IPEDS" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white)) ///

graph export "$png/Finance_avgNPSFA2022.png", as(png) replace
graph export "$wmf/Finance_avgNPSFA2022.wmf", as(wmf) replace
graph export "$final/Finance_avgNPSFA2022.pdf", as(pdf) replace



*******************************************************************************
* Graph multi year comparison
*******************************************************************************

use "$temp/npsfa.dta", clear

** Reshape long for graphing
reshape long NPSFA, i(UnitID) j(year)
label variable year " "


* Create yearly median NTR variable
	* Drop rows where NTR is missing for schools
	drop if NPSFA==.

	replace NPSFA=NPSFA/1000

	egen med_ntr = median(NPSFA), by (year)
	sort year

* Graph for all years combined

graph twoway (scatter NPSFA year if UnitID!= 238333) (scatter NPSFA year if UnitID== 238333) (connected med_ntr year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	title("Average net price-students awarded grant or scholarship aid", size(medium) color(black)) ///
	subtitle("Freshman, 2013-2022", color(black)) ///
	ytitle("$, thousands") ///
	ylabel() ///
	xlabel(2013(1) 2022) ///
	scheme(s2color) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white))
	
graph export "$png/Finance_avgNPSFA13-22.png", as(png) replace
graph export "$final/Finance_avgNPSFA13-22.pdf", as(pdf) replace

clear 
