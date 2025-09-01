*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_institutional_aid
*	- Finance_percentage_receiving_aid
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



* Import and prepare the data
import excel "$input/Financial Aid Trends.xlsx", sheet("Financial Aid") firstrow

* Keep the data of comparison schools only 
keep if inlist(UnitID,$comparison) 

*rename B name
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


save "$temp/Institutional Financial Aid Base Data.dta", replace
	
*****************************
* [HBAR] "Average Institutional Aid Recieved by Freshmen"
*****************************

gen aid2023= Averageamountofinstitutional/1000

graph hbar (asis) aid2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Average Institutional Aid Received by Freshmen, 2023", tstyle(size(medium)) color(black)) ///
  ytitle("Average Amount of Aid ($, thousands)") ///
  scheme(colorblind) ///
  note("Source: IPEDS") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))


graph export "$png/Finance_institutional_aid.png", as(png) replace
graph export "$wmf\Finance_institutional_aid.wmf", as(wmf) replace
graph export "$final/Finance_institutional_aid.pdf", as(pdf) replace


	
***************************************************************
* Percentage of students receiving institutional aid & amount *
***************************************************************

use "$temp/Institutional Financial Aid Base Data.dta", clear

rename U Aid2014
rename S Aid2015
rename Q Aid2016
rename O Aid2017
rename M Aid2018
rename K Aid2019
rename I Aid2020
rename G Aid2021
rename E Aid2022
rename Percentoffulltimefirsttime Aid2023

rename V AvgInstitutionalAid2014
rename T AvgInstitutionalAid2015
rename R AvgInstitutionalAid2016
rename P AvgInstitutionalAid2017
rename N AvgInstitutionalAid2018
rename L AvgInstitutionalAid2019
rename J AvgInstitutionalAid2020
rename H AvgInstitutionalAid2021
rename F AvgInstitutionalAid2022
rename Averageamountofinstitutional AvgInstitutionalAid2023

graph hbar (asis) Aid2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Percentage of Students Receiving Institutional Aid", color(black) tstyle(size(large))) ///
  subtitle("Freshmen, 2023", color(black)) ///
  ytitle("Percentage") ///
  note("Source: IPEDS") ///
  scheme(colorblind) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))


graph export "$png/Finance_percentage_receiving_aid.png", as(png) replace
graph export "$wmf\Finance_percentage_receiving_aid_2017.wmf", as(wmf) replace
graph export "$final/Finance_percentage_receiving_aid.pdf", as(pdf) replace

*End 


