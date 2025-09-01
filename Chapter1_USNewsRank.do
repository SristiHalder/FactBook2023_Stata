*******************************************************************************
* Fact Book
* Chapter: 1 Enrollment
* 
* Output: 
*	- Enrollment_US_News_Score
*
*******************************************************************************

version 14
clear all
set more off
capture log close

global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata\Chapter 1 Enrollment/input"
global temp "$root/Stata\Chapter 1 Enrollment/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

*************************************************************
* Import and prepare the current year data (US News)
*************************************************************


*Import dataset
import excel "$root/Stata/Chapter 1 Enrollment/input/2022-2023bc-national-liberal-arts-colleges.xlsx", cellrange(A7:E208) firstrow clear


* Identify the schools to keep
rename Institution Name
gen comparison = 0
	replace comparison = 1 if index(Name, "Illinois Wesleyan")  //Don't know why Illinois Wesleyan is not in the excel sheet
	replace comparison = 1 if index(Name, "Knox")
	replace comparison = 1 if index(Name, "Agnes Scott")
	replace comparison = 1 if index(Name, "Centre")
	replace comparison = 1 if index(Name, "Wheaton College (MA)")
	replace comparison = 1 if index(Name, "Kalamazoo")
	replace comparison = 1 if index(Name, "Cornell")
	replace comparison = 1 if index(Name, "Juniata")
	replace comparison = 1 if index(Name, "Linfield")
	replace comparison = 1 if index(Name, "Wooster")
	replace comparison = 1 if index(Name, "Allegheny")
	replace comparison = 1 if index(Name, "Millsaps")
	replace comparison = 1 if index(Name, "Ohio Wesleyan")
	replace comparison = 1 if index(Name, "Randolph-Macon")
	replace comparison = 1 if index(Name, "Ursinus")
	replace comparison = 1 if index(Name, "Wofford")
	replace comparison = 1 if index(Name, "Rhodes")
	replace comparison = 1 if index(Name, "Austin")
	replace comparison = 1 if index(Name, "Beloit")
	replace comparison = 1 if index(Name, "Lawrence University")
keep if comparison == 1
drop comparison State PublicPrivate Participation~e

* Format name for graphing	
replace Name="Illinois Wesleyan" if index(Name,"Illinois Wesleyan University")
replace Name="Knox" if index(Name,"Knox College")
replace Name="Agnes Scott" if index(Name,"Agnes Scott College")
replace Name="Centre" if index(Name,"Centre College")
replace Name="Wheaton" if index(Name,"Wheaton College")
replace Name="Kalamazoo" if index(Name,"Kalamazoo College")
replace Name="Cornell" if index(Name,"Cornell College")
replace Name="Juniata" if index(Name,"Juniata College")
replace Name="Linfield" if index(Name,"Linfield University")
replace Name="Wooster" if index(Name,"College of Wooster")
replace Name="Allegheny" if index(Name,"Allegheny College")
replace Name="Millsaps" if index(Name,"Millsaps College")
replace Name="Ohio Wesleyan" if index(Name,"Ohio Wesleyan University")
replace Name="Randolph-Macon" if index(Name,"Randolph-Macon College")
replace Name="Ursinus" if index(Name,"Ursinus College")
replace Name="Wofford" if index(Name,"Wofford College")
replace Name="Rhodes" if index(Name,"Rhodes College")
replace Name="Austin" if index(Name,"Austin College")
replace Name="Beloit" if index(Name,"Beloit College")
replace Name="Lawrence" if index(Name,"Lawrence University")
compress Name
rename Name usnews
rename A Rank

*************************************************************
* Graph current year
*************************************************************

// need to make Rank numeric
destring Rank, replace force

graph hbar Rank, over(usnews, sort(1)) bar(1, color(navy)) blabel(bar, pos(inside) color(white) size(small) format(%9.0f)) title("U.S. News College Score, 2023") subtitle("U.S. News Best National Liberal Arts College Ranking") ytitle("") note("Source: U.S. News") graphregion(color(white)) scheme(s1color)

  
graph export "$pdf/Enrollment_US_News_Score.pdf", as(pdf) replace
graph export "$png/Enrollment_US_News_Score.png", as(png) replace
**Stata for MacOS cannot create wmf files. 

** END OF FILE


** FOR REFERENCE
/*

* To change from carriage return to semicolon
#delimit ;

* Then execute with a semicolon at the end of all the lines
	;

	
* Then change back
	#delimit cr
