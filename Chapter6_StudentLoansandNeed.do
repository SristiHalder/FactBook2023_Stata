*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_percentage_need_met_2016
*	- Finance_percentage_need_awarded_aid_2016
*	- Finance_percentage_need_fully_met_freshmen_2016
*	- Finance_percentage_borrowed_2016
*	- Finance_average_principal_borrowed_2016
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


********************************************************************************
* Import and prepare the data
********************************************************************************
*import excel "$cds/2021_HEDS_CDS_2021_Comparison_Tool_2021-04-19.xlsx", sheet("Part H Financial Aid") firstrow cellrange(B23)
*import excel "$input/Student Loans CDS.xlsx", firstrow
import excel "$input/Student Loans (Selected Schools).xlsx", firstrow cellrange(A2)
keep if inlist(UnitID,$comparison)

*keep UnitID Institution Y AB AF AG BH BI
drop Comparison D

*rename variables 
rename E ofDegreeSeekingUGs
rename F ofStudentsinLineCWhoWere
rename G ofStudentsinLineDWhoseNe
rename H AverageofNeedThatWasMeto
rename I ofStudentsinGraduatingClas
rename J AveragePerUGBorrowerCumulati

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

destring, replace


*save "$temp\GDI.dta", replace

* Create rates for graphing
gen Rate = AverageofNeedThatWasMeto * 100
gen awardRate = ofStudentsinLineCWhoWere/ofDegreeSeekingUGs*100
gen metRate = ofStudentsinLineDWhoseNe/ofDegreeSeekingUGs*100

destring ofStudentsinGraduatingClas, replace
*replace ofStudentsinGraduatingClas == "." if ofStudentsinGraduatingCla == "NA"
destring ofStudentsinGraduatingClas, replace

gen borrowRate = ofStudentsinGraduatingClas*100

*replace AveragePerUGBorrowerCumulati = "0" if AveragePerUGBorrowerCumulati == "NA"
destring AveragePerUGBorrowerCumulati, replace

gen averagePerUGBorrowerCumulati = AveragePerUGBorrowerCumulati/1000

*drop schools with unavailable CDS data in 2023: Centre, Kalamazoo, Randolph-Macon, Ursinus, Wheaton
drop if missing(Rate)

save "$temp/graphdata.dta", replace

********************************************************************************
* Graph 
********************************************************************************


** Average percent of need met, 2023, Beloit and comparison schools
use "$temp/graphdata.dta", clear

graph hbar (asis) Rate, over (Name, sort (Rate)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Average Percentage of Need Met", color(black)) ///
  subtitle("Freshman awarded any need-based aid, 2023") ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Note: Data unavailable for Centre, Kalamazoo, Randolph-Macon, Ursinus," "and Wheaton""Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white)) 


graph export "$png/Finance_percentage_need_met.png", as(png) replace
graph export "$wmf\Finance_percentage_need_met_2019.wmf", as(wmf) replace
graph export "$final/Finance_percentage_need_met.pdf", as(pdf) replace

clear
** Convert to IPEDS
** Percent of students who were awarded any aid, 2023, Beloit and comparison schools
import excel "$input/IPEDS - Percent students awarded aid and avg amt .xlsx", sheet("% awarded any financial aid") firstrow clear
keep if inlist(UnitID,$comparison)

rename Institution Name
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

keep UnitID Name Percentoffulltimefirsttime

graph hbar (asis) Percentoffulltimefirsttime, over (Name, sort (Percentoffulltimefirsttime)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Percentage Awarded Any Financial Aid", color(black) size(4)) ///
    subtitle("Freshman, 2023") ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Source: IPEDS") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))


graph export "$png/Finance_percentage_need_awarded_aid.png", as(png) replace
graph export "$wmf\Finance_percentage_need_awarded_aid_2019.wmf", as(wmf) replace
graph export "$final/Finance_percentage_need_awarded_aid.pdf", as(pdf) replace


** Average percent of need met, 2017, Beloit and comparison schools
use "$temp/graphdata.dta", clear

graph hbar (asis) metRate, over (Name, sort (metRate)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Percentage of Students whose Need was Fully Met", size(medium) color(black)) ///
  subtitle("Freshman, 2023") ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Note: Data unavailable for Centre, Kalamazoo, Randolph-Macon, Ursinus," "and Wheaton""Source: Common Data Set" ) ///
  bar(1, color ("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Finance_percentage_need_fully_met_freshmen.png", as(png) replace
graph export "$wmf\Finance_percentage_need_fully_met_freshmen_2017.wmf", as(wmf) replace
graph export "$final/Finance_percentage_need_fully_met_freshmen.pdf", as(pdf) replace



** Average percent of need met, 2020, Beloit and comparison schools
use "$temp/graphdata.dta", clear

drop if Name == "Rhodes"

graph hbar (asis) borrowRate, over (Name, sort (borrowRate)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Percent of Students Who Borrowed from Any Loan Program", size(medium) color(black)) ///
  subtitle("Graduating Seniors, 2023", size (3.7)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Note: Data unavailable for Centre, Kalamazoo, Randolph-Macon, Ursinus," "Rhodes, and Wheaton""Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Finance_percentage_borrowed.png", as(png) replace
graph export "$wmf\Finance_percentage_borrowed_2018.wmf", as(wmf) replace
graph export "$final/Finance_percentage_borrowed.pdf", as(pdf) replace

** Average principle borrowed
use "$temp/graphdata.dta", clear
drop if Name == "Rhodes"
graph hbar (asis) averagePerUGBorrowerCumulati, over (Name, sort (AveragePerUGBorrowerCumulati)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Average Principal Borrowed", color(black) size(4)) ///
  subtitle("Graduating Seniors, 2023") ///
  ytitle("Borrowed per Student ($, thousands)") ///
  scheme(colorblind) ///
  note("Note: Data unavailable for Centre, Kalamazoo, Randolph-Macon, Ursinus," "Rhodes, and Wheaton""Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Finance_average_principal_borrowed.png", as(png) replace
graph export "$wmf\Finance_average_principal_borrowed_2018.wmf", as(wmf) replace
graph export "$final/Finance_average_principal_borrowed.pdf", as(pdf) replace

clear

*End of file

