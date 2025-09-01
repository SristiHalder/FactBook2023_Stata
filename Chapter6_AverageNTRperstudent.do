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
 *import excel "$input/NACUBO/2021_NACUBO_Tuition_Discounting_Survey_Comparison_Tool_2021-04-26.xlsx", sheet("Characteristics & Ratios") firstrow cellrange(A28:S171) clear
 import excel "$input/Julie/IPEDS - net price.xlsx", sheet("data") firstrow cellrange(A2) clear
 
* Restrict to comparison schools 
destring UnitID, replace
keep if inlist(UnitID,$comparison) 


* Keep variables of interest
rename InstitutionName Name
rename R NTR2020

replace  NTR2020=round( NTR2020,1)

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

save "$temp/ntr2020.dta", replace

*********************************************************************************
* Graph most recent year of data for Beloit and comparison schools
*********************************************************************************

use "$temp/ntr2020.dta", clear

* Drop any schools without NTR
drop if NTR==.

graph hbar (asis) NTR2020, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%8.0g)) ///
  title("Average Net Tuition Revenue", color(black)) ///
  subtitle("Freshman, 2020", color(black)) ///
  ytitle("") ///
  scheme(colorblind) ///
  yscale(noextend) ///
  note("Note: Data unavailable for Allegheny, Austin, Centre, Cornell, Illinois Wesleyan" " Kalamazoo, Linfield, Millsaps, Ohio Wesleyan" "Rhodes College, Wooster, Wheaton, and Wofford College" "Source: NACUBO Tuition Discounting Survey, subject to HEDS Confidentiality" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white)) ///

*graph export "$wmf/Finance_avgNTR.wmf", as(wmf) replace
graph export "$png/Finance_avgNTR.png", as(png) replace
graph export "$final/Finance_avgNTR.pdf", as(pdf) replace


*********************************************************************************
* Import historical datasets for prior years and create dataset with all years
*********************************************************************************

/**** Import datasets for 2014

	*import dataset
	import excel "$input/NACUBO/2014_NACUBO_Tuition_Discounting_Survey_Ratios_2015-02-24.xlsx", sheet("Ratios") cellrange(A20:R150) clear

	*keep variables of interest
	keep A B L

	rename A UnitID
	rename B Name
	rename L NTR2014

	keep if inlist(UnitID,$comparison) 

	save "$temp/ntr2014.dta", replace
*/

*** Import datasaets for 2015

	* Import dataset
	import excel "$input/NACUBO/2015_NACUBO_Tuition_Discounting_Survey_Ratios_2016-03-10.xlsx", sheet("Ratios") cellrange(A22:R157) clear


	* Keep variables of interest
	keep A B L

	rename A UnitID
	rename B Name
	rename L NTR2015

	keep if inlist(UnitID,$comparison) 

	save "$temp/ntr2015.dta", replace


*** Import datasaets for 2016
	
	* Import dataset
	import excel "$input/NACUBO/nacubo 2016.xlsx", sheet("Sheet1") clear

	* Keep variables of interest
	keep A B L

	rename A UnitID
	rename B Name
	rename L NTR2016

	keep if inlist(UnitID,$comparison) 

	save "$temp/ntr2016.dta", replace

*** Import datasaets for 2017
	
	* Import dataset
	import excel "$input/NACUBO/2017_NACUBO_Tuition_Discounting_Survey_Comparison_Tool_2018-03-26", sheet("Ratios") cellrange(A23:R163) clear
 
	* Keep variables of interest
	keep A B L

	rename A UnitID
	rename B Name
	rename L NTR2017

	keep if inlist(UnitID,$comparison) 

	save "$temp/ntr2017.dta", replace

*** Import datasaets for 2018
	
	* Import dataset
	import excel "$input/NACUBO/1819_NACUBO_Tuition_Discounting_Study_Comparison_Tool_2019-03-19", sheet("Ratios") cellrange(A23:L166) clear
	 
	* Keep variables of interest
	keep A B L

	rename A UnitID
	rename B Name
	rename L NTR2018

	keep if inlist(UnitID,$comparison) 

	save "$temp/ntr2018.dta", replace


*** Import datasets for 2019
	
	* Import dataset
	 import excel "$input/NACUBO/1920_NACUBO_Tuition_Discounting_Survey_Comparison_Tool_2020-03-24", sheet("Characteristics & Ratios") firstrow cellrange(A28:S161) clear

	keep if inlist(UnitID,$comparison) 

	* Keep variables of interest
	keep UnitID R
	rename R NTR2019

	drop if NTR==.
	replace  NTR2019=round( NTR2019,1)
	save "$temp/ntr2019.dta", replace



*** Combine all years 
use "$temp/ntr2020.dta", replace

merge 1:1 UnitID using "$temp/ntr2019.dta"
drop _merge

merge 1:1 UnitID using "$temp/ntr2018.dta"
drop _merge

merge 1:1 UnitID using "$temp/ntr2017.dta"
drop _merge

merge 1:1 UnitID using "$temp/ntr2016.dta"
drop _merge

merge 1:1 UnitID using "$temp/ntr2015.dta"
drop _merge


** Add in any names missing from the most recent file that were added in by previous years 
compress Name
replace Name = "Rhodes" if UnitID == 221351
replace Name = "Wofford" if UnitID == 218973

** Save dataset for checking, reference
save "$output/NACUBO compilation.dta", replace
export excel using "$output/NACUBO compilation.xlsx", sheet("Average NTR") cell (A5) sheetmodify firstrow(var)

*******************************************************************************
* Graph multi year comparison
*******************************************************************************

use "$output/NACUBO compilation.dta", clear

** Reshape long for graphing
reshape long NTR, i(UnitID) j(year)
label variable year " "


* Create yearly median NTR variable
	* Drop rows where NTR is missing for schools
	drop if NTR==.

	replace NTR=NTR/1000

	egen med_ntr = median(NTR), by (year)
	sort year

* Graph for all years combined

graph twoway (scatter NTR year if UnitID!= 238333) (scatter NTR year if UnitID== 238333) (connected med_ntr year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	title("Average Net Tuition Revenue", color(black)) ///
	subtitle("Freshman, 2015-2020", color(black)) ///
	ytitle("$, thousands") ///
	ylabel() ///
	xlabel(2015(1) 2020) ///
	scheme(s2color) ///
	note("Source: NACUBO Tuition Discounting Survey, subject to HEDS Confidentiality") ///
    graphregion(fcolor(white))
	
graph export "$png/Finance_avgNTR15-20.png", as(png) replace
graph export "$final/Finance_avgNTR15-20.pdf", as(pdf) replace

clear 
