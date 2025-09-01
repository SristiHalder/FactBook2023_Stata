*******************************************************************************
* Fact Book
* Chapter: 2 Student Characteristics
* 
* Output: 
*	- StudentCh_freshman_race_distribution
*	- StudentCh_freshman_international
*	- StudentCh_freshman_domestic_minority
*
* These graphs show Beloit and Comparison Schools for one year
*
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
* Import and prepare the current year data (CDS)
***********************************************

import excel "$input/CDS2324 (selected schools).xlsx", sheet("Sheet1") firstrow cellrange(B3) clear
* Keep the data of comparison schools only 
keep if inlist(UnitID,$comparison) 

** Create variables as needed
keep UnitID Institution D E G H AC AD AE AF AG AH AI AJ AK
*destring D E F G U V W X Y Z AA AB AC, replace
destring D E G H AC AD AE AF AG AH AI AJ AK, replace
replace D= 0 if missing(D)
replace E= 0 if missing(E)
replace G= 0 if missing(G)
replace H= 0 if missing(H)
replace AC= 0 if missing(AC)
replace AD= 0 if missing(AD)
replace AE= 0 if missing(AE)
replace AF= 0 if missing(AF)
replace AG= 0 if missing(AG)
replace AH= 0 if missing(AH)
replace AI= 0 if missing(AI)
replace AJ= 0 if missing(AJ)
replace AK= 0 if missing(AK)

gen domestic2023 = AD+AE+AG+AH+AI+AJ
gen T = D+E+G+H
gen International2023 = AC/T*100
gen Domesticminority2023 = domestic2023/T*100
gen White2023 = AF/T*100
gen Unknown2023 = AK/T*100


* Fix institution names
rename Institution Name

replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (MA)"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Cornell" if Name=="Cornell College"
replace Name="Juniata" if Name=="Juniata College"
replace Name="Linfield" if Name=="Linfield University"
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

** Drop any schools that did not submit CDS data in most recent year
drop if missing(Domesticminority2023) & missing(International2023) & missing(White2023)
	* In 2023-24, drop: Centre, Kalamazoo, Millsaps, Randolp-Macon, Ursinus, and Wheaton

** Add labels for graphing
label var White2023 "White" 
label var Domesticminority2023 "Domestic Minority"  
label var International2023 "International"
label var Unknown2023 "Unknown "

save "$temp/freshman.dta", replace

***************************************************************
* Graph: Race/Ethnicity Distribution in current year (freshman)
***************************************************************

use "$temp/freshman.dta", clear

** Stacked bar
graph hbar (asis) White2023 Domesticminority2023 International2023 Unknown2023 , over(Name,sort(White2023) label(labsize(small))) percentage stack ///
     ytitle ("Percentage") ///
	 title ("Race/Ethnicity Distribution", size(large) color(black)) ///
	 subtitle("Freshman 2023") ///
	 scheme(colorblind) ///
	 note("Note: Data unavailable for Centre, Kalamazoo, Millsaps, Randolp-Macon," ///
	 "Ursinus, and Wheaton" "Source: Common Data Set" ) ///
     bar(1, color("0 56 107") fintensity(100)) ///
	 bar(2, color("198 147 10") fintensity(100)) ///
	 bar(3, color("232 17 45") fintensity(100)) /// 
	 bar(4, color("olive_teal") fintensity(100)) ///
	 graphregion(color(white)) ///
	 legend(region(lwidth(none))) 
	 
	 
graph export "$png/StudentCh_freshman_race_distribution.png", as(png) replace
graph export "$wmf/StudentCh_freshman_race_distribution.wmf", as(wmf) replace      
graph export "$final/StudentCh_freshman_race_distribution.pdf", as(pdf) replace

**************************************************************
* Graph: Percent international in current year (Freshman)
**************************************************************

use "$temp/freshman.dta", clear

drop if Name == "Linfield University"
graph hbar (asis) International2023, over (Name, sort (International2023)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title ("Percent of Students who are International", color(black)) ///
  subtitle("Freshman 2023") ///
  ytitle ("Percentage") ///
  scheme(colorblind) ///
  yscale(extend) ///
  note("Note: Data unavailable for Centre, Kalamazoo, Millsaps, Randolp-Macon," ///
  "Ursinus, and Wheaton. Linfield has no international freshman this year" /// 
  "Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100))	///
  graphregion(color(white))
  
  
graph export "$png/StudentCh_freshman_international.png", as(png) replace
graph export "$wmf/StudentCh_freshman_international.wmf", as(wmf) replace 
graph export "$final/StudentCh_freshman_international.pdf", as(pdf) replace

*****************************************************
* Graph: Domestic minority in current year (Freshman)
*****************************************************


use "$temp/freshman.dta", clear
graph hbar (asis) Domesticminority2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title ("Percent of Students who are Domestic Minorities", color(black)) ///
  subtitle("Freshman 2023") ///
  ytitle ("Percentage") ///
  scheme(colorblind) ///
  yscale(extend) ///
  note("Note: Data unavailable for Centre, Kalamazoo, Millsaps, Randolp-Macon," ///
  "Ursinus, and Wheaton." "Source: Common Data Set") ///
  bar(1, color("0 56 107") fintensity(100))	///
  graphregion(color(white))
  	 
graph export "$png/StudentCh_freshman_domestic_minority.png", as(png) replace
graph export "$wmf/StudentCh_freshman_domestic_minority.wmf", as(wmf) replace 
graph export "$final/StudentCh_freshman_domestic_minority.pdf", as(pdf) replace


** END OF FILE
