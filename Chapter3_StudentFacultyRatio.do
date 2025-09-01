*******************************************************************************
* Fact Book
* Chapter: 3 Student Experience
* 
* Output: 
*	- StudentEx_student_faculty_ratio_2008-2017
*	- StudentEx_student_faculty_ratio_2017
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

*************************************************************************
* Import and prepare the current year data
*************************************************************************

import excel "$root/Stata/Chapter 3 Student Experience/input/Student Faculty Ratio - IPEDS.xlsx", sheet("data") firstrow clear
keep if inlist(UnitID,$comparison)
keep UnitID StudenttofacultyratioEF2023
gen stufacratio_2023 = StudenttofacultyratioEF2023
drop StudenttofacultyratioEF2023

**Clean data to merge all the same UnitID
collapse (mean) stufacratio_2023, by(UnitID)

save "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio_current.dta", replace
	

/* 
Note: I edited from IPEDS Student Faculty directly because FTE is directly calculated here for 2023,
and the Fall2024 data was not available in HEDS either. You might have to take the data out of HEDS Comparison file 
for the other years.
*/


**********************************************************************
* Import and prepare the historical year data from IPEDS 
**********************************************************************


* Import and prepare the historical data (IPEDS)
import excel "$root/Stata/Chapter 3 Student Experience/input/Student Faculty Ratio - IPEDS.xlsx", sheet("data") firstrow clear
	keep if inlist(UnitID,$comparison) 

	rename StudenttofacultyratioEF2023 stufacratio_2023 
	rename StudenttofacultyratioEF2022 stufacratio_2022 
	rename StudenttofacultyratioEF2021 stufacratio_2021 
	rename StudenttofacultyratioEF2020 stufacratio_2020 
	rename StudenttofacultyratioEF2019 stufacratio_2019 
	rename StudenttofacultyratioEF2018 stufacratio_2018 
	rename StudenttofacultyratioEF2017 stufacratio_2017 
	rename StudenttofacultyratioEF2016 stufacratio_2016 
	rename StudenttofacultyratioEF2015 stufacratio_2015
	rename StudenttofacultyratioEF2014 stufacratio_2014
	rename StudenttofacultyratioEF2013 stufacratio_2013

	keep UnitID InstitutionName stufacratio*
	rename InstitutionName Name
	
	
** Clean up name
	replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
	replace Name="Knox" if Name=="Knox College"
	replace Name="Agnes Scott" if Name=="Agnes Scott College"
	replace Name="Centre" if Name=="Centre College"
	replace Name="Wheaton" if Name=="Wheaton College (MA)"
	replace Name="Kalamazoo" if Name=="Kalamazoo College"
	replace Name="Cornell" if Name=="Cornell College"
	replace Name="Juniata" if Name=="Juniata College"
	replace Name="Linfield" if Name=="Linfield College-McMinnville Campus"
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


	sort UnitID

	**Clean data to merge all the same UnitID
      collapse (firstnm) Name (mean) stufacratio_*, by(UnitID)
	save "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio_historical.dta", replace
	

**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio_current.dta", clear
merge 1:1 UnitID using "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio_historical.dta"
drop _merge


** Reshape data long for graphing and calculating median
reshape long stufacratio_, i(UnitID Name) j(year) 
rename stufacratio_  stufacratio

* Create median variable
egen med = median(stufacratio), by (year)
sort year
    	
save "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio.dta", replace

	
*************************************
* Graph: Current year, all schools
*************************************

use "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio.dta", clear

keep if year == 2023
drop if missing(stufacratio)


graph hbar (asis) stufacratio, over(Name, sort(1) label(labsize(vsmall))) ///
    blabel(bar, pos(inside) color(white) size(vsmall) format(%9.0f)) ///
    title("Student-to-Faculty Ratio, 2023", color(black) size(medium)) ///
    ytitle("", size(small)) ///
    note("Note: Data Unavailable for Illinois Wesleyan{break}" ///
         "Ratio represents full-time equivalent students to full-time equivalent faculty.{break}" ///
         "Source: Common Data Set", size(small)) ///
    scheme(colorblind) ///
    yscale(extend) ///
    bar(1, color("0 56 107") fintensity(100)) ///
    graphregion(color(white) margin(large)) ///
    plotregion(margin(large)) ///
    ysize(8) xsize(12)


graph export "$png/StudentEx_student_faculty_ratio_current.png", as(png) replace
graph export "$pdf/StudentEx_student_faculty_ratio_current.pdf", as(pdf) replace
graph export "$wmf\StudentEx_student_faculty_ratio_current.wmf", as(wmf) replace  //Stata for MAC cannot produce wmf


********************************************************************
* Graph: Box and Whisker for Beloit and Comparison Schools Over Time
********************************************************************


use "$root/Stata/Chapter 3 Student Experience/temp/StudenttoFacultyRatio.dta", clear
	
graph box stufacratio, over(year) ///
    box(1, color(blue)) ///
    title("Student-Faculty Ratio", color(black)) ///
    ytitle("Ratio") ///
    note("Note: Each box and whisker contains Beloit and its 19 comparison schools." "Source: IPEDS, CDS", size(small)) /// SO I want to add a data point like a circle just to show Beloit's data, edit the code in red. 
    scheme(s2color) ///
    graphregion(fcolor(white))


graph export "$png/StudentEx_student_faculty_ratio_historical.png", as(png) replace
graph export "$pdf/StudentEx_student_faculty_ratio_historical.pdf", as(pdf) replace
graph export "$wmf\StudentEx_student_faculty_ratio_historical.wmf", as(wmf) replace //MAC cannot produce 

** END OF FILE
