*******************************************************************************
* Fact Book
* Chapter: 5 Staff
* 
* Output: 
*	- Staff_domestic_minority_scatter
*	- Staff_international_scatter
*	- Staff_white_scatter

*******************************************************************************
version 14
clear all
set more off
capture log close

** Define the correct global path
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
********************************************************************************

* Import and prepare the data
* Note new name is "Staff Gender.xlsx"
import excel "$input/Staff Gender.xlsx", firstrow
sort UnitID
keep if inlist(UnitID,$comparison) 
save "$temp/Staff Gender Base Data.dta", replace

* rename
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

* save to temp
save "$temp/Staff Gender Base Data.dta", replace

* Generate male share (as % of total full-time staff) for 2014–2023
gen male2014 = GrandtotalmenS2014_OC_RVFul / (GrandtotalmenS2014_OC_RVFul + GrandtotalwomenS2014_OC_RVF) * 100
gen male2015 = GrandtotalmenS2015_OC_RVFul / (GrandtotalmenS2015_OC_RVFul + GrandtotalwomenS2015_OC_RVF) * 100
gen male2016 = GrandtotalmenS2016_OC_RVFul / (GrandtotalmenS2016_OC_RVFul + GrandtotalwomenS2016_OC_RVF) * 100
gen male2017 = GrandtotalmenS2017_OC_RVFul / (GrandtotalmenS2017_OC_RVFul + GrandtotalwomenS2017_OC_RVF) * 100
gen male2018 = GrandtotalmenS2018_OC_RVFul / (GrandtotalmenS2018_OC_RVFul + GrandtotalwomenS2018_OC_RVF) * 100
gen male2019 = GrandtotalmenS2019_OC_RVFul / (GrandtotalmenS2019_OC_RVFul + GrandtotalwomenS2019_OC_RVF) * 100
gen male2020 = GrandtotalmenS2020_OC_RVFul / (GrandtotalmenS2020_OC_RVFul + GrandtotalwomenS2020_OC_RVF) * 100
gen male2021 = GrandtotalmenS2021_OC_RVFul / (GrandtotalmenS2021_OC_RVFul + GrandtotalwomenS2021_OC_RVF) * 100
gen male2022 = GrandtotalmenS2022_OC_RVFul / (GrandtotalmenS2022_OC_RVFul + GrandtotalwomenS2022_OC_RVF) * 100
gen male2023 = GrandtotalmenS2023_OCFullt / (GrandtotalmenS2023_OCFullt + GrandtotalwomenS2023_OCFull) * 100

* Keep only UnitID, institution name, and calculated percentages
keep UnitID Name male2014 male2015 male2016 male2017 male2018 male2019 male2020 male2021 male2022 male2023

* Save output
save "$temp/Staff_Gender_Base_Data.dta", replace


***************************
* bargraph most recent year
***************************

graph hbar (asis) male2023, over(Name, sort(male2023)) ///
    blabel(bar, pos(inside) color(white) size(2) format(%9.0f)) ///
    title("Percent of Staff who are Male", color(black)) ///
    subtitle("Full-Time Staff, 2023", color(black)) ///
    ytitle("Percentage") ///
    scheme(colorblind) ///
    ylabel(0(20)60) ///
    note("Source: IPEDS") ///
    bar(1, color("0 56 107") fintensity(100)) ///
    graphregion(color(white))

graph export "$png/Staff_gender_distribution_hbar.png", as(png) replace	
graph export "$pdf/Staff_gender_distribution_hbar.pdf", as(pdf) replace	


************************
* Graph time series: % Male Staff, 2014–2023
************************

* Reload dataset
use "$temp/Staff_Gender_Base_Data.dta", clear

* Reshape to long format
reshape long male, i(UnitID) j(year)

* Create median line by year
egen med = median(male), by(year)
sort year

* Graph with Beloit highlighted
graph twoway ///
    (scatter male year if UnitID != 238333, msymbol(O) mcolor(gs10)) ///
    (scatter male year if UnitID == 238333, msymbol(D) mcolor(navy)) ///
    (line med year, lpattern(dash) lcolor(black)), ///
    legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
    ytitle("Percentage") ///
    title("Percent of Staff who are Male", color(black)) ///
    subtitle("Full-Time Staff, 2014–2023", color(black)) ///
    xlabel(2014(1)2023) ///
    scheme(s2color) ///
    note("Source: IPEDS") ///
    graphregion(color(white))
	
graph export "$png/Staff_gender_distribution_scatter.png", as(png) replace	
graph export "$pdf/Staff_gender_distribution_scatter.pdf", as(pdf) replace	

clear
