*******************************************************************************
* Fact Book
* Chapter: 5 Staff
* 
* Output: 
*	- Staff_race_distribution_hbar
*	- Staff_domestic_minority_hbar
*	- Staff_international_hbar
*
*******************************************************************************

version 14
clear all
set more off
capture log close


global root //insert your working directory here

global input "$root\input"
global temp "$root\temp"
global png "G:\Shared drives\IRAP Interns\Fact book 2020-21\Stata\_png"
global wmf "G:\Shared drives\IRAP Interns\Fact book 2020-21\Stata\_wmfs"
global final "G:\Shared drives\IRAP Interns\Fact book 2020-21\Stata\_pdfs"
global output "G:\Shared drives\IRAP Interns\Fact book 2020-21\Stata\Chapter 5 Staff\output"


* define comparison schools 
local comparison 138600 210669 222983 238333 156408 153162 145646 170532 146427 239017 209065 175980 204909 233295 221351 206589 168281 218973
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 168281, 218973"
local beloit 238333
global beloit "238333"



***********************************************
* Import and prepare the data
***********************************************

import excel "$input/Chapter 5 Input 3.xlsx", firstrow
sort UnitID
keep if inlist(UnitID,$comparison) 
save "$temp\Staff International Base Data.dta", replace

*rename 
rename Institution Name

replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Cornell" if Name=="Cornell College"
*replace Name="Juniata" if Name=="Juniata College"
replace Name="Linfield" if Name=="Linfield College-McMinnville Campus"
replace Name="Wooster" if Name=="The College of Wooster"
replace Name="Allegheny" if Name=="Allegheny College"
replace Name="Millsaps" if Name=="Millsaps College"
replace Name="Ohio Wesleyan" if Name=="Ohio Wesleyan University"
replace Name="Randolph-Macon" if Name=="Randolph-Macon College"
*replace Name="Ursinus" if Name=="Ursinus College"
replace Name="Wofford" if Name=="Wofford College"
replace Name="Rhodes" if Name=="Rhodes College"
replace Name="Austin" if Name=="Austin College"
replace Name="Beloit" if Name=="Beloit College"
replace Name="Lawrence" if Name=="Lawrence University"


* Save data for use in multiple graphs
save "$temp\Staff International Base Data.dta", replace


*********************
* Stacked Bar Graph
*********************

* reload temp data
use "$temp\Staff International Base Data.dta", clear

gen InternationalStaff = (NonresidentalientotalS2019_O)/(GrandtotalS2019_OCFulltime)*100
gen DomesticminorityStaff = ((AmericanIndianorAlaskaNative + AsiantotalS2019_OCFulltime + BlackorAfricanAmericantotal + HispanicorLatinototalS2019_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2018_O)/GrandtotalS2019_OCFulltime)*100
gen WhiteStaff = (WhitetotalS2019_OCFulltime)/(GrandtotalS2019_OCFulltime)*100
gen UnknownStaff = (RaceethnicityunknowntotalS2)/(GrandtotalS2019_OCFulltime)*100

keep InternationalStaff DomesticminorityStaff WhiteStaff UnknownStaff Name

label var WhiteStaff "Domestic White" 
label var DomesticminorityStaff "Domestic Minority"  
label var InternationalStaff "International"
label var UnknownStaff  "Unknown "

save "$temp\Staff International Base Data.dta", replace    

*graph 1 - Stacked bar, all
graph hbar (asis) WhiteStaff DomesticminorityStaff InternationalStaff UnknownStaff, over(Name,sort(1) label(labsize(small))) percentage stack ///
     ytitle ("Percentage") ///
	 title ("Staff Race/Ethnicity Distribution", size(large) color(black)) ///
	 subtitle ("Full-time Staff, 2019", color(black)) ///scheme(colorblind) ///
	 note("Source: IPEDS") ///
     bar(1, color("0 56 107") fintensity(100)) ///
	 bar(2, color("198 147 10") fintensity(100)) ///
	 bar(3, color("232 17 45") fintensity(100)) /// 
	 bar(4, color("olive_teal") fintensity(100)) ///
	 graphregion(color(white)) ///
	 legend(region(lwidth(none))) 
	 

graph export "$wmf\Staff_race_distribution_hbar.wmf", as(wmf) replace 
graph export "$png\Staff_race_distribution_hbar.png", as(png) replace 
graph export "$final\Staff_race_distribution_hbar.pdf", as(pdf) replace     


*************************
* Domestic Minority Graph
*************************

* reload
use "$temp\Staff International Base Data.dta", clear

*graph 3 Domestic Minority
graph hbar (asis) DomesticminorityStaff, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title ("Percentage of Staff who are Domestic Minority", color(black)) ///
  subtitle ("Full-time Staff, 2019", color(black)) ///
  ytitle ("Percentage") ///
  scheme(colorblind) ///
  yscale(extend) ///
  note("Source: IPEDS") ///
  bar(1, color("0 56 107") fintensity(100))	///
  graphregion(color(white))
  	 
graph export "$png\Staff_domestic_minority_hbar.png", as(png) replace 
graph export "$wmf\Staff_domestic_minority_hbar.wmf", as(wmf) replace 
graph export "$final\Staff_domestic_minority_hbar.pdf", as(pdf) replace	 

	 
************************
* International Graph
************************

*reload
use "temp\Staff International Base Data.dta"	 
	 
*graph 2 International


graph hbar (asis) InternationalStaff, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%12.1f)) ///
  title ("Percentage of Staff who are International", color(black)) ///
  subtitle ("Full-time Staff, 2018", color(black)) ///
  ytitle ("Percentage") ///
  scheme(colorblind) ///
  yscale(extend) ///
  note( "Source: IPEDS" ) ///
  bar(1, color("0 56 107") fintensity(100))	///
  graphregion(color(white))
    
graph export "$png\Staff_international_hbar.png", as(png) replace 
graph export "$wmf\Staff_international_hbar.wmf", as(wmf) replace 
graph export "$final\Staff_international_hbar.pdf", as(pdf) replace

clear

