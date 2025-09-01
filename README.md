# Fact Book 2023 – Beloit College

This repository contains the **Fact Book 2023–24 for Beloit College**, created in the **Institutional Research, Assessment & Planning (IRAP)** office. The Fact Book provides a comprehensive, data-driven look at Beloit College across multiple dimensions, visualized through **Stata-generated graphics**.

---

## Project Overview

- **Type:** Stata Project  
- **Institution:** Beloit College Institutional Research and Planning Department  
- **Data Coverage:** Through Fall 2023  
- **Purpose:** To visualize Beloit College’s enrollment, student demographics, faculty/staff composition, finances, outcomes, and alumni trends.  
- **Comparisons:** Includes peer and Associated Colleges of the Midwest (ACM) benchmarks for contextual analysis  

Here is the published [Fact Book 2023 PDF](./FactBook_2023.pdf).

---

## Chapters and Code Files  

### Chapter 1: Enrollment  
Focuses on enrollment trends at Beloit and comparison schools.  

- `Chapter1_Admit YieldDraw.do` → Admission yield and draw rate analysis  
- `Chapter1_FullTimeEquivalent.do` → Full-Time Equivalent (FTE) enrollment visualizations  
- `Chapter1_FullTimeFreshmen.do` → First-Time Full-Time (FTFT) freshmen enrollment  
- `Chapter1_HighSchoolGPA.do` → Average and distribution of incoming freshmen GPA  
- `Chapter1_USNewsRank.do` → Beloit’s placement in U.S. News & World Report  

---

### Chapter 2: Student Characteristics  
Examines demographic and socioeconomic makeup of the student body.  

- `Chapter2_GenderDistribution.do` → Gender breakdown of freshmen  
- `Chapter2_GenderDistributionIPEDS.do` → Gender distribution of all students (IPEDS)  
- `Chapter2_PercentReceivingPell.do` → Pell Grant recipients as socioeconomic diversity measure  
- `Chapter2_Race Distfreshtemp.do` → Temporary/alternate race breakdown script for freshmen  
- `Chapter2_Race DistributionAllStudentsIPEDS.do` → Race/ethnicity distribution (all students, IPEDS)  
- `Chapter2_RaceDistribution-freshman.do` → Race/ethnicity of incoming freshmen  
- `Chapter2_RaceDistributionAllStudents.do` → Institutional data on student race/ethnicity  

---

### Chapter 3: Student Experience  
Analyzes retention, graduation, class size, and faculty accessibility.  

- `Chapter3_ClassSize.do` → Course size distribution (under 20, under 30, etc.)  
- `Chapter3_ClassSizeByCoursePrefix.do` → Average class size by course prefix/department  
- `Chapter3_GraduationRate4Year.do` → Four-year graduation rate trends  
- `Chapter3_InstitutionalPerformance.do` → Links retention and graduation to institutional performance  
- `Chapter3_RetentionRate.do` → Sophomore retention analysis  
- `Chapter3_StudentFacultyRatio.do` → Student-to-faculty ratio comparisons  

---

### Chapter 4: Full-Time Faculty  
Examines faculty demographics and salary benchmarking against ACM schools.  

- `Chapter4_Faculty SalaryACM.do` → Beloit vs. ACM faculty salary comparisons  
- `Chapter4_Faculty Salaryf_referenceonly.do` → Supplemental salary analysis (reference only)  
- `Chapter4_FacultyGender.do` → Male vs. female faculty distribution  
- `Chapter4_FacultyRace.do` → Alternate race/ethnicity dataset for faculty  
- `Chapter4_FacultyRaceDistribution.do` → Race/ethnicity composition of faculty  
- `Chapter4_FullTimeInstructional.do` → Counts of full-time instructional faculty  
- `Chapter4_Salaries asPercentACMmedian.do` → Salaries as % of ACM medians  

---

### Chapter 5: Staff  
Covers staff demographics by gender, race, and international representation.  

- `Chapter5_StaffGenderDistribution.do` → Gender breakdown of staff  
- `Chapter5_StaffRaceInternationalDistributionScatter.do` → Scatterplot of staff race/international composition  
- `Chapter5_StaffRaceInternationalDistributionhbar.do` → Horizontal bar chart of staff race/international composition  

---

### Chapter 6: Finance and Operations  
Analyzes Beloit’s financial indicators, aid, borrowing, and resources.  

- `Chapter6_AverageNPSFAperStudent.do` → Average net price after scholarships/aid  
- `Chapter6_AverageNTRperstudent.do` → Average net tuition revenue per student  
- `Chapter6_EndowmentFASB.do` → Endowment per FTE student  
- `Chapter6_EstimatedRevenue.do` → Estimated revenue per student  
- `Chapter6_InstitutionalFinancialAid.do` → Institutional aid awarded to freshmen  
- `Chapter6_InstitutionalPerformanceFinance.do` → Finance metrics linked to institutional performance  
- `Chapter6_StickerPrice.do` → Tuition, fees, room & board sticker price  
- `Chapter6_StudentLoansand NeedBeloit.do` → Beloit-specific borrowing/need trends  
- `Chapter6_StudentLoansandNeed.do` → Borrowing and unmet financial need  
- `Chapter6_TotalInstitutional FinancialAid.do` → Total institutional financial aid  

---

### Chapter 7: Outcomes  
Covers student learning and engagement outcomes from survey data.  

- `Chapter7_CreateMetricsCharts.do` → Generates charts on engagement, belonging, mentoring, and applied learning  
- `Chapter7_Prepareforgraphing.do` → Cleans and prepares survey outcomes data  

---

## Requirements  

- Stata (v15 or later recommended)  
- Access to Beloit College IRAP datasets (IPEDS, CDS, HR, financial, survey data, etc.)  

---

## Setup Notes (Global Root, Subroots, and Input Files)  

All `.do` files are written to use a **single global root directory** (`$root`). Once you set `$root` at the top of your script(s), the code runs consistently across chapters without changing individual paths. You can edit the code to set your own **global** and **subroots** to match your preferred folder organization.  

A common setup is:  
- Define a project-level `$root`.  
- Create per-chapter folders (e.g., “Chapter 1 Enrollment”) with subfolders for inputs, temporary files, and outputs.  
- Keep some globals independent of chapter paths (e.g., shared output folders, CDS data, and U.S. News data).  

Typical subroots expected by the scripts (relative to `$root`):  
- `Stata/Chapter 1 Enrollment/input` — input data for Chapter 1  
- `Stata/Chapter 1 Enrollment/temp` — temporary/intermediate files for Chapter 1  
- `_pdfs` — consolidated PDF outputs  
- `_png` — consolidated PNG outputs  
- `_wmfs` — consolidated WMF outputs  
- `Stata/_pdfs` — final chapter PDFs (project convention)  
- `~CDS data` — Common Data Set directory  
- `Admin/~USNews` — U.S. News data directory  

**Important:** You must also add the necessary **input files** (IPEDS extracts, CDS datasets, Beloit internal data, etc.) into the appropriate `input` folders for each chapter. Without these, the `.do` files cannot generate the figures and tables.  

---

## Notes  

1. All analysis and figures were produced for internal planning by Beloit College IRAP.  
2. Peer comparisons rely on IPEDS, CDS, U.S. News, and ACM datasets.  
3. The **Comparison School list** (Appendix B in the PDF) defines the benchmark institutions used for context.  
