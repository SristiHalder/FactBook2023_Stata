*******************************************************************************
* Fact Book
* Chapter: 6 Finance and Operations
* 
* Output: 
*	- Finance_est_revenue_2007-2016
*	- Finance_est_revenue
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


* Import and save the data as do files
import excel "$input/Total Enrollment.xlsx", sheet("All") firstrow clear
keep if inlist(UnitID,$comparison) 

rename Fulltimeequivalentfallenroll TotalEnrollment2023
rename D TotalEnrollment2022
rename E TotalEnrollment2021
rename F TotalEnrollment2020
rename G TotalEnrollment2019
rename H TotalEnrollment2018
rename I TotalEnrollment2017
rename J TotalEnrollment2016
rename K TotalEnrollment2015
rename L TotalEnrollment2014
rename M TotalEnrollment2013
rename N TotalEnrollment2012

reshape long TotalEnrollment, i(UnitID) j(year)
label variable year " "
sort year 
save "$temp/Total Enrollment.dta", replace


import excel "$input/State grants and contracts revenue.xlsx", sheet("Grants and Contracts Revenue") firstrow clear
keep if inlist(UnitID,$comparison) 

rename N StateGrants2012
rename M StateGrants2013
rename L StateGrants2014
rename K StateGrants2015
rename J StateGrants2016
rename I StateGrants2017
rename H StateGrants2018
rename G StateGrants2019
rename F StateGrants2020
rename E StateGrants2021
rename D StateGrants2022
rename StategrantsandcontractsTot StateGrants2023
reshape long StateGrants, i(UnitID) j(year)
label variable year " "
sort year
save "$temp/State grants and contract revenue.dta", replace


import excel "$input/Private gifts,grants,and contracts revenue.xlsx", sheet("Gifts Grants Contracts") firstrow clear
keep if inlist(UnitID,$comparison) 

rename N PrivateGifts2012
rename M PrivateGifts2013
rename L PrivateGifts2014
rename K PrivateGifts2015
rename J PrivateGifts2016
rename I PrivateGifts2017
rename H PrivateGifts2018
rename G PrivateGifts2019
rename F PrivateGifts2020
rename E PrivateGifts2021
rename D PrivateGifts2022
rename Privategiftsgrantsandcontr PrivateGifts2023
reshape long PrivateGifts, i(UnitID) j(year)
label variable year " "
sort year
save "$temp/Private gifts,grants,and contracts revenue.dta", replace

	
import excel "$input/Value of Endowed Assets, beginning of fisc year.xlsx", sheet("Endowed Assets") firstrow clear
keep if inlist(UnitID,$comparison) 

rename N EndowedAssets2012
rename M EndowedAssets2013
rename L EndowedAssets2014
rename K EndowedAssets2015
rename J EndowedAssets2016
rename I EndowedAssets2017
rename H EndowedAssets2018
rename G EndowedAssets2019
rename F EndowedAssets2020
rename E EndowedAssets2021
rename D EndowedAssets2022
rename Valueofendowmentassetsatthe EndowedAssets2023
reshape long EndowedAssets, i(UnitID) j(year)
label variable year " "
sort year
save "$temp/Value of Endowed Assets.dta", replace


import excel "$input/Total Revenue from Tuition and Fees.xlsx", sheet("Total Revenue") firstrow clear
keep if inlist(UnitID,$comparison) 

rename TuitionandfeesTotalF1112_ TuitionRev2012
rename TuitionandfeesTotalF1213_ TuitionRev2013
rename TuitionandfeesTotalF1314_ TuitionRev2014
rename TuitionandfeesTotalF1415_ TuitionRev2015
rename TuitionandfeesTotalF1516_ TuitionRev2016
rename TuitionandfeesTotalF1617_ TuitionRev2017
rename TuitionandfeesTotalF1718_ TuitionRev2018
rename TuitionandfeesTotalF1819_ TuitionRev2019
rename TuitionandfeesTotalF1920_ TuitionRev2020
rename TuitionandfeesTotalF2021_ TuitionRev2021
rename TuitionandfeesTotalF2122_ TuitionRev2022
rename TuitionandfeesTotalF2223_ TuitionRev2023
reshape long TuitionRev, i(UnitID) j(year)
label variable year " "
sort year
save "$temp/Total Revenue from Tuition and fees.dta", replace



*Merge data
merge 1:1 UnitID year using "$temp/Total Enrollment.dta"
*keep if _merge == 3
drop _merge
merge 1:1 UnitID year using "$temp/State grants and contract revenue.dta"
*keep if _m == 3
drop _merge
merge 1:1 UnitID year using "$temp/Value of Endowed Assets.dta"
*keep if _m == 3
drop _merge
merge 1:1 UnitID year using "$temp/Private gifts,grants,and contracts revenue.dta"
*keep if _m == 3
drop _merge

* Keep the data of comparison schools only 
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

****************************************
* Calcuate Average Revenue per Student *
****************************************

*create groups per college so that time-series can be set
egen group = group(Name), label
tsset group year

***Revenue per student = tuition+ 4.5% (3-year trailing average of endowment value) + 3-year trailing average of privategifts

*Average endowment value (3-year trailing)
gen endow = (EndowedAssets + L.EndowedAssets +L2.EndowedAssets)/3
gen endow_avg = endow*.045
drop EndowedAssets

*Average enrollment (2-year)
gen enroll_avg = (TotalEnrollment + L.TotalEnrollment)/2
drop TotalEnrollment

*Average Private gifts (3-year average)
gen priv_gift_avg = (PrivateGifts + L.PrivateGifts + L2.PrivateGifts)/3
drop PrivateGifts

*Create total revenue per student

gen total_rev_perstu = (endow_avg + TuitionRev + priv_gift_avg)/enroll_avg

keep UnitID Name total_rev_perstu year
sort total_rev_perstu

replace total_rev_perstu = total_rev_perstu/1000
	

************************************************
* Time Series of Estimated Revenue per student *
************************************************

*adjust for inflation
gen inflation=.

replace inflation =233.916 if year==2014
replace inflation =238.654 if year==2015
replace inflation =240.628 if year==2016
replace inflation =244.786 if year==2017
replace inflation =252.006 if year==2018
replace inflation =256.571 if year==2019
replace inflation =259.101 if year==2020
replace inflation =273.003 if year==2021
replace inflation =296.276 if year==2022
replace inflation =305.691 if year==2023

*create inflation relative to July 2014
gen inflator = 305.691/inflation

gen real_rev = total_rev_perstu*inflator


*gen median to be graphed
egen med = median(real_rev), by(year)
sort year 


graph twoway (scatter real_rev year if Name!= "Beloit" & year >= 2014) (scatter real_rev year if Name== "Beloit" & year >= 2014) (connected med year if year >= 2014, connect(direct)), ///
    legend(label(1 "Comparison Schools") label(2 "Beloit") label(3 "Median")) ///
	ytitle("Estimated Revenue ($, thousands)") ///
	title("Estimated Revenue per Student, Inflation Adjusted", color(black)) ///
	scheme(s2color) ///
	xlabel(2014 (1) 2023) ///
    note("Source: IPEDS") ///
	graphregion(fcolor(white))
	
graph export "$png/Finance_est_revenue_2012-2019.png", as(png) replace	
graph export "$wmf/Finance_est_revenue_2008-2018.wmf", as(wmf) replace	
graph export "$final/Finance_est_revenue_2012-2019.pdf", as(pdf) replace

*******************************************
* Chart of Estimated Revenue per student *
*******************************************

keep if year==2023
		
graph hbar (asis) total_rev_perstu, over (Name, sort (1)) ///
	  blabel(bar, pos(inside) color(white) size(2.0) format(%9.0f)) ///
	  title ("Estimated Revenue per Student, 2023", color(black)) ///
	  scheme(colorblind) ///
	  ytitle("Estimated Revenue ($, thousands)") ///
	  yscale(extend) ///
	  note("Source: IPEDS") ///
	  bar(1, color("0 56 107") fintensity(100)) ///
	  graphregion(color(white))
	  

graph export "$png/Finance_est_revenue.png", as(png) replace
graph export "$wmf/Finance_est_revenue.wmf", as(wmf) replace
graph export "$final/Finance_est_revenue.pdf", as(pdf) replace


clear
