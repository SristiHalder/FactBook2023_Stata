*******************************************************************************
* Fact Book
* Chapter: 4 Full-Time Faculty
* 
* Output: 
*	- Final Tables of Salaries as Percent of ACM (Excel sheet, needs to be printed to PDF for Latex)
*		- raw-full
*		- raw-associate
*		- raw-assistant
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

* define acm schools 
local acm 173258 238333 153144 126678 153162 153384 146427 153834 146481 239017 173902 147341 239628 174844
global acm "173258,238333,153144,126678,153162,153384,146427,153834,146481,239017,173902,147341,239628,174844"
local beloit 238333
global beloit "238333"



********************************************************
*  Create variables for median for each year and rank
*******************************************************


* Import and prepare the data  We've got problem import the data
import excel using "$input/AAUP Total Compilation 2009-2020.xlsx", firstrow clear

*generate medians for each year and each position
egen median_2010_full = median(Salary) if Year == 2010 & Rank=="Full"
egen median_2011_full = median(Salary) if Year == 2011 & Rank=="Full"
egen median_2012_full = median(Salary) if Year == 2012 & Rank=="Full"
egen median_2013_full = median(Salary) if Year == 2013 & Rank=="Full"
egen median_2014_full = median(Salary) if Year == 2014 & Rank=="Full"
egen median_2015_full = median(Salary) if Year == 2015 & Rank=="Full"
egen median_2016_full = median(Salary) if Year == 2016 & Rank=="Full"
egen median_2017_full = median(Salary) if Year == 2017 & Rank=="Full"
egen median_2018_full = median(Salary) if Year == 2018 & Rank=="Full"
egen median_2019_full = median(Salary) if Year == 2019 & Rank=="Full"
egen median_2020_full = median(Salary) if Year == 2020 & Rank=="Full"


egen median_2010_associate = median(Salary) if Year == 2010 & Rank=="Associate"
egen median_2011_associate = median(Salary) if Year == 2011 & Rank=="Associate"
egen median_2012_associate = median(Salary) if Year == 2012 & Rank=="Associate"
egen median_2013_associate = median(Salary) if Year == 2013 & Rank=="Associate"
egen median_2014_associate = median(Salary) if Year == 2014 & Rank=="Associate"
egen median_2015_associate = median(Salary) if Year == 2015 & Rank=="Associate"
egen median_2016_associate = median(Salary) if Year == 2016 & Rank=="Associate"
egen median_2017_associate = median(Salary) if Year == 2017 & Rank=="Associate"
egen median_2018_associate = median(Salary) if Year == 2018 & Rank=="Associate"
egen median_2019_associate = median(Salary) if Year == 2019 & Rank=="Associate"
egen median_2020_associate = median(Salary) if Year == 2020 & Rank=="Associate"


egen median_2010_assistant = median(Salary) if Year == 2010 & Rank=="Assistant"
egen median_2011_assistant = median(Salary) if Year == 2011 & Rank=="Assistant"
egen median_2012_assistant = median(Salary) if Year == 2012 & Rank=="Assistant"
egen median_2013_assistant = median(Salary) if Year == 2013 & Rank=="Assistant"
egen median_2014_assistant = median(Salary) if Year == 2014 & Rank=="Assistant"
egen median_2015_assistant = median(Salary) if Year == 2015 & Rank=="Assistant"
egen median_2016_assistant = median(Salary) if Year == 2016 & Rank=="Assistant"
egen median_2017_assistant = median(Salary) if Year == 2017 & Rank=="Assistant"
egen median_2018_assistant = median(Salary) if Year == 2018 & Rank=="Assistant"
egen median_2019_assistant = median(Salary) if Year == 2019 & Rank=="Assistant"
egen median_2020_assistant = median(Salary) if Year == 2020 & Rank=="Assistant"


******************************************************************
*  Create one variable that holds each year/rank median values
******************************************************************

gen median = . 
replace median = median_2010_full if Year == 2010 & Rank=="Full"
replace median = median_2011_full if Year == 2011 & Rank=="Full"
replace median = median_2012_full if Year == 2012 & Rank=="Full"
replace median = median_2013_full if Year == 2013 & Rank=="Full"
replace median = median_2014_full if Year == 2014 & Rank=="Full"
replace median = median_2015_full if Year == 2015 & Rank=="Full"
replace median = median_2016_full if Year == 2016 & Rank=="Full"
replace median = median_2017_full if Year == 2017 & Rank=="Full"
replace median = median_2018_full if Year == 2018 & Rank=="Full"
replace median = median_2019_full if Year == 2019 & Rank=="Full"
replace median = median_2020_full if Year == 2020 & Rank=="Full"


replace median = median_2010_associate if Year == 2010 & Rank=="Associate"
replace median = median_2011_associate if Year == 2011 & Rank=="Associate"
replace median = median_2012_associate if Year == 2012 & Rank=="Associate"
replace median = median_2013_associate if Year == 2013 & Rank=="Associate"
replace median = median_2014_associate if Year == 2014 & Rank=="Associate"
replace median = median_2015_associate if Year == 2015 & Rank=="Associate"
replace median = median_2016_associate if Year == 2016 & Rank=="Associate"
replace median = median_2017_associate if Year == 2017 & Rank=="Associate"
replace median = median_2018_associate if Year == 2018 & Rank=="Associate"
replace median = median_2019_associate if Year == 2019 & Rank=="Associate"
replace median = median_2020_associate if Year == 2020 & Rank=="Associate"


replace median = median_2010_assistant if Year == 2010 & Rank=="Assistant"
replace median = median_2011_assistant if Year == 2011 & Rank=="Assistant"
replace median = median_2012_assistant if Year == 2012 & Rank=="Assistant"
replace median = median_2013_assistant if Year == 2013 & Rank=="Assistant"
replace median = median_2014_assistant if Year == 2014 & Rank=="Assistant"
replace median = median_2015_assistant if Year == 2015 & Rank=="Assistant"
replace median = median_2016_assistant if Year == 2016 & Rank=="Assistant"
replace median = median_2017_assistant if Year == 2017 & Rank=="Assistant"
replace median = median_2018_assistant if Year == 2018 & Rank=="Assistant"
replace median = median_2019_assistant if Year == 2019 & Rank=="Assistant"
replace median = median_2020_assistant if Year == 2020 & Rank=="Assistant"


**********************************************************************************
*  Restrict to Beloit and calculate Beloit's salaries as percent of median
**********************************************************************************

keep median Name Salary Rank Year
keep if Name=="Beloit"

* Find beloit salaries as a perentage of the ACM Median
gen percent_of_median = Salary/median


* Save out data to create table in excel
save "$output\Final Tables of Salaries as Percent of ACM - raw data.dta", replace


**********************************************************************************
*  Export
**********************************************************************************

** Note: 2021.09.05 For some reason, this code isn't exporting properly. Instead, just copied and pasted the output.


* Export for full professors
use "$output\final Tables of Salaries as Percent of ACM - raw data.dta", clear
keep if Rank == "Full"
export excel "$output\Final Tables of Salaries as Percent of ACM.xlsx", sheet("raw-full") sheetreplace firstrow(var)

* Export for Associate professors
use "$output\Final Tables of Salaries as Percent of ACM - raw data.dta", clear
keep if Rank == "Associate"
export excel "$output\Final Tables of Salaries as Percent of ACM.xlsx", sheet("raw-associate") sheetreplace firstrow(var)  

* Export for full professors
use "$output\Final Tables of Salaries as Percent of ACM - raw data.dta", clear
keep if Rank == "Assistant"
export excel "$output\Final Tables of Salaries as Percent of ACM.xlsx", sheet("raw-assistant") sheetreplace firstrow(var) 



* END OF FILE
