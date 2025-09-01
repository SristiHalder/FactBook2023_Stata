*******************************************************************************
* Fact Book
* Chapter: 2 Student Characteristics
* 
* Output: 
*	- StudentCh_domestic_minority_students
*	- StudentCh_international_students
*	- StudentCh_white_students
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


*************************************************
* Import and prepare the current year data (CDS)
*************************************************

import excel "$input/Race from IPEDS.xlsx", sheet("Race Data") firstrow cellrange(B2) clear
keep if inlist(UnitID,$comparison) 
keep UnitID InstitutionName TOT2023 AMIN2023 ASIAN2023 BLACK2023 HISP2023 HAWAII2023 WHITE2023 TWOORMORE2023 UNKNOWN2023 NONRES2023
destring TOT2023 AMIN2023 ASIAN2023 BLACK2023 HISP2023 HAWAII2023 WHITE2023 TWOORMORE2023 UNKNOWN2023 NONRES2023, replace  

rename InstitutionName Name
gen DOMMIN2023 = AMIN2023 + ASIAN2023 + BLACK2023 + HISP2023 + HAWAII2023 + TWOORMORE2023
keep UnitID TOT2023 WHITE2023 NONRES2023 UNKNOWN2023 DOMMIN2023
save "$temp/all_students_current.dta", replace

************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************

import excel "$input/Race from IPEDS.xlsx", sheet("Race Data") cellrange(B2:CY1853) firstrow clear
keep if inlist(UnitID,$comparison) 
rename InstitutionName Name


* Create domestic minority totals, and drop the detail we don't need
gen DOMMIN2023 = AMIN2023 + ASIAN2023 + BLACK2023 + HISP2023 + HAWAII2023 + TWOORMORE2023
gen DOMMIN2022 = AMIN2022 + ASIAN2022 + BLACK2022 + HISP2022 + HAWAII2022 + TWOORMORE2022
gen DOMMIN2021 = AMIN2021 + ASIAN2021 + BLACK2021 + HISP2021 + HAWAII2021 + TWOORMORE2021
gen DOMMIN2020 = AMIN2020 + ASIAN2020 + BLACK2020 + HISP2020 + HAWAII2020 + TWOORMORE2020
gen DOMMIN2019 = AMIN2019 + ASIAN2019 + BLACK2019 + HISP2019 + HAWAII2019 + TWOORMORE2019
gen DOMMIN2018 = AMIN2018 + ASIAN2018 + BLACK2018 + HISP2018 + HAWAII2018 + TWOORMORE2018
gen DOMMIN2017 = AMIN2017 + ASIAN2017 + BLACK2017 + HISP2017 + HAWAII2017 + TWOORMORE2017
gen DOMMIN2016 = AMIN2016 + ASIAN2016 + BLACK2016 + HISP2016 + HAWAII2016 + TWOORMORE2016
gen DOMMIN2015 = AMIN2015 + ASIAN2015 + BLACK2015 + HISP2015 + HAWAII2015 + TWOORMORE2015
gen DOMMIN2014 = AMIN2014 + ASIAN2014 + BLACK2014 + HISP2014 + HAWAII2014 + TWOORMORE2014
	
drop AMIN* ASIAN* BLACK* HISP* HAWAII* TWOORMORE*


*keep UnitID InstitutionName total* international* white* unknown* domestic*
save "$temp/all_students_historical.dta", replace

**********************************************************
* Combine datasets and prepare together
**********************************************************

*Merge IPEDS Dataset to CDS Dataset
use "$temp/all_students_historical.dta"

keep UnitID Name TOT* NONRES* WHITE* UNKNOWN* DOMMIN*

** Fix institution names
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

* Find international, domestic minority, and white as percent of total
	gen Perc_DomesticMinority_2014 = DOMMIN2014/TOT2014*100
	gen Perc_DomesticMinority_2015 = DOMMIN2015/TOT2015*100
	gen Perc_DomesticMinority_2016 = DOMMIN2016/TOT2016*100
	gen Perc_DomesticMinority_2017 = DOMMIN2017/TOT2017*100
	gen Perc_DomesticMinority_2018 = DOMMIN2018/TOT2018*100
	gen Perc_DomesticMinority_2019 = DOMMIN2019/TOT2019*100
	gen Perc_DomesticMinority_2020 = DOMMIN2020/TOT2020*100
	gen Perc_DomesticMinority_2021 = DOMMIN2021/TOT2021*100
	gen Perc_DomesticMinority_2022 = DOMMIN2022/TOT2022*100
	gen Perc_DomesticMinority_2023 = DOMMIN2023/TOT2023*100

	gen Perc_International_2014 = NONRES2014/TOT2014*100
	gen Perc_International_2015 = NONRES2015/TOT2015*100
	gen Perc_International_2016 = NONRES2016/TOT2016*100
	gen Perc_International_2017 = NONRES2017/TOT2017*100
	gen Perc_International_2018 = NONRES2018/TOT2018*100
	gen Perc_International_2019 = NONRES2019/TOT2019*100
	gen Perc_International_2020 = NONRES2020/TOT2020*100
	gen Perc_International_2021 = NONRES2021/TOT2021*100
	gen Perc_International_2022 = NONRES2022/TOT2022*100
	gen Perc_International_2023 = NONRES2023/TOT2023*100


	gen Perc_White_2014 = WHITE2014/TOT2014*100
	gen Perc_White_2015 = WHITE2015/TOT2015*100
	gen Perc_White_2016 = WHITE2016/TOT2016*100
	gen Perc_White_2017 = WHITE2017/TOT2017*100
	gen Perc_White_2018 = WHITE2018/TOT2018*100
	gen Perc_White_2019 = WHITE2019/TOT2019*100
	gen Perc_White_2020 = WHITE2020/TOT2020*100
	gen Perc_White_2021 = WHITE2021/TOT2021*100
	gen Perc_White_2022 = WHITE2022/TOT2022*100
	gen Perc_White_2023 = WHITE2023/TOT2023*100

	
* Drop data  not needed for any graph
keep UnitID Name Perc*


** Reshape data long
reshape long Perc_, i(UnitID) j(year) string
rename Perc_ perc

** Split out year
split year, gen(temp) parse("_")
	drop year
	rename temp1 type
	rename temp2 year
	destring year, replace
	

* Create yearly median variable for each of domestic minoirity, international, and white
sort type year perc
bysort type year: egen med = median(perc)


* Save as data file to use in following graphs
save "$temp/racedistbase.dta", replace


****************************************************
* Graph: Domestic minority over time
****************************************************

use "$temp/racedistbase.dta", clear
keep if type == "DomesticMinority"
graph twoway (scatter perc year if UnitID!= 238333) (scatter perc year if UnitID== 238333)(connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percent of Students who are Domestic Minority", color(black)) ///
	subtitle("All students, 2014-2023", color(black)) ///
	scheme(s2color) ///
	xlabel(2014(1) 2023) ///
    note("Source: IPEDS") ///
	graphregion(fcolor(white)) 

graph export "$png/StudentCh_domestic_minority_students.png", as(png) replace
graph export "$wmf/StudentCh_domestic_minority_students.wmf", as(wmf) replace
graph export "$final/StudentCh_domestic_minority_students.pdf", as(pdf) replace



****************************************************
* Graph: International over time
****************************************************


use "$temp/racedistbase.dta", clear
keep if type == "International"
graph twoway (scatter perc year if UnitID!= 238333) (scatter perc year if UnitID== 238333)(connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percent of Students who are International", color(black)) ///
	subtitle("All students, 2014-2023", color(black)) ///
	scheme(s2color) ///
	xlabel(2014(1) 2023) ///
    note("Source: IPEDS") ///
	graphregion(fcolor(white)) 
	
	
graph export "$png/StudentCh_international_students.png", as(png) replace
graph export "$wmf/StudentCh_international_students.wmf", as(wmf) replace
graph export "$final/StudentCh_international_students.pdf", as(pdf) replace

****************************************************
* Graph: White Domestic Students over time
****************************************************

use "$temp/racedistbase.dta", clear
keep if type == "White"

graph twoway (scatter perc year if UnitID!= 238333) (scatter perc year if UnitID== 238333) (connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	xlabel(2014(1) 2023) ///
	ylabel(40 (10) 90) ///
	title("Percent of Students who are Domestic White", color(black)) ///
	subtitle("All students, 2014-2023", color(black)) ///
	scheme(s2color) ///
    note("Source: IPEDS") ///
	graphregion(fcolor(white)) 
 
graph export "$png/StudentCh_white_students.png", as(png) replace
graph export "$wmf/StudentCh_white_students.wmf", as(wmf) replace
graph export "$final/StudentCh_white_students.pdf", as(pdf) replace

 
** END OF FILE 


