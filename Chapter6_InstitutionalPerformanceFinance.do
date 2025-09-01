*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_scatterplot_students_faculty
*	- Finance_scatterplot_students_employees
*	- Finance_scatterplot_students_staff
*	- Finance_expenses_per_student
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

****************************************
* Import and prepare the data

import excel "$input/Faculty & Staff Gender.xlsx", sheet("Faculty & Staff") firstrow cellrange(A2)
sort UnitID
keep if inlist(UnitID, $comparison)
rename F fulltimeemp2023 // you should find the column named GrandtotalS2023_OCFulltime
rename I fulltimefaculty2023 // you should find the column named GrandtotalS2023_ISAllinstr
keep UnitID InstitutionName fulltimeemp2023 fulltimefaculty2023

save "$temp/StaffFaculty.dta", replace
clear

import excel "$input/Total Enrollment.xlsx", sheet("All") firstrow
sort UnitID
keep if inlist(UnitID,$comparison) 
rename Fulltimeequivalentfallenroll Fall2023
keep UnitID Fall2023 InstitutionName

merge 1:1 UnitID using "$temp/StaffFaculty.dta" 
drop _merge

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

label var Fall2023 "FTE Students"
label var fulltimeemp2023 "Full-Time Employees"
label var fulltimefaculty2023 "Full-Time Faculty"


**********************************************
*number of FTE students v. number of faculty
********************************************

graph twoway (scatter Fall2023 fulltimefaculty2023, mlabel(Name) mlabcolor(gs0)) (lfit Fall2023 fulltimefaculty2023, sort), ///
	ytitle() ///
	title("Number of FTE Students vs. Number of Full-Time Faculty, 2023", color(black) size(4)) ///
	scheme(s2color) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white)) ///
	xlabel(80 (20) 200)
	 	
graph export "$png/Finance_scatterplot_students_faculty.png", as(png) replace 	
graph export "$wmf\Finance_scatterplot_students_faculty.wmf", as(wmf) replace 	
graph export "$final/Finance_scatterplot_students_faculty.pdf", as(pdf) replace


**********************************************
*number of FTE students v. number of employees
***********************************************

graph twoway (scatter Fall2023 fulltimeemp2023, mlabel(Name) mlabcolor(gs0))(lfit Fall2023 fulltimeemp2023, sort), ///
	ytitle() ///
	title("Number of FTE Students vs. Number of Full-Time Employees, 2023", color(black) size(4)) ///
	scheme(s2color) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white)) ///
	xlabel(250 (50) 550)
	
graph export "$png/Finance_scatterplot_students_employees.png", as(png) replace
graph export "$wmf\Finance_scatterplot_students_employees.wmf", as(wmf) replace
graph export "$final/Finance_scatterplot_students_employees.pdf", as(pdf) replace

gen staff2023 = fulltimeemp2023-fulltimefaculty2023
label var staff2023 "Full-Time Staff"


******************************************
*number of FTE students v. number of staff
****************************************

graph twoway (scatter Fall2023 staff2023, mlabel(Name) mlabcolor(gs0))(lfit Fall2023 staff2023, sort), ///
	ytitle() ///
	title("Number of FTE Students vs. Number of Full-Time Staff, 2023", color(black) size(4)) ///
	scheme(s2color) ///
	note("Source: IPEDS") ///
    graphregion(fcolor(white)) ///
	ylabel (750 (250) 2000) ///
	xlabel(150 (50) 350)
	
graph export "$png/Finance_scatterplot_students_staff.png", as(png) replace
graph export "$wmf\Finance_scatterplot_students_staff.wmf", as(wmf) replace
graph export "$final/Finance_scatterplot_students_staff.pdf", as(pdf) replace

clear

* edited till here
********************************
* Total expenses per student
********************************

* Import and prepare the data - 2005-06-2014-15 -=- is this still what is happening
import excel "$input/IPEDS trend data for total expenses FASB.xlsx", sheet("Sheet1") firstrow clear
keep if inlist(UnitID,$comparison) 
sort UnitID

gen TotalE2023 = (InstructionTotalamountF2223_ + ResearchTotalamountF2223_F2 + PublicserviceTotalamountF22 + StudentserviceTotalamountF2 + AcademicsupportTotalamountF + InstitutionalsupportTotalamou + AuxiliaryenterprisesTotalamou)
gen TotalE2022 = (InstructionTotalamountF2122_ + ResearchTotalamountF2122_F2_ + PublicserviceTotalamountF21 + M + N + O + P)
gen TotalE2021 = (InstructionTotalamountF2021_ + ResearchTotalamountF2021_F2_ + PublicserviceTotalamountF20 + T + U + V + W)
gen TotalE2020 = (InstructionTotalamountF1920_ + ResearchTotalamountF1920_F2_ + PublicserviceTotalamountF19 + StudentserviceTotalamountF1 + AB + AC + AD)
gen TotalE2019 = (InstructionTotalamountF1819_ + ResearchTotalamountF1819_F2_ + PublicserviceTotalamountF18 + AH + AI + AJ + AK)
gen TotalE2018 = (InstructionTotalamountF1718_ + ResearchTotalamountF1718_F2_ + PublicserviceTotalamountF17 + AO + AP + AQ + AR)
gen TotalE2017 = (InstructionTotalamountF1617_ + ResearchTotalamountF1617_F2_ + PublicserviceTotalamountF16 + AV + AW + AX + AY)
gen TotalE2016 = (InstructionTotalamountF1516_ + ResearchTotalamountF1516_F2_ + PublicserviceTotalamountF15 + BC + BD + BE + BF)
gen TotalE2015 = (InstructionTotalamountF1415_ + ResearchTotalamountF1415_F2_ + PublicserviceTotalamountF14 + BJ + BK + BL + BM)
gen TotalE2014 = (InstructionTotalamountF1314_ + ResearchTotalamountF1314_F2_ + PublicserviceTotalamountF13 + BQ + BR + BS + BT)

	
keep UnitID InstitutionName Total*
save "$temp/expense.dta", replace
clear

import excel "$input/Total Enrollment.xlsx", sheet("All") firstrow
sort UnitID

keep if inlist(UnitID,$comparison) 

rename Fulltimeequivalentfallenroll Fall2023
rename D Fall2022
rename E Fall2021
rename F Fall2020
rename G Fall2019
rename H Fall2018
rename I Fall2017
rename J Fall2016
rename K Fall2015
rename L Fall2014

drop M N

merge 1:1 UnitID using "$temp/expense.dta"

*rename Institution name
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

*convert average expenses to millions of dollars from dollars
gen AverageExpenses = ((TotalE2023+TotalE2022+TotalE2021)/3)/1000000
gen AverageEnrollment = (Fall2023+Fall2022+Fall2021)/3


label var AverageExpenses "3-Year Average Total Operating Expenses ($, millions)"
label var AverageEnrollment "3-year Average Undergraduate Enrollment"

format AverageEnrollment %9.0gc


* Create graph showing number of FTE students v. total operating expenses
graph twoway (scatter AverageEnrollment AverageExpenses, mlabel(Name) mlabcolor(gs0)) (lfit AverageEnrollment AverageExpenses, sort), ///
	xlabel(40 (20) 110) /// 
	yscale(extend) ///
	title("Operating Expenses vs. Number of Full-Time Students, 2021-2023", color(black)size(4)) ///
	scheme(s2color) ///
	note( "Note: 3-year averages are shown for both variables; Operating expenses include instruction, research," "public service, academic support, student services, institutional support and auxiliaries" "Source: IPEDS") ///
    graphregion(fcolor(white)) 	
	
graph export "$png/Finance_expenses_per_student.png", as(png) replace
graph export "$wmf\Finance_expenses_per_student.wmf", as(wmf) replace
graph export "$final/Finance_expenses_per_student.pdf", as(pdf) replace


clear
*End of file
