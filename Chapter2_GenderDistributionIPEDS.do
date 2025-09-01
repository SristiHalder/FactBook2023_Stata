*******************************************************************************
* Fact Book
* Chapter: 2 Student Characteristics
* 
* Output: 
*	- StudentCh_male_freshmen_historical
*	- StudentCh_male_freshmen_current
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

* Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"
 

************************************************************
* Import and prepare the historical year data (IPEDS)
************************************************************

*** Import historical years of gender data from IPEDS
import excel "$input/Gender Distribution.xlsx", sheet("Gender Distribution") firstrow clear 
sort UnitID
keep UnitID InstitutionName Enrolled* Applicant* Admission* 

* Keep the data of comparison schools only 
keep if inlist(UnitID,$comparison) 

* Drop the single sex institution (no men attend)
drop if InstitutionName=="Agnes Scott College"

rename ApplicantstotalADM* Applied*
rename AdmissionstotalADM* Admitted*
rename EnrolledtotalADM* Enrolled*
rename EnrolledfulltimetotalADM* Enrolled*
rename EnrolledmenADM* Enmen*
rename EnrolledwomenADM* Enwomen*

*rename Institution name
rename InstitutionName Name

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

save "$temp/Gender_historical.dta", replace

**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$temp/Gender_historical.dta", replace


* Generate Enrolled Male Variable as percentage of total Enrolled
gen male2014=Enmen2014/Enrolled2014*100
gen male2015=Enmen2015/Enrolled2015*100
gen male2016=Enmen2016/Enrolled2016*100
gen male2017=Enmen2017/Enrolled2017*100
gen male2018=Enmen2018/Enrolled2018*100
gen male2019=Enmen2019/Enrolled2019*100
gen male2020=Enmen2020/Enrolled2020*100
gen male2021=Enmen2021/Enrolled2021*100
gen male2022=Enmen2022/Enrolled2022*100
gen male2023=Enmen2023/Enrolled2023*100

reshape long male, i(UnitID) j(year)
label variable year " "

* Create median variable
egen med = median(male), by (year)

* Keep what you need
keep UnitID year Name Enrolled* Enmen* male med
sort year
save "$temp/Gender.dta", replace


****************************************************
* Graph: Percent of freshman who are male, over time
****************************************************

use "$temp/Gender.dta", clear
graph twoway (scatter male year if UnitID!= 238333) (scatter male year if UnitID== 238333) (connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percentage of Male Students", color(black)) ///
	subtitle("Freshman, 2014-2023") ///
	scheme(s2color) ///
	xlabel(2014(1) 2023) ///
	ylabel(30 (5) 70 ) ///
	note("Note: Agnes Scott not included (female school)" "Source: IPEDS") ///
    graphregion(fcolor(white))

graph export "$png/StudentCh_male_freshmen_historical.png", as(png) replace
graph export "$wmf/StudentCh_male_freshmen_historical.wmf", as(wmf) replace
graph export "$final/StudentCh_male_freshmen_historical.pdf", as(pdf) replace


*********************************************************************
* Graph: Percent of freshman who are male, most recent year
*********************************************************************

use "$temp/Gender.dta", clear

** Restrict to current year
keep if year == 2023


graph hbar (asis) male, over(Name,sort(male)) ///
      blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
      title ("Percent of Male Students", color(black)) ///
	  subtitle("Freshman, 2023") ///
	  ytitle ("Percentage") ///
	  scheme(colorblind) ///
      yscale (extend) ///
      note("Note: Agnes Scott not included (female school)" "Source: IPEDS") ///
      bar(1, color("0 56 107") fintensity(100)) ///
	  graphregion(color(white))

	 
graph export "$png/StudentCh_male_freshmen_current.png", as(png) replace	 	
graph export "$wmf/StudentCh_male_freshmen_current.wmf", as(wmf) replace	
graph export "$final/StudentCh_male_freshmen_current.pdf", as(pdf) replace 		  



*** END OF FILE
