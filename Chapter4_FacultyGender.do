*******************************************************************************
* Fact Book
* Chapter: 4 Full-Time Faculty
* 
* Output: 
*	- Faculty_gender_distribution
*	- Faculty_gender_distribution_2017

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
global input "$root/Stata\Chapter 4 Full-Time Faculty/input"
global temp "$root/Stata\Chapter 4 Full-Time Faculty/temp"
global png "$root/Stata\Chapter 4 Full-Time Faculty/_png"
global wmf "$root/Stata\Chapter 4 Full-Time Faculty/_wmfs"
global final "$root/Stata\Chapter 4 Full-Time Faculty/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"


*************************************************
* Import and prepare the current year data (CDS)
*************************************************

* Import and prepare the data
import excel "$cds/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part I Faculty and Class Size") firstrow cellrange(B23) clear
rename Institution Name
keep if inlist(UnitID,$comparison)
rename D prof_FT_total_current
rename G prof_FT_men_current
keep UnitID Name prof_FT_total_current prof_FT_men_current
destring, replace
save "$temp/faculty_gender_current.dta", replace

************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************


* Import and prepare the data
import excel "$input/Faculty - Gender - IPEDS.xlsx", sheet("Faculty - Gender") firstrow cellrange(B2) clear
sort UnitID
*keep UnitID InstitutionName proftotal* profwomen* profmen*
keep if inlist(UnitID,$comparison) 
rename InstitutionName Name
save "$temp/faculty_gender_historic.dta", replace


**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$temp/faculty_gender_current.dta", clear
*merge 1:1 UnitID using "$temp/faculty_gender_historic.dta" 
	*Note: Because we're making this file so late, the IPEDS file has more than it usually would and we have
	*      IPEDS and CDS data for "most recent" year. To keep it easy, just use IPEDS this time.
	*      In the future, if you make this in a timely way, will need CDS.
	*  Drop CDS years
	*drop prof_FT_total_current prof_FT_men_current
	
	* Drop a year of IPEDS data that is too recent for this edition
	*drop total_23 total_men_23 total_women_23

	*Generally, should have all comparison schools in both datasets. If not, check why
	*assert _merge == 3
	*drop _merge

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


* Prepare graphing variables
gen male2014 = total_men_14 / total_14 * 100
gen male2015 = total_men_15 / total_15 * 100
gen male2016 = total_men_16 / total_16 * 100
gen male2017 = total_men_17 / total_17 * 100
gen male2018 = total_men_18 / total_18 * 100
gen male2019 = total_men_19 / total_19 * 100
gen male2020 = total_men_20 / total_20 * 100
gen male2021 = total_men_21 / total_21 * 100
gen male2022 = total_men_22 / total_22 * 100
gen male2023 = total_men_23 / total_23 * 100

keep UnitID Name male*


save "$temp/faculty_gender.dta", replace



*************************************
* Graph: Current year, all schools
*************************************

use "$temp/faculty_gender.dta", clear

** Reshape long
reshape long male, i(UnitID) j(year)
label variable year " "

** Restrict to current year
keep if year==2023

** Remove any schools that are missing data this year
** N/A in 2020
*drop if Name=="Juniata"
*drop if Name=="Ursinus"
*drop if Name =="Allegheny" | Name =="Centre" | Name == "Ohio Wesleyan" | Name =="Rhodes" 

graph hbar (asis) male, over(Name,sort(male)) ///
      blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
      title("Percent of Male Faculty", color(black)) ///
	  subtitle("Full-time Faculty, 2023") ///
	  ytitle ("Percentage") ///
	  scheme(colorblind) ///
      ylabel (0(20) 60) ///
      note("Source: IPEDS" ) ///
      bar(1, color("0 56 107") fintensity(100)) ///
	  graphregion(color(white))
	  
	  
graph export "$png/Faculty_gender_distribution_current.png", as(png) replace	
graph export "$wmf/Faculty_gender_distribution_2023.wmf", as(wmf) replace		
graph export "$final/Faculty_gender_distribution_2023.pdf", as(pdf) replace

	* Next time, if using CDS data, put a note like this back in:
	* note("Note: Data unavailable for Allegheny, Centre, Ohio Wesleyan, Rhodes and Ursinus" "Source: Common Data Set" ) ///

****************************************************
* Graph: Over time for Beloit and all schools
****************************************************


use "$temp/faculty_gender.dta", clear

** Reshape long
reshape long male, i(UnitID) j(year)
label variable year " "


** Create median variable
egen med = median(male), by (year)
sort year

graph twoway (scatter male year if UnitID!= 238333) (scatter male year if UnitID== 238333) (connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percent of Male Faculty", color(black)) ///
	subtitle("Full-time Faculty, 2014-2023") ///
	scheme(s2color) ///
	xlabel(2014(1) 2023) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white))

	*(connected med year connect(direct))
	 
graph export "$png/Faculty_gender_distribution.png", as(png) replace	
graph export "$wmf/Faculty_gender_distribution.wmf", as(wmf) replace		
graph export "$final/Faculty_gender_distribution.pdf", as(pdf) replace

	* Note: Next year,add CDS back in to Note if applicable





** END OF FILE
