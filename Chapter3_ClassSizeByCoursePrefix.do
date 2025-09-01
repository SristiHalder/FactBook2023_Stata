*******************************************************************************
* Fact Book
* Chapter: 3 Student Experience
* 
* Output: 
*	- StudentEx_average_class_department
*	- StudentEx_count_of_courses_2017

*******************************************************************************

version 14
clear all
set more off
capture log close

** Define the correct global path
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


**************************************************************************
* Graph: Histogram showing number of courses by class size
**************************************************************************

import excel "$root/Stata/Chapter 3 Student Experience/input/EnrollmentNumbersbyCoursePrefix.xlsx", sheet("Raw Data") firstrow clear
	
* Create graph
histogram crs_enrollment, discrete frequency ytitle(Count of Courses) xtitle(Class Size) ///
  title("Count of Courses by Class Size", color(black)) ///
  subtitle("2023-24 Academic Year") ///
  scheme(s2color) ///
  note("Source: Beloit College 2023-24 Course Registration Data, as of Arpil 10, 2024") ///
  graphregion(fcolor(white)) ///
  bcolor("0 56 107")

graph export "$png/StudentEx_course_size_distribution.png", as(png) replace
graph export "$pdf/StudentEx_course_size_distribution.pdf", as(pdf) replace



********************************************************************
* Graph: Average class size by course prefix
********************************************************************


import excel "$input/EnrollmentNumbersbyCoursePrefix.xlsx", sheet("Raw Data") firstrow clear

	* Find averages by department (course prefix)
	gen crs_count = 1
	collapse (sum) crs_count crs_enrollment, by (crse_dept)
	gen classavg = crs_enrollment / crs_count 
	rename crse_dept dept
	rename crs_enrollment dept_enrollment
	
* Create bar graph
graph hbar (asis) classavg, over (dept, sort (1) label(labsize(tiny))) ///
	blabel(bar, pos(inside) color(white) size(1) format(%9.0f)) ///
	title("Average Class Size by Course Prefix", color(black)) ///
	subtitle("2023-24 Academic Year") ytitle("Average Class Size") ///
	scheme(colorblind) ///
	note("Note: Methodology is same as Departmental Reports for Tenure Track Planning""Beloit College 2023-24 Course Registration Data, as of Arpil 10, 2024") ///
	bar(1, color("0 56 107")fintensity(100)) graphregion(color(white))
 
graph export "$png/StudentEx_average_class_department.png", as(png) replace
graph export "$pdf/StudentEx_average_class_department.pdf", as(pdf) replace


** END OF FILE  

