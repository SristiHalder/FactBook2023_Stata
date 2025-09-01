*******************************************************************************
* Fact Book
* Chapter: 3 Student Experience
* 
* Output: 
*	- StudentEx_InstPerf_faculty_retention
*	- StudentEx_InstPerf_faculty_graduation
*	- StudentEx_InstPerf_staff_retention
*	- StudentEx_InstPerf_staff_graduation
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

** Define other global paths
global input "$root/Stata/Chapter 3 Student Experience/input"
global temp "$root/Stata/Chapter 3 Student Experience/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

******************************************
* Retention and number of faculty
******************************************

***** Import and prepare the most recent year of retention data (CDS)
import excel "/Users/sristihalder/Library/CloudStorage/GoogleDrive-halderss@beloit.edu/Shared drives/IRAP Interns/Fact books/Fact book 2024-25/~CDS data/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part B Enrollment") firstrow cellrange(B23) clear

keep if inlist(UnitID,$comparison)
rename AR FirsttoSecondYearRetention
destring FirsttoSecondYearRetention, replace
gen fy2023=FirsttoSecondYearRetention*100
keep UnitID Institution fy2023
save "$temp/RetentionRateCurrent.dta", replace

* Import and prepare historic retention rate data (IPEDS)
import excel "$input/Retention Data IPEDS.xlsx", firstrow clear

*Make UnitID numeric
replace UnitID = strtrim(UnitID)
replace UnitID = subinstr(UnitID, " ", "", .)
gen double UnitID_num = real(UnitID)
drop UnitID
rename UnitID_num UnitID

*Keep only schools in the comparison group
keep if inlist(UnitID, $comparison)

*Rename Fulltimeretentionrate columns to retention_20XX
rename Fulltimeretentionrate2023 retention_2023
rename Fulltimeretentionrate2022 retention_2022
rename Fulltimeretentionrate2021 retention_2021
rename Fulltimeretentionrate2020 retention_2020
rename Fulltimeretentionrate2019 retention_2019
rename Fulltimeretentionrate2018 retention_2018
rename Fulltimeretentionrate2017 retention_2017
rename Fulltimeretentionrate2016 retention_2016
rename Fulltimeretentionrate2015 retention_2015
rename Fulltimeretentionrate2014 retention_2014

*Destring retention variables if needed
ds retention_20*, has(type string)
destring `r(varlist)', replace ignore(" ")

* Step 5: Drop rows that are missing the most recent year
drop if retention_2023 == .

* Step 6: Rename institution column to match other datasets
rename InstitutionName Institution

* Step 7: Keep only necessary variables
keep UnitID Institution retention_*

* Step 8: Save the cleaned dataset
cap mkdir "$temp"
save "$temp/RetentionRateHistoric.dta", replace

* Add the most recent retention year (CDS) to the historical years (IPEDS)
merge 1:1 UnitID using "$temp/RetentionRateCurrent.dta" 
rename retention* fy*
keep UnitID  fy* 
save "$temp/InstitutionalPerformanceRetention", replace


** Import and prepare the number of faculty historically (IPEDS)
import excel "$input/Chapter 3 Data.xlsx", firstrow clear
keep if inlist(UnitID,$comparison) 
sort UnitID
rename Gr~1_IS_RVAllfu proftotal2023
rename Fulltimeequivalentfallenroll enrolled2023
keep UnitID InstitutionName proftotal* enrolled* 


** Add the retention rates to the yearly number of faculty
merge 1:1 UnitID using "$temp/InstitutionalPerformanceRetention.dta" 


** Create variables to graph
gen perfulltime2023 = enrolled2023/proftotal2023
gen RetentionRate=(fy_2023+fy_2022+fy_2021)/3

label var perfulltime "FTE Students per Full-Time Faculty"
label var RetentionRate "Retention Rate (3-yr avg)"


	** Clean up name
	drop if InstitutionName== ""
	
	drop fy2023 _merge // this step is optional
	rename InstitutionName Name 
	replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
	replace Name="Knox" if Name=="Knox College"
	replace Name="Agnes Scott" if Name=="Agnes Scott College"
	replace Name="Centre" if Name=="Centre College"
	replace Name="Wheaton" if Name=="Wheaton College"
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
	replace Name= "Wheaton" if Name=="Wheaton College (Massachusetts)"
	compress Name


** Create graph of FTE faculty v. retention rate

graph twoway (scatter perfulltime RetentionRate, mlabel(Name) mlabcolor(gs0))(lfit perfulltime RetentionRate, sort), ///
	ytitle() ///
	title("Number of FTE Students per Full-Time Faculty vs. Retention Rate", color(black) size(4)) ///
	scheme(s2color) ///
	xlabel(75 95) ///
    note("Note: Retention Rate is the average retention rate of 2021, 2022, and 2023." ///
         "FTE Students per Full-Time Faculty is for 2023." ///
         "Source: IPEDS") ///
    graphregion(fcolor(white))

graph export "$png/StudentEx_InstPerf_faculty_retention.png", as(png) replace
graph export "$pdf/StudentEx_InstPerf_faculty_retention.pdf", as(pdf) replace



 
************************************
* Graduation and number of faculty
************************************

** Import and prepare the 6 year graduation rate data for most recent year (CDS)
import excel "/Users/sristihalder/Library/CloudStorage/GoogleDrive-halderss@beloit.edu/Shared drives/IRAP Interns/Fact books/Fact book 2024-25/~CDS data/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part B Enrollment") firstrow cellrange(B23) clear
rename AY grad6_2023
keep UnitID grad6_2023
replace grad6_2023 = grad6_2023*100
sort UnitID
keep if inlist(UnitID,$comparison) 
save "$temp/Grad2023.dta", replace


** Import and prepare the 6 year graduation rate data for historic years (IPEDS)
import excel "$input/Chapter 3 Data.xlsx", firstrow clear
sort UnitID
rename Gr~1_IS_RVAllfu proftotal2023
rename Fulltimeequivalentfallenroll enrolled2023
rename P grad6_2023
rename AD grad6_2022
rename AR grad6_2021
rename BF grad6_2020
	/* Need to look in the original spreadsheet to find the variable names, and match to how it imported in Stata
	Column T:  Graduation rate - Bachelor degree within 6 years  total (DRVGR2019)
	Column AM: Graduation rate - Bachelor degree within 6 years  total (DRVGR2018_RV)
	Column BF: Graduation rate - Bachelor degree within 6 years  total (DRVGR2017_RV)
	*/
keep UnitID InstitutionName grad6* proftotal* enrolled*
keep if inlist(UnitID,$comparison) 


* Add the most recent 6 year graduation rate year (CDS) to the historical years (IPEDS)
merge 1:1 UnitID using "$temp/Grad2023.dta" 
drop _merge

* Create variables to graph
gen perfulltime = enrolled2023/proftotal2023
gen GraduationRate=(grad6_2023+grad6_2022+grad6_2021)/3


label var perfulltime "FTE Students per Full-Time Faculty"
label var GraduationRate "Graduation Rate"


* Clean up Institution name
rename InstitutionName Name
	replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
	replace Name="Knox" if Name=="Knox College"
	replace Name="Agnes Scott" if Name=="Agnes Scott College"
	replace Name="Centre" if Name=="Centre College"
	replace Name="Wheaton" if Name=="Wheaton College"
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
	replace Name= "Wheaton" if Name=="Wheaton College (Massachusetts)"
	compress Name
 
 drop if Name == ""

** Save dataset for use in 4th graph
save "$temp/graduation_faculty_cleaned.dta", replace


*FTE faculty v. graduation rate
drop if Name == "Rhodes"
graph twoway (scatter perfulltime GraduationRate, mlabel(Name) mlabcolor(gs0))(lfit perfulltime GraduationRate, sort), ///
	ytitle() ///
	title("Number of FTE Students per Full-Time Faculty vs. Graduation Rate", color(black) size(4)) ///
	scheme(s2color) ///
	xlabel(60 70 80 90) ///
	note("Note: Six-Year Graduation Rate is the average six-year graduation rate of 2021, 2022, and 2023." ///
	     "FTE Students per Full-Time Faculty is for 2023." ///
	     "Source: IPEDS" "Rhodes College was excluded from this visualization due to an extreme outlier value (-1920)", span) ///
    graphregion(fcolor(white))

graph export "$png/StudentEx_InstPerf_faculty_gradrate.png", as(png) replace
graph export "$pdf/StudentEx_InstPerf_faculty_gradrate.pdf", as(pdf) replace

	

*********************************
* Retention and number of staff
*********************************

* Import and prepare the most recent year of retention data (CDS)
* (Already imported above)


* Import and prepare historic retention rate data (IPEDS)
* (Already imported above)

* Add the most recent retention year (CDS) to the historical years (IPEDS)
* (Already combined above)
* (Saved as: "$temp/InstitutionalPerformanceRetention"


** Import and prepare the number of staff historically (IPEDS)
import excel "$input/Chapter 3 Data.xlsx", firstrow clear
sort UnitID
rename GrandtotalS20~l allstafftotal2023
rename Gr~1_IS_RVAllfu proftotal2023
rename Fulltimeequivalentfallenroll enrolled2023
keep UnitID InstitutionName allstafftotal2023 proftotal* enrolled* 
keep if inlist(UnitID,$comparison) 
save "$temp/staff_historic.dta", replace
	/*
	Column O: Grand total (S2019_OC  Full-time total)
	Column AH: Grand total (S2018_OC_RV  Full-time total)
	*/

	
** Add the retention rates to the yearly number of faculty
merge 1:1 UnitID using "$temp/InstitutionalPerformanceRetention.dta" 
drop _merge


* Create variables to graph
gen RetentionRate=(fy_2023+fy_2022+fy_2021)/3
gen perfulltime = enrolled2023/(allstafftotal2023-proftotal2023)

label var perfulltime "FTE Students per Full-Time Staff"  
label var RetentionRate "Retention Rate"


* Clean up Institution Name
*rename Institution name
rename InstitutionName Name
	replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
	replace Name="Knox" if Name=="Knox College"
	replace Name="Agnes Scott" if Name=="Agnes Scott College"
	replace Name="Centre" if Name=="Centre College"
	replace Name="Wheaton" if Name=="Wheaton College"
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
	replace Name= "Wheaton" if Name=="Wheaton College (Massachusetts)"
	compress Name
 
 drop if Name == ""
 
*FTE faculty v. retention rate
drop if Name == "Rhodes"
graph twoway (scatter perfulltime RetentionRate, mlabel(Name) mlabcolor(gs0))(lfit perfulltime RetentionRate, sort), ///
	ytitle() ///
	title("Number of FTE Students per Full-Time Staff vs. Retention Rate", color(black) size(4)) ///
	scheme(s2color) ///
	xlabel(75 95) ///
	note("Note: Retention Rate is the average retention rate of 2021, 2022, and 2023.""FTE Students per Full-Time Staff is for 2019.""Source: IPEDS" "Rhodes College was excluded from this visualization due to an extreme outlier value (-1920)", span) ///
    graphregion(fcolor(white)) 
	
graph export "$png/StudentEx_InstPerf_staff_retention.png", as(png) replace
graph export "$wmf\StudentEx_InstPerf_staff_retention.wmf", as(wmf) replace
graph export "$pdf/StudentEx_InstPerf_staff_retention.pdf", as(pdf) replace


*******************************************
* Graduation Rate and number of staff
*******************************************

** Merge cleaned staff data to cleaned graduation rate data
use "$temp/graduation_faculty_cleaned.dta", clear
merge 1:1 UnitID using "$temp/staff_historic.dta"
drop _merge

* Create a staff performance variable (existing one in the data is for faculty)
drop perfulltime 
gen perfulltime = enrolled2023/(allstafftotal2023-proftotal2023)

label var perfulltime "FTE Students per Full-Time Staff"  

*FTE faculty v. graduation rate
drop if Name == "Rhodes"
graph twoway (scatter perfulltime GraduationRate, mlabel(Name) mlabcolor(gs0))(lfit perfulltime GraduationRate, sort), ///
	ytitle() ///
	title("Number of FTE Students per Full-Time Staff vs. Six-Year Graduation Rate", color(black) size(4)) ///
	scheme(s2color) ///
	xlabel(60 90) ///
	note("Note: Six-Year Graduation Rate is the average six-year graduation rate of 2021, 2022, and 2023""FTE Students per Full-Time Staff is for 2023" "Source: IPEDS," "Rhodes College was excluded from this visualization due to an extreme outlier value (-1920)", span) ///
    graphregion(fcolor(white))
	
graph export "$png/StudentEx_InstPerf_staff_graduation.png", as(png) replace
graph export "$wmf\StudentEx_InstPerf_staff_graduation.wmf", as(wmf) replace
graph export "$pdf/StudentEx_InstPerf_staff_graduation.pdf", as(pdf) replace




** END OF FILE
