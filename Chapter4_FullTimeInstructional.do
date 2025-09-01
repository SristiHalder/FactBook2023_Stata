*******************************************************************************
* Fact Book
* Chapter: 4 Full-Time Faculty
* 
* Output: 
*	- Faculty_full_time_instructional_2016
*	- Faculty_full_time_instructional
*
*******************************************************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 4 Full-Time Faculty/input"
global temp "$root/Stata\Chapter 4 Full-Time Faculty/temp"
global png "$root/Stata\Chapter 4 Full-Time Faculty/_png"
global wmf "$root/Stata\Chapter 4 Full-Time Faculty/_wmfs"
global final "$root/Stata\Chapter 4 Full-Time Faculty/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

* Import and prepare the data
import excel using "$input/All Professors Salary.xlsx", sheet("All Professors") firstrow cellrange(A2)

* Keep the data of comparison schools only 
keep UnitID InstitutionName proftotal* stafftotal*
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

gen full2014=proftotal2014/stafftotal2014*100
gen full2015=proftotal2015/stafftotal2015*100
gen full2016=proftotal2016/stafftotal2016*100
gen full2017=proftotal2017/stafftotal2017*100
gen full2018=proftotal2018/stafftotal2018*100
gen full2019=proftotal2019/stafftotal2019*100
gen full2020=proftotal2020/stafftotal2020*100
gen full2021=proftotal2021/stafftotal2021*100
gen full2022=proftotal2022/stafftotal2022*100
gen full2023=proftotal2023/stafftotal2023*100

* Create bar graph 
graph hbar (asis) full2023, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f))  ///
  ytitle ("Percentage") ///
  title("Percentage of Employees Who are Faculty", color(black)) ///
  subtitle("Full-Time, 2023", color(black)) ///
  note("Source: IPEDS") ///
  scheme(colorblind) ///
  yscale (extend) ///
  bar(1, color("0 56 107") fintensity(100)) ///
  graphregion(color(white))

graph export "$png/Faculty_full_time_instructional1.pdf", as(png) replace
graph export "$wmf/Faculty_full_time_instructional.wmf", as(wmf) replace
graph export "$pdf/Faculty_full_time_instructional1.pdf", as(pdf) replace


************************
* graph time series
************************
reshape long full, i(UnitID) j(year)
label variable year " "


*create median variable
egen med = median(full), by (year)
sort year

graph twoway (scatter full year if UnitID!= 238333) (scatter full year if UnitID== 238333) (connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percentage of Employees Who are Faculty", color(black)) ///
	subtitle("Full-Time", color(black)) ///
	scheme(s2color) ///
	xlabel(2014(1) 2023)  ///
	ylabel(25 30 35 40 45) /// 
	note("Source: IPEDS") ///
    graphregion(fcolor(white))

	 
graph export "$png/Faculty_full_time_instructional.png", as(png) replace	
graph export "$wmf/Faculty_full_time_instructional.wmf", as(wmf) replace		
graph export "$pdf/Faculty_full_time_instructional.pdf", as(pdf) replace

clear



