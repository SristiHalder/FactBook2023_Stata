*******************************************************************************
* Fact Book
* Chapter: 1 Enrollment
* 
* Output: 
* 	- Enrollment_admit_rate_current
* 	- Enrollment_admit_rate_historical
*   - Enrollment_yield_rate_current
*   - Enrollment_yield_rate_historical
*   - Enrollment_draw_rate_current
*   - Enrollment_draw_rate_historical

*
*
*******************************************************************************

***********************************************
* Set up
***********************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 1 Enrollment/input"
global temp "$root/Stata\Chapter 1 Enrollment/temp"
global png "$root/Stata/_png"
global wmf "$root/Stata/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"


*************************************************
* Import and prepare the current year data (CDS)
*************************************************


* Import and prepare the data
import excel "$cds/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part C First-Year Admission") firstrow cellrange(B23) clear

* Restrict to comparison schools
keep if inlist(UnitID,$comparison)

* Find and calculate needed variables
rename D applied_men
rename E applied_women
gen Applied2024 = applied_men + applied_women

rename F admitted_men
rename G admitted_women
gen Admitted2020 = admitted_men + admitted_women

rename H enrolled_men
rename J enrolled_women
gen Enrolled2024 = enrolled_men + enrolled_women

keep UnitID  Applied Admitted Enrolled

save "$temp/Admit_current_year.dta", replace


************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************


import excel "$input/Admission and Enrolled 3.xlsx", firstrow clear
keep if inlist(UnitID,$comparison)

* Find and calculate needed variables
keep UnitID InstitutionName Applicantstotal* Admissionstotal* Enrolledtotal*

rename *_RV *
rename ApplicantstotalADM* Applied*
rename ApplicantstotalIC* Applied*

rename AdmissionstotalADM* Admitted*
rename AdmissionstotalIC* Admitted*

rename EnrolledtotalADM* Enrolled*
rename EnrolledtotalIC* Enrolled*

sort UnitID

save "$temp/Admit_historical.dta", replace


**********************************************************
* Combine datasets and prepare together
**********************************************************


*Merge
use "$temp/Admit_historical.dta", clear
merge 1:1 UnitID using "$temp/Admit_current_year.dta"
drop _merge

* Rename Institution name
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
replace Name="Linfield" if Name=="Linfield College-McMinnville Campus"
replace Name="Millsaps" if Name=="Millsaps College"
replace Name="Ohio Wesleyan" if Name=="Ohio Wesleyan University"
replace Name="Randolph-Macon" if Name=="Randolph-Macon College"
replace Name="Rhodes" if Name=="Rhodes College"
replace Name="Ursinus" if Name=="Ursinus College"
replace Name="Wheaton" if Name=="Wheaton College"
replace Name="Wooster" if Name=="The College of Wooster"
replace Name="Wofford" if Name=="Wofford College"
compress Name

* Calculate Admit rates
gen admit_rate2014=Admitted2014/Applied2014*100
gen admit_rate2015=Admitted2015/Applied2015*100
gen admit_rate2016=Admitted2016/Applied2016*100
gen admit_rate2017=Admitted2017/Applied2017*100
gen admit_rate2018=Admitted2018/Applied2018*100
gen admit_rate2019=Admitted2019/Applied2019*100
gen admit_rate2020=Admitted2020/Applied2020*100
gen admit_rate2021=Admitted2021/Applied2021*100
gen admit_rate2022=Admitted2022/Applied2022*100
gen admit_rate2023=Admitted2023/Applied2023*100

* Calculate Yield rates
gen yield_rate2014=Enrolled2014/Admitted2014*100
gen yield_rate2015=Enrolled2015/Admitted2015*100
gen yield_rate2016=Enrolled2016/Admitted2016*100
gen yield_rate2017=Enrolled2017/Admitted2017*100
gen yield_rate2018=Enrolled2018/Admitted2018*100
gen yield_rate2019=Enrolled2019/Admitted2019*100
gen yield_rate2020=Enrolled2020/Admitted2020*100
gen yield_rate2021=Enrolled2021/Admitted2021*100
gen yield_rate2022=Enrolled2022/Admitted2022*100
gen yield_rate2023=Enrolled2023/Admitted2023*100


* Calculate Draw rates
gen draw_rate2014=yield_rate2014/admit_rate2014*100
gen draw_rate2015=yield_rate2015/admit_rate2015*100
gen draw_rate2016=yield_rate2016/admit_rate2016*100
gen draw_rate2017=yield_rate2017/admit_rate2017*100
gen draw_rate2018=yield_rate2018/admit_rate2018*100
gen draw_rate2019=yield_rate2019/admit_rate2019*100
gen draw_rate2020=yield_rate2020/admit_rate2020*100
gen draw_rate2021=yield_rate2021/admit_rate2021*100
gen draw_rate2022=yield_rate2022/admit_rate2022*100
gen draw_rate2023=yield_rate2023/admit_rate2023*100




keep UnitID Name admit_rate* yield_rate* draw_rate*
aorder
order UnitID Name 

** Save final data for both graphs
save "$temp/Admit.dta", replace


********************************************************************************
*
*     ADMIT RATE GRAPHS
*
********************************************************************************

*************************************
* Graph: Current year, all schools
*************************************

use "$temp/Admit.dta", clear

* Drop out any school with no current year data (missing in CDS)
drop if missing(admit_rate2023)


graph hbar (asis) admit_rate2023, over (Name, sort (1)) ///
  blabel(bar, position(inside) color(white) size(2) format(%9.0f)) ///
  title("Admit Rate, 2023", color(black)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Note: Data unavailable for Allegheny, Centre, Ohio Wesleyan, Rhodes, and Ursinus""Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Enrollment_admit_rate_current.png", as(png) replace
graph export "$wmf\Enrollment_admit_rate_current.wmf", as(wmf) replace
graph export "$final/Enrollment_admit_rate_current.pdf", as(pdf) replace


**********************************
* Graph: Over time, all schools
**********************************

use "$temp/Admit.dta", clear

drop yield_rate* draw_rate*

* Reshape data long, for easier graphing
reshape long admit_rate, i(UnitID) j(year)

* Drop data older than 10 years
drop if year <= 2013

label variable year " "

* create median variable
egen med_admit = median(admit_rate), by (year)

*Graph
sort year
graph twoway (scatter admit_rate year if UnitID!= 238333) (scatter admit_rate year if UnitID== 238333) (connected med_admit year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Admit Rate", color(black)) ///
	ylabel() ///
	xlabel(2014 2023) ///
	scheme(s2color) ///
	note("Source: IPEDS; Common Data Set") ///
    graphregion(fcolor(white))

graph export "$png/Enrollment_admit_rate_historical.png", as(png) replace
graph export "$wmf\Enrollment_admit_rate_historical.wmf", as(wmf) replace
graph export "$final/Enrollment_admit_rate_historical.pdf", as(pdf) replace



********************************************************************************
*
*     YIELD RATE GRAPHS
*
********************************************************************************




*************************************
* Graph: Current year, all schools
*************************************

use "$temp/Admit.dta", clear

* Drop out any school with no current year data (missing in CDS)
drop if missing(yield_rate2023)


graph hbar (asis) yield_rate2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Yield Rate, 2023", color(black)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Note: Data unavailable for Allegheny, Centre, Ohio Wesleyan, Rhodes, and Ursinus""Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Enrollment_yield_rate_current.png", as(png) replace
graph export "$wmf\Enrollment_yield_rate_current.wmf", as(wmf) replace
graph export "$final/Enrollment_yield_rate_current.pdf", as(pdf) replace


**********************************
* Graph: Over time, all schools
**********************************

use "$temp/Admit.dta", clear

drop admit_rate* draw_rate*

* Reshape data long, for easier graphing
reshape long yield_rate, i(UnitID) j(year)

* Drop data older than 10 years
drop if year <= 2013

label variable year " "

* create median variable
egen med_yield = median(yield_rate), by (year)

*Graph
sort year
graph twoway (scatter yield_rate year if UnitID!= 238333) (scatter yield_rate year if UnitID== 238333) (connected med_yield year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Yield Rate", color(black)) ///
	ylabel() ///
	xlabel(2014 2023) ///
	scheme(s2color) ///
	note("Source: IPEDS; Common Data Set") ///
    graphregion(fcolor(white))

graph export "$png/Enrollment_yield_rate_historical.png", as(png) replace
graph export "$wmf\Enrollment_yield_rate_historical.wmf", as(wmf) replace
graph export "$final/Enrollment_yield_rate_historical.pdf", as(pdf) replace



********************************************************************************
*
*    DRAW RATE GRAPHS
*
********************************************************************************


*************************************
* Graph: Current year, all schools
*************************************

use "$temp/Admit.dta", clear

* Drop out any school with no current year data (missing in CDS)
drop if missing(draw_rate2023)


graph hbar (asis) draw_rate2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Draw Rate, 2023", color(black)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  yscale (extend) ///
  note("Note: Data unavailable for Allegheny, Centre, Ohio Wesleyan, Rhodes, and Ursinus""Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Enrollment_draw_rate_current.png", as(png) replace
graph export "$wmf\Enrollment_draw_rate_current.wmf", as(wmf) replace
graph export "$final/Enrollment_draw_rate_current.pdf", as(pdf) replace




**********************************
* Graph: Over time, all schools
**********************************

use "$temp/Admit.dta", clear

drop admit_rate* yield_rate*

* Reshape data long, for easier graphing
reshape long draw_rate, i(UnitID) j(year)

* Drop data older than 10 years
drop if year <= 2013

label variable year " "

* create median variable
egen med_draw = median(draw_rate), by (year)

*Graph
sort year
graph twoway (scatter draw_rate year if UnitID!= 238333) (scatter draw_rate year if UnitID== 238333) (connected med_draw year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Draw Rate", color(black)) ///
	ylabel() ///
	xlabel(2014 2023) ///
	scheme(s2color) ///
	note("Source: IPEDS; Common Data Set") ///
    graphregion(fcolor(white))

graph export "$png/Enrollment_draw_rate_historical.png", as(png) replace
graph export "$wmf\Enrollment_draw_rate_historical.wmf", as(wmf) replace
graph export "$final/Enrollment_draw_rate_historical.pdf", as(pdf) replace









** END OF FILE
