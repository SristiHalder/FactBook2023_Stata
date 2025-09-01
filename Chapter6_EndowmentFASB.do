*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_endowment_FASB_2016
*	- Finance_endowment_FASB_adjusted_2007-2017
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


* Import and prepare the data
import excel "$input/Endowment FASB.xlsx", firstrow cellrange(A2) clear

* Keep the data of comparison schools only 
keep if inlist(UnitID,$comparison) 

*rename Institution name
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


* save temp file
save "$temp/Endowment FASB Base Data.dta", replace


************************************************************
* Charts of nominal endowment (not inflation-adjusted) *
************************************************************

*generate Endowments per FTE students to use for later


gen fy2014= (DRVF2014)/(1000)
gen fy2015= (DRVF2015)/(1000)
gen fy2016= (DRVF2016)/(1000) 
gen fy2017= (DRVF2017)/(1000)
gen fy2018= (DRVF2018)/(1000)
gen fy2019= (DRVF2019)/(1000)
gen fy2020= (DRVF2020)/(1000)
gen fy2021= (DRVF2021)/(1000)
gen fy2022= (DRVF2022)/(1000)
gen fy2023= (DRVF2023)/(1000)

graph hbar (asis) fy2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Endowment per Full-Time Equivalent Student, 2023", tstyle(size(medium)) color(black)) ///
  ytitle("Endowment per FTE Student ($, thousands)") ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Source: IPEDS") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

 
graph export "$wmf/Finance_endowment_FASB_2023.wmf", as(wmf) replace
graph export "$png/Finance_endowment_FASB_2023.png", as(png) replace
graph export "$final/Finance_endowment_FASB_2023.pdf", as(pdf) replace



use "$temp/Endowment FASB Base Data.dta", clear

rename DRVF2014 fy2014
rename DRVF2015 fy2015
rename DRVF2016 fy2016
rename DRVF2017 fy2017
rename DRVF2018 fy2018
rename DRVF2019 fy2019
rename DRVF2020 fy2020
rename DRVF2021 fy2021
rename DRVF2022 fy2022
rename DRVF2023 fy2023

gen FY2014=fy2014/1000
gen FY2015=fy2015/1000
gen FY2016=fy2016/1000
gen FY2017=fy2017/1000
gen FY2018=fy2018/1000
gen FY2019=fy2019/1000
gen FY2020=fy2020/1000
gen FY2021=fy2021/1000
gen FY2022=fy2022/1000
gen FY2023=fy2023/1000


reshape long FY, i(UnitID) j(Year)
label variable FY "Endowment ($, thousands)"


********************************************************************
/* Create endowment in real $ using BLS Urban CPI for Jan 2016
http://data.bls.gov/cgi-bin/surveymost */
********************************************************************

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

gen inflator = 305.691/inflation

gen real_endowment=FY*inflator

egen med = median(real_endowment), by(Year)
sort Year


**********************************************
* Remake second chart adjusted for inflation *
**********************************************

graph twoway (scatter real_endowment Year if UnitID!= 238333) (scatter real_endowment Year if UnitID== 238333)(connected med Year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle("Endowment per FTE Student ($, thousands)") ///
	title("Endowment per Full-Time Equivalent Student, Inflation Adjusted", tstyle(size(medium)) color(black)) ///
	scheme(s2color) ///
	xtitle("") ///
	xlabel(2014(1) 2023) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white))
	
graph export "$wmf/Finance_endowment_FASB_adjusted_2014-2023.wmf", as(wmf) replace
graph export "$png/Finance_endowment_FASB_adjusted_2014-2023.png", as(png) replace
graph export "$final/Finance_endowment_FASB_adjusted_2014-2023.pdf", as(pdf) replace

clear 
*End of the file. 
