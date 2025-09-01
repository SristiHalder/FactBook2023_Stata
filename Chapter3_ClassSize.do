*******************************************************************************
* Fact Book
* Chapter: 3 Student Experience
* 
* Output: 
*	- StudentEx_class_size_under_20_2011-2017
*
*******************************************************************************


version 14
clear all
set more off
capture log close

global root //insert your working directory here

** The rest of these globals should work independent of the path above
global input "$root/Stata/Chapter 3 Student Experience/input"
global temp "$root/Stata/Chapter 3 Student Experience/temp"
global png "$root/Stata/_png"
global wmf "$root/Stata/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"

 ** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"


*************************************************************************
* Import and prepare the current year data (CDS)
*************************************************************************


* Import and prepare the data
import excel "$cds/HEDS_23-24_CDS_Comparison_Tool_Published_2024-07-10.xlsm", sheet("Part I Faculty and Class Size") firstrow cellrange(B23) clear
keep if inlist(UnitID,$comparison)
keep UnitID  AF AG AH AI AJ AK AL AM Institution
rename AF _2_9UGs
rename AG _10_19UGs
rename AH _20_29UGs
rename AI _30_39UGs
rename AJ _40_49UGs
rename AK _50_99UGs
rename AL _100UGs
rename AM _total
destring, replace


** Find percentage of sections that are under 20 or over 50
	*Replace missing data with zero
		*Replace existing zero data points to missing data
		mvdecode _all, mv(0)
		*Replace all new misssing to zero
		mvencode _all, mv(0)

	* Calculate groupings
	gen under20_2020 = (_2_9UGs+_10_19UGs)           / _total
	gen under30_2020 = (_2_9UGs+_10_19UGs+_20_29UGs) / _total
	gen over50_2020  = (_50_99UGs+_100UGs)           / _total 
	
	gen perc_2_9UGs2020 = _2_9UGs / _total
	gen perc_10_19UGs2020 = _10_19UGs / _total
	gen perc_20_29UGs2020 = _20_29UGs / _total
	gen perc_30_39UGs2020 = _30_39UGs / _total
	gen perc_40_49UGs2020 = _40_49UGs / _total
	gen perc_50_99UGs2020 = _50_99UGs / _total
	gen perc_100UGs2020 = _100UGs / _total
	
keep UnitID Institution under20_* under30_* over50_* perc_*
rename Institution Name 

save "$temp/ClassSize_current.dta", replace

**********************************************************************
* Import and prepare the historical year data from IPEDS 
**********************************************************************


*Import US News Historical Data
import excel "$input/Class Size - US News.xlsx", firstrow clear
	* Remove years that won't be needed
	drop *_2011
	
	* Drop name (use CDS instead)
	drop School
	
save "$temp/ClassSize_historical.dta", replace




**********************************************************
* Combine datasets and prepare together
**********************************************************

use "$temp/ClassSize_current.dta", clear
merge 1:1 UnitID using "$temp/ClassSize_historical.dta"
drop _merge


*rename Institution name
replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (MA)"
replace Name="Kalamazoo" if Name=="Kalamazoo College"
replace Name="Cornell" if Name=="Cornell College"
replace Name="Juniata" if Name=="Juniata College"
replace Name="Linfield" if Name=="Linfield University"
replace Name="Wooster" if Name=="College of Wooster"
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
compress Name 


** Multiply percentages by 100
foreach perc in 2012 2013 2014 2015 2016 2017 2018 2019 2020 {
	replace under20_`perc' = under20_`perc' * 100

	replace over50_`perc' = over50_`perc' * 100
}

	replace under30_2020 = under30_2020 * 100
	

reshape long under20_ under30_ over50_ perc_2_9UGs perc_10_19UGs perc_20_29UGs perc_30_39UGs perc_40_49UGs perc_50_99UGs perc_100UGs , i(UnitID  Name) j(year)

rename under20_ under20
rename under30_ under30
rename over50_ over50

*create median variable
egen med_under20 = median(under20), by (year)
egen med_under30 = median(under30), by (year)
egen med_over50 = median(over50), by (year)

sort year

save "$temp/ClassSize.dta", replace


*************************************
* Graph: Current year, all schools
*************************************


*** Create bar graph of Class Size under 20

use  "$temp/ClassSize.dta", clear

	keep if year == 2020
	drop if missing(under20)
	
	graph hbar (asis) under20, over (Name, sort (1)) ///
	  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
	  title("Sections Under 20 Students, Fall 2020", color(black)) ///
	  ytitle("Percentage") ///
	  scheme(colorblind) ///
	  yscale(reverse) ///
	  note("Note: Data unavailable for Allegheny, Centre, Millsaps, Ohio Wesleyan, Rhodes," "and Ursinus" "Source: Common Data Set") ///
	  bar(1, color("0 56 107")fintensity(100)) ///
	  graphregion(color(white))


	graph export "$png\StudentEx_class_size_under_20.png", as(png) replace
	graph export "$wmf\StudentEx_class_size_under_20.wmf", as(wmf) replace
	graph export "$final\StudentEx_class_size_under_20.pdf", as(pdf) replace


*** Create bar graph of Class Size under 30
 use  "$temp/ClassSize.dta", clear

	keep if year == 2020
	drop if missing(under30)
	
graph hbar (asis) under30, over (Name, sort (1)) ///
  blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
  title("Sections Under 30 Students, Fall 2020", color(black)) ///
  ytitle("Percentage") ///
  scheme(colorblind) ///
 note("Note: Data unavailable for Allegheny, Centre, Millsaps, Ohio Wesleyan, Rhodes," "and Ursinus" "Source: Common Data Set") ///
  bar(1, color("0 56 107") fintensity(100)) ///
  yscale(reverse) ///
  graphregion(color(white))
	  
	graph export "$png\StudentEx_class_size_under_30.png", as(png) replace
	graph export "$wmf\StudentEx_class_size_under_30.wmf", as(wmf)replace
	graph export "$final\StudentEx_class_size_under_30.pdf", as(pdf) replace


*** Create bar graph of all section size distributions
use  "$temp/ClassSize.dta", clear
keep if year == 2020
drop if missing(under30) & missing(under20)
	
** Create bar graph of complete distribution
graph hbar (asis) perc_2_9UGs perc_10_19UGs perc_20_29UGs perc_30_39UGs perc_40_49UGs perc_50_99UGs perc_100UGs , over(Name,sort(under20) label(labsize(small))) percentage stack ///
     legend(order(1 "2-9" 2 "10-19" 3 "20-29" 4 "30-39" 5 "40-49" 6 "50-99" 7 "100+" ) ) ///
	 ytitle ("Percentage") ///
	 title ("Section Size, Fall 2020", size(large) color(black)) ///
	 scheme(colorblind) ///
	 ylabel (0(20) 100) ///
	 note("Note: Data unavailable for Allegheny, Centre, Millsaps, Ohio Wesleyan, Rhodes," "and Ursinus" "Source: Common Data Set") ///
     bar(1, color("0 56 107") fintensity(100)) ///
	 bar(2, color("198 147 10") fintensity(100)) ///
	 bar(3, color("232 17 45") fintensity(100)) /// 
	 bar(4, color("olive_teal") fintensity(100)) ///
	 bar(5, color("green") fintensity(100)) ///
	 bar(6, color("orange") fintensity(100)) ///
	 bar(7, color("yellow") fintensity(100)) ///
	 graphregion(color(white)) ///
	 legend(region(lwidth(none))) 

graph export "$png\StudentEx_class_size_Distribution.png", as(png) replace
graph export "$wmf\StudentEx_class_size_Distribution.wmf", as(wmf) replace
graph export "$final\StudentEx_class_size_Distribution.pdf", as(pdf) replace




**********************************
* Graph: Over time, all schools
**********************************

 use  "$temp/ClassSize.dta", clear


graph twoway (scatter under20 year if Name!= "Beloit") (scatter under20 year if Name== "Beloit")(connected med_under20 year, connect(direct)), ///
    legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Sections Under 20 Students", color(black)) ///
	subtitle("Fall 2012-2020", color(black)) ///
	xtitle("") ///
	ylabel(50 60 70 80 90) ///
	xlabel(2012(1) 2020) ///
	scheme(s2color) ///
	note("Note: 2020 Data unavailable for Allegheny, Centre, Millsaps, Ohio Wesleyan, Rhodes," "and Ursinus" "Source: U.S. News & World Report; Common Data Set") ///
    graphregion(fcolor(white))


graph export "$png/StudentEx_class_size_under_20_historical.png", as(png) replace
graph export "$wmf/StudentEx_class_size_under_20_historical.wmf", as(wmf) replace 	
graph export "$final\StudentEx_class_size_under_20_historical.pdf", as(pdf) replace



*** END OF FILE
