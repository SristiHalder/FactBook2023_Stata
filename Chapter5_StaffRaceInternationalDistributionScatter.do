*******************************************************************************
* Fact Book
* Chapter: 5 Staff
* 
* Output: 
*	- Staff_domestic_minority_scatter
*	- Staff_international_scatter
*	- Staff_white_scatter
*
*******************************************************************************
version 14
clear all
set more off
capture log close

global root //insert your working directory here


** Define other global paths
global input "$root/Stata/Chapter 5 Staff/input"
global temp "$root/Stata/Chapter 5 Staff/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"


***********************************************
* Import and prepare the data
***********************************************

import excel "$input/Staff Race.xlsx", firstrow clear
sort UnitID
keep if inlist(UnitID,$comparison) 
save "$temp/Staff Race Base Data.dta", replace

*rename 
rename Institution Name

replace Name="Illinois Wesleyan" if Name=="Illinois Wesleyan University"
replace Name="Knox" if Name=="Knox College"
replace Name="Agnes Scott" if Name=="Agnes Scott College"
replace Name="Centre" if Name=="Centre College"
replace Name="Wheaton" if Name=="Wheaton College (Massachusetts)"
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


* Save data for use in multiple graphs	
save "$temp/Staff Race Base Data.dta", replace


*****************************************************
** Generate scatter graphs for domestic minorities
*****************************************************
	
use "$temp/Staff Race Base Data.dta", clear

** Generate total domestic minority staff counts yearly

// === 2023 ===
gen DomesticMinorityStaff2023 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2023_OCFulltime + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2023_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2023_O) / ///
     GrandtotalS2023_OCFulltime * 100

// === 2022 ===
gen DomesticMinorityStaff2022 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2022_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2022_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2022_O) / ///
     GrandtotalS2022_OC_RVFullt * 100

// === 2021 ===
gen DomesticMinorityStaff2021 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2021_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2021_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2021_O) / ///
     GrandtotalS2021_OC_RVFullt * 100

// === 2020 ===
gen DomesticMinorityStaff2020 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2020_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2020_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2020_O) / ///
     GrandtotalS2020_OC_RVFullt * 100

// === 2019 ===
gen DomesticMinorityStaff2019 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2019_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2019_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2019_O) / ///
     GrandtotalS2019_OC_RVFullt * 100

// === 2018 ===
gen DomesticMinorityStaff2018 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2018_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2018_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2018_O) / ///
     GrandtotalS2018_OC_RVFullt * 100

// === 2017 ===
gen DomesticMinorityStaff2017 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2017_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2017_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2017_O) / ///
     GrandtotalS2017_OC_RVFullt * 100

// === 2016 ===
gen DomesticMinorityStaff2016 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2016_OC_RVFullti + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2016_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2016_O) / ///
     GrandtotalS2016_OC_RVFullti * 100

// === 2015 ===
gen DomesticMinorityStaff2015 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2015_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2015_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2015_O) / ///
     GrandtotalS2015_OC_RVFullt * 100

// === 2014 ===
gen DomesticMinorityStaff2014 = ///
    (AmericanIndianorAlaskaNative + AsiantotalS2014_OC_RVFullt + BlackorAfricanAmericantotal + ///
     HispanicorLatinototalS2014_ + NativeHawaiianorOtherPacific + TwoormoreracestotalS2014_O) / ///
     GrandtotalS2014_OC_RVFullt * 100


** Keep only relevant variables
keep UnitID Name DomesticMinorityStaff*

** Reshape data from wide to long format
reshape long DomesticMinorityStaff, i(UnitID) j(year)
label variable year "Year"
label variable DomesticMinorityStaff "Percent Domestic Minority Staff"


** Create median line by year
egen med = median(DomesticMinorityStaff), by(year)
sort year

** Generate scatterplot
graph twoway ///
    (scatter DomesticMinorityStaff year if UnitID != 238333, msymbol(circle_hollow) mcolor(gs6)) ///
    (scatter DomesticMinorityStaff year if UnitID == 238333, msymbol(diamond) mcolor(black)) ///
    (line med year, lcolor(red) lpattern(dash)), ///
    legend(label(1 "Comparison Schools") label(2 "Beloit College") label(3 "Median")) ///
    ytitle("Percent") ///
    title("Percentage of Full-Time Staff who are Domestic Minority", color(black)) ///
    subtitle("2014–2023", color(black)) ///
    xlabel(2014(1)2023, angle(45)) ///
    ylabel(, angle(horizontal)) ///
    scheme(s2color) ///
    note("Source: IPEDS. Median calculated across comparison schools.") ///
    graphregion(fcolor(white))

** Export
graph export "$wmf/Staff_domestic_minority_scatter.wmf", as(wmf) replace
graph export "$png/Staff_domestic_minority_scatter.png", as(png) replace
graph export "$pdf/Staff_domestic_minority_scatter.pdf", as(pdf) replace


*****************************************************
** Generate scatter graphs for international
*****************************************************
	
use "$temp/Staff Race Base Data.dta", clear

* Generate international staff percentages for each year (2014–2023)
gen InternationalStaff2014 = (NonresidentalientotalS2014_O / GrandtotalS2014_OC_RVFullt) * 100
gen InternationalStaff2015 = (NonresidentalientotalS2015_O / GrandtotalS2015_OC_RVFullt) * 100
gen InternationalStaff2016 = (NonresidentalientotalS2016_O / GrandtotalS2016_OC_RVFullti) * 100
gen InternationalStaff2017 = (NonresidentalientotalS2017_O / GrandtotalS2017_OC_RVFullti) * 100
gen InternationalStaff2018 = (NonresidentalientotalS2018_O / GrandtotalS2018_OC_RVFullti) * 100
gen InternationalStaff2019 = (NonresidentalientotalS2019_O / GrandtotalS2019_OC_RVFullti) * 100
gen InternationalStaff2020 = (NonresidentalientotalS2020_O / GrandtotalS2020_OC_RVFullti) * 100
gen InternationalStaff2021 = (NonresidentalientotalS2021_O / GrandtotalS2021_OC_RVFullti) * 100
gen InternationalStaff2022 = (USNonresidenttotalS2022_OC / GrandtotalS2022_OC_RVFullti) * 100
gen InternationalStaff2023 = (USNonresidenttotalS2023_OC / GrandtotalS2023_OCFulltime) * 100

* Keep relevant variables
keep UnitID Name InternationalStaff*

* Reshape from wide to long
reshape long InternationalStaff, i(UnitID) j(year)
label variable year "Year"
label variable InternationalStaff "Percent International Staff"

* Calculate median per year
egen med = median(InternationalStaff), by(year)
sort year

* Create the graph
graph twoway ///
    (scatter InternationalStaff year if UnitID != 238333, msymbol(circle_hollow) mcolor(gs6)) ///
    (scatter InternationalStaff year if UnitID == 238333, msymbol(diamond) mcolor(black)) ///
    (line med year, lcolor(red) lpattern(dash)), ///
    legend(label(1 "Comparison Schools") label(2 "Beloit College") label(3 "Median")) ///
    ytitle("Percent") ///
    title("Percentage of Full-Time Staff who are International", color(black)) ///
    subtitle("2014–2023", color(black)) ///
    xlabel(2014(1)2023, angle(45)) ///
    ylabel(, angle(horizontal)) ///
    scheme(s2color) ///
    note("Source: IPEDS. Median calculated across comparison schools.") ///
    graphregion(fcolor(white))

* Export graph
graph export "$wmf/Staff_international_scatter.wmf", as(wmf) replace
graph export "$png/Staff_international_scatter.png", as(png) replace
graph export "$pdf/Staff_international_scatter.pdf", as(pdf) replace


*****************************************************
** Generate scatter graphs for White
*****************************************************

use "$temp/Staff Race Base Data.dta", clear

* Generate percentage of white full-time staff (2014–2023)
gen WhiteStaff2014 = (WhitetotalS2014_OC_RVFullt / GrandtotalS2014_OC_RVFullt) * 100
gen WhiteStaff2015 = (WhitetotalS2015_OC_RVFullt / GrandtotalS2015_OC_RVFullt) * 100
gen WhiteStaff2016 = (WhitetotalS2016_OC_RVFullti / GrandtotalS2016_OC_RVFullti) * 100
gen WhiteStaff2017 = (WhitetotalS2017_OC_RVFullti / GrandtotalS2017_OC_RVFullti) * 100
gen WhiteStaff2018 = (WhitetotalS2018_OC_RVFullti / GrandtotalS2018_OC_RVFullti) * 100
gen WhiteStaff2019 = (WhitetotalS2019_OC_RVFullti / GrandtotalS2019_OC_RVFullti) * 100
gen WhiteStaff2020 = (WhitetotalS2020_OC_RVFullti / GrandtotalS2020_OC_RVFullti) * 100
gen WhiteStaff2021 = (WhitetotalS2021_OC_RVFullti / GrandtotalS2021_OC_RVFullti) * 100
gen WhiteStaff2022 = (WhitetotalS2022_OC_RVFullti / GrandtotalS2022_OC_RVFullti) * 100
gen WhiteStaff2023 = (WhitetotalS2023_OCFulltime / GrandtotalS2023_OCFulltime) * 100

* Keep relevant variables
keep UnitID Name WhiteStaff*

* Reshape to long format
reshape long WhiteStaff, i(UnitID) j(year)
label variable year "Year"
label variable WhiteStaff "Percent Domestic White Staff"

* Median by year
egen med = median(WhiteStaff), by(year)
sort year

* Scatterplot
graph twoway ///
    (scatter WhiteStaff year if UnitID != 238333, msymbol(circle_hollow) mcolor(gs6)) ///
    (scatter WhiteStaff year if UnitID == 238333, msymbol(diamond) mcolor(black)) ///
    (line med year, lcolor(red) lpattern(dash)), ///
    legend(label(1 "Comparison Schools") label(2 "Beloit College") label(3 "Median")) ///
    ytitle("Percent") ///
    title("Percentage of Full-Time Staff who are Domestic White", color(black)) ///
    subtitle("2014–2023", color(black)) ///
    xlabel(2014(1)2023, angle(45)) ///
    ylabel(, angle(horizontal)) ///
    scheme(s2color) ///
    note("Source: IPEDS. Median calculated across comparison schools.") ///
    graphregion(fcolor(white))

* Export
graph export "$wmf/Staff_white_scatter.wmf", as(wmf) replace
graph export "$png/Staff_white_scatter.png", as(png) replace
graph export "$pdf/Staff_white_scatter.pdf", as(pdf) replace

clear
