*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_summary_freshmen_financial_aid_Beloit
*	- Finance_average_principle_borrowed_Beloit
*	- Finance_percentage_borrowed_Beloit
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

** NOTE FOR NEXT YEAR: CHANGE THIS IMPORT LINE TO PULL DIRECTLY FROM THE CDS FILES
import excel "$input/Student Loans Beloit .xlsx", sheet("Loans") firstrow clear

** Format variables for graphing
gen Rate = AverageofNeedThatWasMeto * 100
gen awardRate = ofStudentsinLineCWhoWere/ofDegreeSeekingUGs*100
gen metRate = ofStudentsinLineDWhoseNe/ofDegreeSeekingUGs*100
gen borrowRate = ofStudentsinGraduatingClas*100

destring (borrowRate), replace

label var awardRate "Students who were awarded aid"
label var metRate "Students whose need was fully met"
label var Rate "Average financial need met"

** Create inflation adjusted borrowing figures using BLS Urban CPI for July 2016 *
* (source: Bureau of Labor Statistics Data CPI.pdf)
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

gen real_borrowed=AveragePerUGBorrowerCumulati*inflator
gen real_borrowed_thou = real_borrowed/1000

********************************************************************************
* Graph 
********************************************************************************
drop if Year < 2014
** Average percent of need met, for freshman awarded any need-based aid
graph bar (asis) Rate, over (Year, sort (Year)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%12.1f)) ///
  title("Average Percent of Need Met", color(black)) ///
  subtitle("Freshman awarded any need-based aid", color(black)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Finance_percentage_need_met_Beloit.png", as(png) replace
graph export "$wmf\Finance_percentage_need_met_Beloit.wmf", as(wmf) replace
graph export "$final/Finance_percentage_need_met_Beloit.pdf", as(pdf) replace


** Summary of Freshman Financial Aid -- Need Met
graph twoway (connected metRate Year)(connected Rate Year), legend(size(small)) ///
	ylabel(0(20) 100) ///
	ytitle("Percentage") ///
	xlabel(2014(1) 2023) ///
	title("Summary of Financial Need Met, Beloit", color(black)) ///
	subtitle("Freshman awarded any need-based aid", color(black)) ///
	note("Source: Common Data Set" ) ///						 
    graphregion(color(white))

graph export "$png/Finance_summary_freshmen_financial_aid_Beloit.png", as(png) replace
graph export "$wmf/Finance_summary_freshmen_financial_aid_Beloit.wmf", as(wmf) replace
graph export "$final/Finance_summary_freshmen_financial_aid_Beloit.pdf", as(pdf) replace


** Percentage of students whose need was fully met
graph bar (asis) metRate, over (Year, sort (Year)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%12.1f)) ///
  title("Percent of Students Whose Need was Fully Met", color(black)) ///
  subtitle("Freshman awarded any need-based aid", color(black)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Finance_percentage_need_fully_met_freshmen_Beloit.png", as(png) replace
graph export "$wmf\Finance_percentage_need_fully_met_freshmen_Beloit.wmf", as(wmf) replace
graph export "$final/Finance_percentage_need_fully_met_freshmen_Beloit.pdf", as(pdf) replace


** Percentage of students who took out loans
graph bar (asis) borrowRate, over (Year, sort (Year)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%12.1f)) ///
  title("Percentage of Students Who Borrowed from Any Loan Program", color(black) size(medium)) ///
  subtitle("Graduating seniors") ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
  note("Source: Common Data Set") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Finance_percentage_borrowed_Beloit.png", as(png) replace
graph export "$wmf\Finance_percentage_borrowed_Beloit.wmf", as(wmf) replace
graph export "$final/Finance_percentage_borrowed_Beloit.pdf", as(pdf) replace

** Average principle borrows for graduates who borrowed any
graph bar (asis) real_borrowed_thou , over (Year, sort (Year)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%12.1f)) ///
  title("Average Principal Borrowed, inflation adjusted", color(black) size(4)) ///
  subtitle("Graduating Seniors who Borrowed from any Loan Program") ///
  ytitle("Borrowed per Student ($, thousands)") ///
  scheme(colorblind) ///
  note("Note: Inflation adjustment using Bureau of Labor Statistics: CPI-All Urban Consumers" "Source: Common Data Set" ) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))
  

graph export "$png/Finance_average_principle_borrowed_Beloit.png", as(png) replace
graph export "$wmf\Finance_average_principle_borrowed_Beloit.wmf", as(wmf) replace
graph export "$final/Finance_average_principle_borrowed_Beloit.pdf", as(pdf) replace

clear

*End of file



