*******************************************************************************
* Fact Book
* Chapter: 1 Enrollment
* 
* Output: 
*	- Enrollment_HS_GPA
*	- Enrollment_HS_GPA_historical
*******************************************************************************

***********************************************
* Set up
***********************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here

** Define other global paths
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

import excel "$cds/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", ///
    sheet("Part C First-Year Admission") firstrow cellrange(B23) clear

* Keep only comparison schools 
keep if inlist(UnitID, $comparison)

* Keep relevant variables
keep UnitID Institution AI

rename AI HS_GPA_Fall2023
rename Institution Name


* Format institution names for consistency
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Cornell" if Name=="Cornell College"
replace Name="Juniata" if Name=="Juniata College"
replace Name="Linfield" if Name=="Linfield College-McMinnville Campus"
replace Name="Wooster" if Name=="College of Wooster"
replace Name="Allegheny" if Name=="Allegheny College"
replace Name="Millsaps" if Name=="Millsaps College"
replace Name="Ohio Wesleyan" if Name=="Ohio Wesleyan University"
replace Name="Randolph-Macon" if Name=="Randolph-Macon College"
replace Name="Ursinus" if Name=="Ursinus College"
replace Name="Wheaton" if Name=="Wheaton College (MA)"
replace Name="Wofford" if Name=="Wofford College"
replace Name="Rhodes" if Name=="Rhodes College"
replace Name="Austin" if Name=="Austin College"
replace Name="Beloit" if Name=="Beloit College"
replace Name="Lawrence" if Name=="Lawrence University"
compress Name

* Save processed data
save "$root/Stata/Chapter 1 Enrollment/temp/GPA_current_year.dta", replace

********************************************************************
* Import and prepare historical GPA data
********************************************************************

import excel "$input/Student Demographic Trends.xlsx", sheet("High school GPA") firstrow cellrange(A11) clear

* Drop unnecessary columns
drop H I J K L M N O P Q

* Rename columns
rename B perc_375_400
rename C perc_350_374
rename D perc_325_349
rename E perc_300_324
rename F perc_250_299
rename G perc_200_249

* Remove old data
drop if Year <= 2013

* Convert percentages for easier visualization
replace perc_375_400 = perc_375_400 * 100
replace perc_350_374 = perc_350_374 * 100
replace perc_325_349 = perc_325_349 * 100
replace perc_300_324 = perc_300_324 * 100
replace perc_250_299 = perc_250_299 * 100
replace perc_200_249 = perc_200_249 * 100

save "$root/Stata/Chapter 1 Enrollment/temp/GPA_historical.dta", replace

**********************************************************
* Graph: Current Year GPA for all Schools
**********************************************************

use "$root/Stata/Chapter 1 Enrollment/temp/GPA_current_year.dta", clear

* Drop missing GPA data before graphing
drop if missing(HS_GPA_Fall2023)

* Generate bar graph
graph hbar (asis) HS_GPA_Fall2023, over(Name, sort(HS_GPA_Fall2023)) ///
  blabel(bar, pos(inside) color(white) size(2.5) format(%12.2f)) ///
  ytitle("Average GPA") ///
  title("Average Freshmen High School GPA, 2023", color(black) size(large)) ///
  note("Note: Data not available for Cornell, Ohio Wesleyan, " ///
       "Randolph-Macon, Rhodes, and Ursinus" "High school GPA calculation methodologies may vary. " ///
       "Source: Common Data Set") ///
  scheme(colorblind) ///
  graphregion(color(white)) ///
  bar(1, color("0 56 107") fintensity(100))

* Export graphs
graph export "$png/Enrollment_HS_GPA.png", as(png) replace
graph export "$pdf/Enrollment_HS_GPA.pdf", as(pdf) replace
**********************************
* Graph: Over time for Beloit
**********************************

use "$root/Stata/Chapter 1 Enrollment/temp/GPA_historical.dta", clear


graph bar perc_375_400 perc_350_374 perc_325_349 perc_300_324 perc_250_299 perc_200_249, stack over(Year) ytitle(Percentage of Class) title(Beloit Freshmen High School GPA Distribution, color(black)) subtitle(Fall 2014 to Fall 2023) scheme(s2color) legend(order(1 "3.75-4.00 " 2 "3.50-3.74" 3 "3.25-3.49" 4 "3.00-3.24" 5 "2.50-2.99" 6 "2.00-2.49" ) ) note("Source: Common Data Set") graphregion(color(white)) bar(1, color("0 56 107") fintensity(100)) bar(2, color("198 147 10") fintensity(100)) bar(3, color("232 17 45") fintensity(100)) bar(4, color("olive_teal") fintensity(100)) legend(region(lwidth(none))) 

graph export "$png/Enrollment_HS_GPA_Historical.png", as(png) replace
graph export "$pdf/Enrollment_HS_GPA_Historical.pdf", as(pdf) replace


** END OF FILE
