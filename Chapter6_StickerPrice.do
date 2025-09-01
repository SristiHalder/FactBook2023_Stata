*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_stickerprice_adjusted_2007-2017
*	- Finance_stickerprice_2018
*
*******************************************************************************


**********
* Set up *
**********

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


***********************************************
* Import and prepare the data
***********************************************
* If you are doing fact book for previous year, you just need to download the data from IPEDS, but if you are doing the most recent one whose data
* unavailable on IPEDS, you have to split it in two spreadsheets, one for current year on those schools' websites and one downloaded for previous years on IPEDS.
*import excel "$input/Sticker Price.xlsx", sheet("Sticker Price All") firstrow clear
*keep Name Total2023 
*save "$temp/StickerPrice2021.dta", replace
*clear 

import excel "$input/Sticker Price.xlsx", sheet("Sticker Price All") firstrow clear
keep if inlist(UnitID,$comparison) 

*rename variables 
rename InstitutionName Name
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College"
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


save "$temp/StickerPrice.dta", replace

*merge 1:1 Name using "$temp/StickerPrice2021.dta" 


*drop _merge 

gen Total2023=(Publishedindistricttuitionan+Oncampusfoodandhousing2023)/1000
gen Total2022=(E+Oncampusroomandboard20222)/1000
gen Total2021=(G+Oncampusroomandboard20212)/1000
gen Total2020=(I+Oncampusroomandboard20202)/1000
gen Total2019=(K+Oncampusroomandboard20192)/1000
gen Total2018=(M+Oncampusroomandboard20181)/1000
gen Total2017=(O+Oncampusroomandboard20171)/1000
gen Total2016=(Q+Oncampusroomandboard20161)/1000
gen Total2015=(S+Oncampusroomandboard20151)/1000
gen Total2014=(U+Oncampusroomandboard20141)/1000

******************************
* Sticker Price
****************************** 
  
*Reshape data to add a year variable
reshape long Total, i(Name) j(Year)	
*adjust for inflation
gen inflation=.

replace inflation =233.916 if Year==2014
replace inflation =238.654 if Year==2015
replace inflation =240.628 if Year==2016
replace inflation =244.786 if Year==2017
replace inflation =252.006 if Year==2018
replace inflation =256.571 if Year==2019
replace inflation =259.101 if Year==2020
replace inflation =273.003 if Year==2021
replace inflation =296.276 if Year==2022
replace inflation =305.691 if Year==2023

*create inflation relative to July 2014
gen inflator = 305.691/inflation

** Inflate/deflate the total comprehensive fee
gen real_cost=Total*inflator

*create median variable
egen med = median(real_cost), by (Year)
sort Year


*Create scatterplot
graph twoway (scatter real_cost Year if Name!= "Beloit") (scatter real_cost Year if Name == "Beloit")(connected med Year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Price ($, thousands)) ///
	xtitle("") ///
	xlabel(2014(1) 2023) ///
	ylabel(55 (5) 85) ///
	title("Sticker Price of Tuition, Fees, Room, and Board", color(black)) ///
	subtitle("Inflation Adjusted,2023", color(black)) ///
	scheme(s2color) ///
	note("Note: Inflation adjustment using Bureau of Labor Statistics: CPI-All Urban Consumers" "Source: IPEDS") ///
    graphregion(fcolor(white))	
	
graph export "$png/Finance_stickerprice_adjusted_2008-2018.png", as(png) replace
graph export "$wmf\Finance_stickerprice_adjusted_2008-2018.wmf", as(wmf) replace
graph export "$final/Finance_stickerprice_adjusted_2008-2018.pdf", as(pdf) replace

clear 


******************************
*Sticker Price, 2018
******************************

* Import and prepare the data
import excel "$input/Sticker Price.xlsx", sheet("Sticker Price All") firstrow clear
keep if inlist(UnitID,$comparison)
gen Total2023=(Publishedindistricttuitionan+Oncampusfoodandhousing2023)/1000
gen Total2022=(E+Oncampusroomandboard20222)/1000

*rename variables 
rename InstitutionName Name
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
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


graph hbar (asis) Total2023, over (Name, sort (Total2023)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Sticker Price of Tuition, Fees, Room, and Board", color(black)) ///
  subtitle("2023-24", color(black)) ///
  ytitle("Price ($, thousands)") ///) ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Note: IPEDS" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  ylabel(0(10) 70) ///
  graphregion(color(white))

graph export "$png/Finance_stickerprice_2023.png", as(png) replace
graph export "$wmf\Finance_stickerprice_2023.wmf", as(wmf) replace  
graph export "$final/Finance_stickerprice_2023.pdf", as(pdf) replace
  
clear

