*******************************************************************************
* Fact Book
* Chapter: 7 Outcomes
* 
* Aim: Create graphs showing metrics for all students
*
* Output: 
*	- Outcome_metrics_metric_profstaffcare_agree 
*	- Outcome_metrics_metric_profstaffchallenge_agree
*	- Outcome_metrics_metric_mentor_agree 
*	- Outcome_metrics_metric_belong_agree 
*	- Outcome_metrics_metric_project_agree 
*	- Outcome_metrics_metric_internship_agree 
*	- Outcome_metrics_metric_extracurr_agree 
*	- Outcome_metrics_metric_honestdiscuss_agree  
*	- Outcome_metrics_metric_profstaffexcite_agree
*
*******************************************************************************
 
* Set up
version 14
clear all
set more off
capture log close



* Define paths
global root //insert working directory here

global input "$root/Stata/Chapter 7 Outcomes/input"
global temp "$root/Stata/Chapter 7 Outcomes/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

* Define comparison schools
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

*************************************
* Create charts for all students *	
*************************************

* First batch
foreach var in metric_profstaffcare_agree metric_profstaffchallenge_agree {
	use "$temp/Metrics-Graph-Group.dta", clear
	keep if item == "`var'"
	keep if inlist(group, "all", "senior", "junior", "sophomore", "freshman")

	levelsof question if question != "", local(questionline1)
	levelsof subquestion, local(questionline2)

	graph bar percSA_A percN_D_SD, over(group, label(angle(30))) stack ///
		title(`"`questionline2'"') subtitle(`"`questionline1'"') ///
		legend(order(1 "Agree" 2 "Neutral or disagree")) ///
		note("Source: 20 Questions on the Student Experience, 2023-24") ///
		graphregion(fcolor(white)) ///
		blabel(bar, pos(center) gap(-3) color(white) size(3) format(%9.0f)) ///
		bar(1, color("0 56 107") fintensity(80)) ///
		bar(2, color("198 147 10") fintensity(80)) ///
		ytitle("Percentage")

	graph export "$png/Outcome_metrics_`var'.png", as(png) replace
	graph export "$pdf/Outcome_metrics_`var'.pdf", as(pdf) replace
}

foreach var in metric_mentor_agree metric_belong_agree metric_project_agree metric_internship_agree metric_extracurr_agree {
	use "$temp/Metrics-Graph-Group.dta", clear
	keep if item == "`var'"
	keep if inlist(group, "all", "senior", "junior", "sophomore", "freshman")

	levelsof question if question != "", local(questionline1)
	levelsof subquestion, local(questionline2)

	graph bar percSA_A percN_D_SD, over(group, label(angle(30))) stack ///
		title(`"`questionline2'"') subtitle(`"`questionline1'"') ///
		legend(order(1 "Agree" 2 "Neutral or disagree")) ///
		note("Source: 20 Questions on the Student Experience, 2023-24") ///
		graphregion(fcolor(white)) ///
		blabel(bar, pos(center) gap(-3) color(white) size(3) format(%9.0f)) ///
		bar(1, color("0 56 107") fintensity(80)) ///
		bar(2, color("198 147 10") fintensity(80)) ///
		ytitle("Percentage")

	graph export "$png/Outcome_metrics_`var'.png", as(png) replace
	graph export "$pdf/Outcome_metrics_`var'.pdf", as(pdf) replace
}


* Third batch (single item - metric_honestdiscuss_agree)
foreach var in metric_honestdiscuss_agree {
	use "$temp/Metrics-Graph-Group.dta", clear
	keep if item == "`var'"
	keep if inlist(group, "all", "senior", "junior", "sophomore", "freshman")

	levelsof question if question != "", local(questionline1)
	levelsof subquestion, local(questionline2)

	graph bar percSA_A percN_D_SD, over(group, label(angle(30))) stack ///
		title(`"`questionline2'"', size(4.5)) subtitle(`"`questionline1'"') ///
		legend(order(1 "Agree" 2 "Neutral or disagree")) ///
		note("Source: 20 Questions on the Student Experience, 2023-24") ///
		graphregion(fcolor(white)) ///
		blabel(bar, pos(center) gap(-3) color(white) size(3) format(%9.0f)) ///
		bar(1, color("0 56 107") fintensity(80)) ///
		bar(2, color("198 147 10") fintensity(80)) ///
		ytitle("Percentage")

	graph export "$png/Outcome_metrics_`var'.png", as(png) replace
	graph export "$pdf/Outcome_metrics_`var'.pdf", as(pdf) replace
}


* Fourth batch (single item - metric_profstaffexcite_agree)

foreach var in metric_profstaffexcite_agree {
	use "$temp/Metrics-Graph-Group.dta", clear
	keep if item == "`var'"
	keep if inlist(group, "all", "senior", "junior", "sophomore", "freshman")

	levelsof question if question != "", local(questionline1)
	levelsof subquestion, local(questionline2)

	graph bar percSA_A percN_D_SD, over(group, label(angle(30))) stack ///
		title(`"`questionline2'"', size(4.5)) subtitle(`"`questionline1'"') ///
		legend(order(1 "Agree" 2 "Neutral or disagree")) ///
		note("Source: 20 Questions on the Student Experience, 2023-24") ///
		graphregion(fcolor(white)) ///
		blabel(bar, pos(center) gap(-3) color(white) size(3) format(%9.0f)) ///
		bar(1, color("0 56 107") fintensity(80)) ///
		bar(2, color("198 147 10") fintensity(80)) ///
		ytitle("Percentage")

	graph export "$png/Outcome_metrics_`var'.png", as(png) replace
	graph export "$pdf/Outcome_metrics_`var'.pdf", as(pdf) replace
}

* End of file
*******************************************************************************
