*******************************************************************************
* Fact Book
* Chapter: 3 Student Experience
*
* Output:
*   - StudentEx_4grad_rate_2009–2023
*******************************************************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here


** The rest of these globals should work independent of the path above
global input "$root/Stata/Chapter 3 Student Experience/input"
global temp "$root/Stata/Chapter 3 Student Experience/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

* Define UnitIDs of comparison schools + Beloit
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

*******************************************************************************
* Step 1: Import and clean historical 4-year grad rate data (2014–2023)
*******************************************************************************

import excel "$input/Graduation Data - 4yr .xlsx", sheet("Master") firstrow clear
drop if UnitID == .

* Keep only the needed columns (2014–2023)
keep UnitID InstitutionName GraduationrateBachelordegre D E F G H I J K L

* Rename columns for clarity
rename GraduationrateBachelordegre gradrate4_2023
rename D gradrate4_2022
rename E gradrate4_2021
rename F gradrate4_2020
rename G gradrate4_2019
rename H gradrate4_2018
rename I gradrate4_2017
rename J gradrate4_2016
rename K gradrate4_2015
rename L gradrate4_2014

* Standardize institution name
rename InstitutionName Name
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
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

*******************************************************************************
* Step 2: Reshape long, filter to comparison schools only
*******************************************************************************

* Reshape from wide to long format
reshape long gradrate4_, i(UnitID Name) j(Year) string
destring Year, replace
rename gradrate4_ grad_rate_4

* Keep only comparison institutions + Beloit
gen keep_inst = inlist(UnitID, ///
    138600, 210669, 222983, 238333, 156408, 153162, 145646, ///
    213251, 170532, 146427, 239017, 209065, 175980, 204909, ///
    233295, 221351, 206589, 216524, 168281, 218973)

keep if keep_inst == 1
drop keep_inst

*******************************************************************************
* Step 3: Calculate 3-year trailing average
*******************************************************************************

sort UnitID Year
tsset UnitID Year
gen threeyearavg = (grad_rate_4 + L1.grad_rate_4 + L2.grad_rate_4) / 3
drop if Year <= 2013

save "$temp/GrateRate4.dta", replace

*******************************************************************************
* Step 4: Graph – Four-Year Graduation Rate, 2023
*******************************************************************************

use "$temp/GrateRate4.dta", clear
drop if grad_rate_4 == .
keep if Year == 2023

graph hbar (asis) grad_rate_4, over(Name, sort(grad_rate_4)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Four-Year Graduation Rate, 2023", color(black)) ///
  ytitle(Percentage) ///
  scheme(colorblind) ///
  yscale(extend) ///
  note("Graduation rate is for the cohort starting in Fall 2019." ///
       "Source: IPEDS") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  ylabel(0(20)100) ///
  graphregion(color(white))
  
* Export graph in multiple formats with descriptive file names

graph export "$png/StudentEx_4grad_rate_2023.png", as(png) replace
graph export "$pdf/StudentEx_4grad_rate_2023.pdf", as(pdf) replace
graph export "$wmf/StudentEx_4grad_rate_2023.wmf", as(wmf) replace  // Skip on Mac if needed

**********************************
* Graph: Over time for Beloit
**********************************

use "$root/Stata/Chapter 3 Student Experience/temp/GrateRate4.dta", clear
drop if grad_rate_4 == .
sort Year 
egen med = median(grad_rate_4), by(Year)
graph twoway (scatter grad_rate_4 Year if Name!= "Beloit") (scatter grad_rate_4 Year if Name == "Beloit")(connected med Year, connect(direct))(line threeyearavg Year if Name=="Beloit"), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median") label(4 "Beloit's 3-year trailing average")) ///
	ytitle(Six-year Graduation Rate) ///
	xtitle("") ///
	xlabel(2014(1) 2023) ///
	title("Four-Year Graduation Rate", color(black)) ///
	scheme(s2color) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white))

** Next year, add the note about CDS Source back in, as it will be a source in future years	
	
graph export "$png/StudentEx_4grad_rate_historical.png", as(png) replace
graph export "$pdf/StudentEx_4grad_rate_historical.pdf", as(pdf) replace
graph export "$wmf/StudentEx_4grad_rate_historical.wmf", as(wmf) replace  // Stata for MAC cannot produce wmf

** END OF FILE
