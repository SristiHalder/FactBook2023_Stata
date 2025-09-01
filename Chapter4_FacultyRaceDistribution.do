TO DEPRECATE


*******************************************************************************
* Fact Book
* Chapter: 4 Full-Time Faculty
* 
* Output: 
*	- Faculty_domestic_minority 
*	- Faculty_international
*	- Faculty_white
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

***********************************************
* Percent Domestic Minority Full-Time Faculty
***********************************************

* Import and prepare the data (current year)
import excel "$cds/2021_HEDS_CDS_2021_Comparison_Tool_2021-04-19.xlsx", sheet("Part I Faculty and Class Size") firstrow cellrange(B23)
keep if inlist(UnitID,$comparison) 
keep UnitID Institution D E F G H
rename D Total2020
rename E domestic2020
rename F Women2020
rename G Men2020
rename H international2020

destring, replace

save "$temp/FacultyRace2020.dta", replace

clear

* Import and prepare the data (historic years)
import excel "$input/Faculty - Race - IPEDS.xlsx", sheet("Faculty Race") firstrow cellrange(A2) clear

*Renaming the variables
gen domestic2023 = aianprof2023 + asianprof2023 + blackprof2023 + hawpacprof2023 + twoprof2023
gen domestic2022 = aianprof2022 + asianprof2022 + blackprof2022 + hawpacprof2022 + twoprof2022
gen domestic2021 = aianprof2021 + asianprof2021 + blackprof2021 + hawpacprof2021 + twoprof2021 
gen domestic2020 = aianprof2020 + asianprof2020 + blackprof2020 + hawpacprof2020 + twoprof2020 
gen domestic2019 = aianprof2019 + asianprof2019 + blackprof2019 + hawpacprof2019 + twoprof2019
gen domestic2018 = aianprof2018 + asianprof2018 + blackprof2018 + hawpacprof2018 + twoprof2018
gen domestic2017 = aianprof2017 + asianprof2017 + blackprof2017 + hawpacprof2017 + twoprof2017 
gen domestic2016 = aianprof2016 + asianprof2016 + blackprof2016 + hawpacprof2016 + twoprof2016 
gen domestic2015 = aianprof2015 + asianprof2015 + blackprof2015 + hawpacprof2015 + twoprof2015 
gen domestic2014 = aianprof2014 + asianprof2014 + blackprof2014 + hawpacprof2014 + twoprof2014

keep if inlist(UnitID,$comparison) 
keep domestic* unknownprof* whiteprof* interprof* UnitID Institution proftotal*

* Merge current year onto historic data
*merge 1:1 UnitID using "$temp/FacultyRace2020.dta" 
*drop _merge

*rename 
rename Institution Name

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


* Generate new variables 
gen DomesticMinority2014 = domestic2014/proftotal2014*100
gen DomesticMinority2015 = domestic2015/proftotal2015*100
gen DomesticMinority2016 = domestic2016/proftotal2016*100
gen DomesticMinority2017 = domestic2017/proftotal2017*100
gen DomesticMinority2018 = domestic2018/proftotal2018*100
gen DomesticMinority2019 = domestic2019/proftotal2019*100
gen DomesticMinority2020 = domestic2020/proftotal2020*100
gen DomesticMinority2021 = domestic2018/proftotal2021*100
gen DomesticMinority2022 = domestic2019/proftotal2022*100
gen DomesticMinority2023 = domestic2020/proftotal2023*100
	
*drop unnecessary data 
keep UnitID Name DomesticMinority*

reshape long DomesticMinority, i(UnitID) j(year)
label variable year " "

*create median variable
egen med = median(DomesticMinority), by (year)
sort year


graph twoway (scatter DomesticMinority year if UnitID!= 238333) (scatter DomesticMinority year if UnitID== 238333)(connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percentage of Faculty who are Domestic Minority", color(black)) ///
    subtitle("Full-Time Faculty", color(black)) ///
	scheme(s2color) ///
    note("Source: IPEDS") ///
	xlabel(2014(1) 2023) ///
	ylabel(0(10) 30) ///
	graphregion(fcolor(white)) 

graph export "$png/Faculty_domestic_minority.png", as(png) replace
graph export "$wmf/Faculty_domestic_minority.wmf", as(wmf) replace
graph export "$final/Faculty_domestic_minority.pdf", as(pdf) replace


graph hbar (asis) DomesticMinority2023, over(Name, sort(1)) ///
    blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
    title("Percentage of Faculty who are Domestic Minority", color(black)) ///
    subtitle("Full-Time, 2023", color(black)) ///
    ytitle("Percentage") ///
    scheme(colorblind) ///
    yscale(extend) ///
    note("Source: IPEDS") ///
    bar(1, color("0 56 107") fintensity(100)) ///
    graphregion(color(white))

graph export "$png/Faculty_domestic_minority_2023.png", as(png) replace
graph export "$wmf/Faculty_domestic_minority_2013.wmf", as(wmf) replace
graph export "$final/Faculty_domestic_minority_2023.pdf", as(pdf) replace 
	


clear
***********************************************
* Percent International Full Time Faculty
***********************************************
* Import and prepare the data (historic years)
import excel "$input/Faculty - Race - IPEDS.xlsx", sheet("Faculty Race") firstrow cellrange(A2) clear

*Renaming the variables
gen domestic2023 = aianprof2023 + asianprof2023 + blackprof2023 + hawpacprof2023 + twoprof2023
gen domestic2022 = aianprof2022 + asianprof2022 + blackprof2022 + hawpacprof2022 + twoprof2022
gen domestic2021 = aianprof2021 + asianprof2021 + blackprof2021 + hawpacprof2021 + twoprof2021 
gen domestic2020 = aianprof2020 + asianprof2020 + blackprof2020 + hawpacprof2020 + twoprof2020 
gen domestic2019 = aianprof2019 + asianprof2019 + blackprof2019 + hawpacprof2019 + twoprof2019
gen domestic2018 = aianprof2018 + asianprof2018 + blackprof2018 + hawpacprof2018 + twoprof2018
gen domestic2017 = aianprof2017 + asianprof2017 + blackprof2017 + hawpacprof2017 + twoprof2017 
gen domestic2016 = aianprof2016 + asianprof2016 + blackprof2016 + hawpacprof2016 + twoprof2016 
gen domestic2015 = aianprof2015 + asianprof2015 + blackprof2015 + hawpacprof2015 + twoprof2015 
gen domestic2014 = aianprof2014 + asianprof2014 + blackprof2014 + hawpacprof2014 + twoprof2014

keep if inlist(UnitID,$comparison) 
keep domestic* unknownprof* whiteprof* interprof* UnitID Institution proftotal*

* Merge current year onto historic data
*merge 1:1 UnitID using "$temp/FacultyRace2020.dta" 
*drop _merge



*rename 
rename Institution Name


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




*destring all the variables 
destring `var', replace 
gen International2014 = interprof2014/proftotal2014*100
gen International2015 = interprof2015/proftotal2015*100
gen International2016 = interprof2016/proftotal2016*100
gen International2017 = interprof2017/proftotal2017*100
gen International2018 = interprof2018/proftotal2018*100
gen International2019 = interprof2019/proftotal2019*100
gen International2020 = interprof2020/proftotal2020*100
gen International2021 = interprof2021/proftotal2021*100
gen International2022 = interprof2022/proftotal2022*100
gen International2023 = interprof2023/proftotal2023*100

*drop unnecessary data 
keep UnitID Name International*

reshape long International, i(UnitID) j(year)
label variable year " "

*create median variable
egen med = median(International), by (year)
sort year


graph twoway (scatter International year if UnitID!= 238333) (scatter International year if UnitID== 238333)(connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percentage of Faculty who are International", color(black)) ///
	subtitle("Full-Time Faculty", color(black)) ///
	scheme(s2color) ///
    note("Note: International is defined as non-resident aliens. Green card holders and naturalized U.S.""citizens are not included here.""Source: IPEDS") ///
	xlabel(2014(1) 2023) ///
	ylabel(0(5) 15) ///
	graphregion(fcolor(white)) 
	
	
graph export "$png/Faculty_international.png", as(png) replace
graph export "$wmf/Faculty_international.wmf", as(wmf) replace
graph export "$final/Faculty_international.pdf", as(pdf) replace

* Graph: Faculty International, current year, Beloit and comparison
drop if International2023 == 0

graph hbar (asis) International2023, over (Name, sort (1)) ///
  blabel(bar, pos(outside) color(black) size(2) format(%9.0f)) ///
  title ("Percentage of Faculty who are International", color(black)) ///
  subtitle("Full-Time, 2023", color(black)) ///
  ytitle ("Percentage") ///
  scheme(colorblind) ///
  yscale(extend) ///
  note("Note: International is defined as non-resident aliens. Green card holders and ""naturalized U.S.citizens are not included here." "Source: IPEDS" ) ///
  bar(1, color("0 56 107") fintensity(100))	///
  graphregion(color(white))
  
  
graph export "$png/Faculty_international_2023.png", as(png) replace
graph export "$wmf/Faculty_international_2023.wmf", as(wmf) replace 
graph export "$final/Faculty_international_2023.pdf", as(pdf) replace


********************************************
* Percent White Full Time Faculty 
********************************************

*Import 2019 CDS Data
import excel "$cds/2021_HEDS_CDS_2021_Comparison_Tool_2021-04-19.xlsx", sheet("Part I Faculty and Class Size") firstrow cellrange(B23) clear
keep if inlist(UnitID,$comparison) 
keep UnitID Institution D E F G H
rename D total2020
rename E domestic2020
rename F Women2020
rename G Men2020
rename H international2020
destring, replace
replace international2020=0 if international2020==.
replace domestic2020=0 if domestic2020==.
gen white2020= total2020-international2020-domestic2020
save "$temp/FacultyRace2020.dta", replace
clear

* Import and prepare the data (historic years)
import excel "$input/Faculty - Race - IPEDS.xlsx", sheet("Faculty Race") firstrow cellrange(A2) clear


gen domestic2023 = aianprof2023 + asianprof2023 + blackprof2023 + hawpacprof2023 + twoprof2023
gen domestic2022 = aianprof2022 + asianprof2022 + blackprof2022 + hawpacprof2022 + twoprof2022
gen domestic2021 = aianprof2021 + asianprof2021 + blackprof2021 + hawpacprof2021 + twoprof2021 
gen domestic2020 = aianprof2020 + asianprof2020 + blackprof2020 + hawpacprof2020 + twoprof2020 
gen domestic2019 = aianprof2019 + asianprof2019 + blackprof2019 + hawpacprof2019 + twoprof2019
gen domestic2018 = aianprof2018 + asianprof2018 + blackprof2018 + hawpacprof2018 + twoprof2018
gen domestic2017 = aianprof2017 + asianprof2017 + blackprof2017 + hawpacprof2017 + twoprof2017 
gen domestic2016 = aianprof2016 + asianprof2016 + blackprof2016 + hawpacprof2016 + twoprof2016 
gen domestic2015 = aianprof2015 + asianprof2015 + blackprof2015 + hawpacprof2015 + twoprof2015 
gen domestic2014 = aianprof2014 + asianprof2014 + blackprof2014 + hawpacprof2014 + twoprof2014

keep if inlist(UnitID,$comparison) 
keep domestic* unknownprof* whiteprof* interprof* UnitID Institution profmen* profwomen* proftotal*

* Merge current year onto historic data
*merge 1:1 UnitID using "$temp/FacultyRace2020.dta" 
*drop _merge



*rename Institution name
rename Institution Name

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
	
* Generate new variables 
gen White2014 = whiteprof2014/proftotal2014*100
gen White2015 = whiteprof2015/proftotal2015*100
gen White2016 = whiteprof2016/proftotal2016*100
gen White2017 = whiteprof2017/proftotal2017*100
gen White2018 = whiteprof2018/proftotal2018*100
gen White2019 = whiteprof2019/proftotal2019*100
gen White2020 = whiteprof2020/proftotal2020*100
gen White2021 = whiteprof2021/proftotal2021*100
gen White2022 = whiteprof2022/proftotal2022*100
gen White2023 = whiteprof2023/proftotal2023*100

*drop unnecessary data 
keep UnitID Name White*


reshape long White, i(UnitID) j(year)
label variable year " "

*create median variable
egen med = median(White), by (year)
sort year

graph twoway (scatter White year if UnitID!= 238333) (scatter White year if UnitID== 238333) (connected med year, connect(direct)), ///
	legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle(Percentage) ///
	title("Percentage of Faculty who are Domestic White ", color(black)) ///
	subtitle("Full-Time Faculty", color(black)) ///
	scheme(s2color) ///
    note("Note: 2017 domestic white also includes domestic faculty of unknown race/ethnicity""Source: IPEDS") ///
	xlabel(2014(1) 2023) ///
	graphregion(fcolor(white)) 
 
graph export "$png/Faculty_white.png", as(png) replace
graph export "$wmf/Faculty_white.wmf", as(wmf) replace
graph export "$final/Faculty_white.pdf", as(pdf) replace



** END OF FILE
