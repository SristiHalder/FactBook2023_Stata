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
local comparison 138600 210669 222983 238333 156408 153162 145646 213251 170532 146427 239017 209065 175980 204909 233295 221351 206589 216524 168281 218973
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
local acm 238333 173258 153144 126678 153162 153384 146427 146481 239017 153834 173902 147341 239628 174844
global acm "238333, 173258, 153144, 126678, 153162, 153384, 146427, 146481, 239017, 153834, 173902, 147341, 239628, 174844"
local beloit 238333
global beloit "238333"
 
***********************************************
* Import and prepare the current year data (CDS)
***********************************************


*** Import most recent year of gender data from CDS
import excel "$cds/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part C First-Year Admission") firstrow cellrange(B23) clear
duplicates drop UnitID, force
keep UnitID Institution D E F G H I J K X
rename H menfull2023
rename I menpart2023
*replace menpart2023="0" if menpart=="N/A"
*replace menpart2023=0 if menpart2023=="."
destring menpart2023, replace
replace menpart2023=0 if missing(menpart2023)
replace menfull2023=0 if missing(menfull2023)
gen Men2023 = menpart2023+menfull2023
rename J womenfull2023
rename K womenpart2023
*replace womenpart2023="0" if womenpart2023=="N/A"
*replace womenpart2020=0 if womenpart2020==.
destring womenpart2023, replace
replace womenpart2023=0 if missing(womenpart2023)
replace womenfull2023=0 if missing(womenfull2023)
gen Enrolled2023 = Men2023+womenpart2023+womenfull2023
rename Institution Name
keep UnitID Name Enrolled2023 Men2023
*destring, replace
save "$temp/Gender_current.dta", replace
clear

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
*rename ApplicantstotalIC* Applied*

rename AdmissionstotalADM* Admitted*
*rename AdmissionstotalIC* Admitted* 
*rename *_RV *
rename EnrolledtotalADM* Enrolled*
rename EnrolledfulltimetotalADM* Enrolled*
*rename EnrolledfulltimetotalIC* Enrolled*
rename EnrolledmenADM* Enmen*
*rename EnrolledmenIC* Enmen*

rename EnrolledwomenADM* Enwomen*
*rename EnrolledwomenIC* Enwomen*


*rename Institution name
rename Institution Name

replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Cornell" if Name=="Cornell College"
replace Name="Juniata" if Name=="Juniata College"
replace Name="Linfield" if Name=="Linfield College-McMinnville Campus"
replace Name="Wooster" if Name== "The College of Wooster"
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

save "$temp/Gender_historical.dta", replace

**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$temp/Gender_historical.dta", replace
merge 1:1 UnitID using "$temp/Gender_current.dta" 
destring Men2023, replace
drop if _merge == 2
drop _merge


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
gen male2023=Men2023/Enrolled2023*100

reshape long male, i(UnitID) j(year)
label variable year " "

* Create median variable
egen med = median(male), by (year)

* Keep what you need
keep UnitID year Name Enrolled* Enmen* Men2023 male med
sort year
save "$temp/Gender.dta", replace


****************************************************
* Graph: Percent of freshman who are male, over time
****************************************************

use "$temp/Gender.dta", clear
graph twoway (scatter male year if UnitID!= 238333) (scatter male year if UnitID== 238333) (connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percent of Students who are Male", color(black)) ///
	subtitle("Freshman, 2014-2023") ///
	scheme(s2color) ///
	xlabel(2014(1) 2023) ///
	ylabel(30 (5) 55) ///
	note("Source: IPEDS; Common Data Set") ///
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

** Drop anyone who has not submitted data in current year CDS
drop if missing(male)
	** In 2023-24 CDS, it is Ursinus, Allegheny, Centre, Ohio Wesleyan, and Rhodes

graph hbar (asis) male, over(Name,sort(male)) ///
      blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
      title ("Percent of Students who are Male", color(black)) ///
	  subtitle("Freshman, 2023") ///
	  ytitle ("Percentage") ///
	  scheme(colorblind) ///
      yscale (extend) ///
      note( "Note: Data unavailable for Ursinus, Allegheny, Centre, Ohio Wesleyan and Rhodes" "Source: Common Data Set") ///
      bar(1, color("0 56 107") fintensity(100)) ///
	  graphregion(color(white))

	 
graph export "$png/StudentCh_male_freshmen_current.png", as(png) replace	 	
graph export "$wmf/StudentCh_male_freshmen_current.wmf", as(wmf) replace	
graph export "$final/StudentCh_male_freshmen_current.pdf", as(pdf) replace 		  



*** END OF FILE
