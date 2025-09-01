*******************************************************************************
* Fact Book
* Chapter: 7 Outcomes
* 
* Aim: Get the student experience metrics data into a form we can graph
* Output: 
*	- A temporary data file for cleaning data for graphing
*
*
*******************************************************************************


**********
* Set up *
**********

version 14
clear all
set more off
capture log close

* Define paths
global root //insert working directory here

** Define other global paths
global input "$root/Stata/Chapter 7 Outcomes/input"
global temp "$root/Stata/Chapter 7 Outcomes/temp"
global pdf "$root/_pdfs"
global png "$root/_png"
global wmf "$root/_wmfs"
global final "$root/Stata/_pdfs"
global cds "$root/~CDS data"
global usnews "$root/Admin/~USNews"

** Define comparison schools 
global comparison "138600, 210669, 222983, 238333, 156408, 153162, 145646, 213251, 170532, 146427, 239017, 209065, 175980, 204909, 233295, 221351, 206589, 216524, 168281, 218973"
global beloit "238333"

**********************************
* Create groups for sub-analysis *
**********************************

use "$input/student experience analysis dataset_23 Feb 2024.dta", clear 

* Restrict to students who consented to participate
keep if consent == "Y"

gen all = 1

	** Create class flags
	
	gen freshman = 0
		replace freshman = 1 if current_class_cde == "FR"
	gen sophomore = 0
		replace sophomore = 1 if current_class_cde == "SO"
	gen junior = 0
		replace junior = 1 if current_class_cde == "JR"
	gen senior = 0
		replace senior = 1 if current_class_cde == "SR"

	** Create gender flags
	gen male = 0
		replace male = 1 if gender == "M"
	gen female = 0
		replace female = 1 if gender == "F"
		
	
	** Race & Ethnicity
	gen white = 1 if ipeds_value_desc == "White"
	gen international = 1 if ipeds_value_desc == "Nonresident Alien"
	gen domestic_minority = 0
		replace domestic_minority = 1 if ipeds_value_desc == "American Indian or Alaska Native"
		replace domestic_minority = 1 if ipeds_value_desc == "Asian"
		replace domestic_minority = 1 if ipeds_value_desc == "Black or African American"
		replace domestic_minority = 1 if ipeds_value_desc == "Hispanics of any race"
		replace domestic_minority = 1 if ipeds_value_desc == "Native Hawaiian or Other Pacific Islander"
		replace domestic_minority = 1 if ipeds_value_desc == "Two or more races"
		
		
**************************************************
* Create Summary of Institutional Health Metrics *
**************************************************

*… a professor or staff person made them excited about learning	
gen metric_profstaffexcite_agree = "N_D_SD"
	replace metric_profstaffexcite_agree = "SA_A" if profexcite == "A"
	replace metric_profstaffexcite_agree = "SA_A" if profexcite == "SA"
	replace metric_profstaffexcite_agree = "SA_A" if staffexcite == "A"
	replace metric_profstaffexcite_agree = "SA_A" if staffexcite == "SA"
	
*… a professor or staff person care about them as people	
gen metric_profstaffcare_agree = "N_D_SD"
	replace metric_profstaffcare_agree = "SA_A" if profcare == "A"
	replace metric_profstaffcare_agree = "SA_A" if profcare == "SA"
	replace metric_profstaffcare_agree = "SA_A" if staffcare == "A"
	replace metric_profstaffcare_agree = "SA_A" if staffcare == "SA"

*… a professor or staff person challenge them
gen metric_profstaffchallenge_agree = "N_D_SD"
	replace metric_profstaffchallenge_agree = "SA_A" if profchallenge == "A"
	replace metric_profstaffchallenge_agree = "SA_A" if profchallenge == "SA"
	replace metric_profstaffchallenge_agree = "SA_A" if staffchallenge == "A"
	replace metric_profstaffchallenge_agree = "SA_A" if staffchallenge == "SA"
	
* … they have had a mentor who encouraged them to pursue their goals and dreams	
gen metric_mentor_agree = "N_D_SD"
	replace metric_mentor_agree = "SA_A" if mentor == "A"
	replace metric_mentor_agree = "SA_A" if mentor == "SA"

* … they feel a sense of belonging to this campus	
gen metric_belong_agree = "N_D_SD"
	replace metric_belong_agree = "SA_A" if belonging == "A"
	replace metric_belong_agree = "SA_A" if belonging == "SA"

* … they have worked on a project that took a semester or more to complete	
gen metric_project_agree = "N_D_SD"
	replace metric_project_agree = "SA_A" if project == "A"
	replace metric_project_agree = "SA_A" if project == "SA"

* … they have had an internship or job that allowed them to apply what they were learning in the classroom	
gen metric_internship_agree = "N_D_SD"
	replace metric_internship_agree = "SA_A" if internship == "A"
	replace metric_internship_agree = "SA_A" if internship == "SA"

*  … they have been extremely active in extracurricular activities and organizations while attending Beloit College	
gen metric_extracurr_agree = "N_D_SD"
	replace metric_extracurr_agree = "SA_A" if extracurricular == "A"
	replace metric_extracurr_agree = "SA_A" if extracurricular == "SA"

*  … they have participated in discussions regarding social issues with students whose background and perspectives differed from them
gen metric_honestdiscuss_agree = "N_D_SD"
	replace metric_honestdiscuss_agree = "SA_A" if honestdiscuss == "A"
	replace metric_honestdiscuss_agree = "SA_A" if honestdiscuss == "SA"
	 
save "$temp/metrics_working.dta", replace	 


***************************************************************************************
* Find the numbers to populate the table
***************************************************************************************

	* Find total responses for each question
	foreach var in metric_profstaffexcite_agree metric_profstaffcare_agree metric_profstaffchallenge_agree metric_mentor_agree metric_belong_agree metric_project_agree metric_internship_agree metric_extracurr_agree metric_honestdiscuss_agree {
		 di "`var'"
		 use "$temp/metrics_working.dta", clear
		 *drop if `var' == "NA"
		 *replace `var' = trim(`var')
		 collapse (sum) all freshman sophomore junior senior male female ever_athlete disability domestic_minority white international first_gen pell_fa23, by (`var')
		 gen item = "`var'"
		 rename `var' value
		 order item value 
		 save "$temp/data `var'.dta", replace
	}

	* Create blank dataset and append each of the files onto it
		clear
		gen blank = 0
		save "$temp/metrics_class_graph.dta", replace

	* Append into one dataset per question type
	foreach var in metric_profstaffexcite_agree metric_profstaffcare_agree metric_profstaffchallenge_agree metric_mentor_agree metric_belong_agree metric_project_agree metric_internship_agree metric_extracurr_agree metric_honestdiscuss_agree {
		 use "$temp/metrics_class_graph.dta", clear
		 append using "$temp/data `var'.dta"
		 save "$temp/metrics_class_graph.dta", replace
	}
	
	* Save out that question type
	 use "$temp/metrics_class_graph.dta", clear
	 keep item value all senior junior sophomore freshman male female ever_athlete disability domestic_minority white international first_gen pell_fa23
	 order item value all senior junior sophomore freshman male female ever_athlete disability domestic_minority white international first_gen pell_fa23
	 save "$temp/metrics_class_graph.dta", replace
	 

*** Create labels for titles ***
	gen question = ""
	gen subquestion = ""
	
		replace subquestion = "A professor or staff person has made me excited about learning" if item ==  "metric_profstaffexcite_agree" 
		replace question = " " if item ==  "metric_profstaffexcite_agree" 
	
		replace subquestion = "A professor or staff person has challenged me" if item ==  "metric_profstaffchallenge_agree" 
		replace question = " " if item ==  "metric_profstaffchallenge_agree" 

		replace subquestion = "A professor or staff person cares about me as a person" if item ==  "metric_profstaffcare_agree" 
		replace question = " " if item ==  "metric_profstaffcare_agree" 
	
		replace subquestion = "I've had a mentor at Beloit College" if item ==  "metric_mentor_agree" 
		replace question = "who has encouraged me to pursue my goals and dreams" if item ==  "metric_mentor_agree" 
		
		replace subquestion = "I feel a sense of belonging to this campus" if item ==  "metric_belong_agree" 
		replace question = " " if item ==  "metric_belong_agree" 
	
		replace subquestion = "I've had an internship or job" if item ==  "metric_internship_agree" 
		replace question = "that allowed me to apply what I was learning in the classroom" if item ==  "metric_internship_agree" 
	
		replace subquestion = "I've worked on a project that took a semester" if item ==  "metric_project_agree" 
		replace question = "or more to complete" if item ==  "metric_project_agree" 
	
		replace subquestion = "I've been extremely active in extracurricular" if item ==  "metric_extracurr_agree" 
		replace question = "activities and organizations in the last year while attending Beloit College" if item ==  "metric_extracurr_agree" 

		replace subquestion = "I've had meaningful & honest discussions about social issues" if item ==  "metric_honestdiscuss_agree" 
		replace question = "with students whose background or perspectives differ from my own" if item ==  "metric_honestdiscuss_agree" 

order item value
save "$temp/Metrics-Graphing.dta", replace
	
*************** RESHAPE ***********************

* Load the cleaned metrics dataset
use "$temp/Metrics-Graphing.dta", clear

* OPTIONAL: Save the raw count version in case you need it later
save "$temp/Metrics-Graphing-Counts.dta", replace

* Rename all group count variables for reshape compatibility
rename all countall
rename freshman countfreshman
rename sophomore countsophomore
rename junior countjunior
rename senior countsenior
rename male countmale
rename female countfemale
rename ever_athlete countever_athlete
rename disability countdisability
rename domestic_minority countdomestic_minority
rename white countwhite
rename international countinternational
rename first_gen countfirst_gen
rename pell_fa23 countpell_fa23

* Reshape long by demographic group
reshape long count, i(item value question subquestion) j(group) string

* Generate percentage of responses for each group within each metric
bysort item group: egen temp = total(count)
gen perc = 100*(count/temp)
drop count temp

* Reshape wide by response value (SA_A vs. N_D_SD)
reshape wide perc, i(item question subquestion group) j(value) string

* Optional: clean up group names for readability in graphs
replace group = "1-All Students" if group == "countall"
replace group = "2-Senior" if group == "countsenior"
replace group = "3-Junior" if group == "countjunior"
replace group = "4-Sophomore" if group == "countsophomore"
replace group = "5-Freshman" if group == "countfreshman"
replace group = "2-Male" if group == "countmale"
replace group = "3-Female" if group == "countfemale"
replace group = "2-Athlete (ever)" if group == "countever_athlete"
replace group = "2-Disability" if group == "countdisability"
replace group = "2-Domestic Minority" if group == "countdomestic_minority"
replace group = "3-Domestic Majority" if group == "countwhite"
replace group = "2-International" if group == "countinternational"
replace group = "2-First gen college student" if group == "countfirst_gen"
replace group = "2-Low income" if group == "countpell_fa23"

* Save final dataset for graphing
save "$temp/Metrics-Graph-Group.dta", replace

	
* END OF FILE
