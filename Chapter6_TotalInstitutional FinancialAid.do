*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_percentage_receiving_aid_scatter
*	- Finance_institutional_aid_2007-2016
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
import excel "$input/IPEDS - Percent students awarded aid and avg amt .xlsx", sheet("All") firstrow

* Keep the data of comparison schools only 
keep if inlist(UnitID,$comparison) 

*rename variables
rename InstitutionName Name
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
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

	
***************************************************************
* Percentage of students receiving institutional aid & amount *
***************************************************************
rename Percentoffulltimefirsttime Aid2023
rename E Aid2022
rename G Aid2021
rename I Aid2020
rename K Aid2019
rename M Aid2018
rename O Aid2017
rename Q Aid2016
rename S Aid2015
rename U Aid2014

rename Averageamountoffederalstate AvgAid2023
rename F AvgAid2022
rename H AvgAid2021
rename J AvgAid2020
rename L AvgAid2019
rename N AvgAid2018
rename P AvgAid2017
rename R AvgAid2016
rename T AvgAid2015
rename V AvgAid2014


save "$temp/IPEDS - Percent students awarded aid and avg amt.dta", replace


****************************************************************
* Chart of nominal Average Inst Aid (not inflation-adjusted) *
****************************************************************

reshape long Aid, i(Name) j(Year)
keep Name Year UnitID Aid
gen School_type=""
replace School_type="Comparison School" if inlist(UnitID,$comparison)
drop UnitID
label variable Year " "

*create median variable
egen Med = median(Aid), by(Year)
sort Year

graph twoway (scatter Aid Year if School_type=="Comparison School")(scatter Aid Year if Name=="Beloit")(connected Med Year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit")label(3 "Median")) ///
	ytitle("Percentage") ///
	title("Percentage of Freshmen Receiving Institutional Aid", color(black)) /// 
	note("Source: IPEDS") ///
	xlabel(2014(1) 2023) ///
	ylabel(90 (2) 100) ///
	scheme(s2color8) ///
	graphregion(fcolor(white))
	
graph export "$png/Finance_percentage_receiving_aid_scatter.png", as(png) replace
graph export "$wmf\Finance_percentage_receiving_aid_scatter.wmf", as(wmf) replace
graph export "$final/Finance_percentage_receiving_aid_scatter.pdf", as(pdf) replace


***********************************************************************
* Create Average Inst Aid in real $ using BLS Urban CPI for Jan 2016*
***********************************************************************

use "$temp/IPEDS - Percent students awarded aid and avg amt.dta", clear

reshape long AvgAid, i(Name) j(Year)
keep Name Year UnitID AvgAid
gen School_type=""
replace School_type="Comparison School" if inlist(UnitID,$comparison)
drop UnitID
label variable Year " "

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

gen real_average_aid = Avg * inflator

*create median variable
egen med = median(real_average_aid), by(Year)
sort Year

*Convert to thousands of dollars
foreach Year in  2014 2015 2016 2017 2018 2019 2020 2021 2022 2023 {
	replace AvgAid`year'=AvgAid`year'/1000
	}
replace real_average_aid=real_average_aid/1000
replace med = med/1000

*************************************************************
* Chart of Average Institutional Aid adjusted for inflation *
*************************************************************

graph twoway (scatter real_average_aid Year if School_type=="Comparison School")(scatter real_average_aid Year if Name=="Beloit")(connected med Year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit")label(3 "Median")) ///
	ytitle("Average Amount of Aid ($, thousands)") ///
	title("Average Institutional Aid Received by Freshmen, Inflation Adjusted", tstyle(size(medium)) color(black)) ///
	note("Source: IPEDS") ///
	scheme(s2color8) ///
	xlabel(2014(1) 2023) ///
	ylabel(25 (5) 55) ///
	graphregion(fcolor(white))

graph export "$png/Finance_institutional_aid_2011-2018.png", as(png) replace
graph export "$wmf\Finance_institutional_aid_2008-2017.wmf", as(wmf) replace
graph export "$final/Finance_institutional_aid_2011-2018.pdf", as(pdf) replace

clear



