/****************************************************************************************
PROJECT: Agricultural Diversification and Household Welfare
DATA: EHCVM 2018 – Agricultural Module
AUTHOR: Armand Djaha, MSc
VERSION: 2026.1

DESCRIPTION
This script constructs agricultural diversification indicators at the household level
using the EHCVM 2018 agricultural module. The analysis includes:

1. Identification of households and plots
2. Measurement of declared crop diversification
3. Construction of simplified diversification indices (Shannon, HHI)
4. Cleaning and processing of crop revenue variables
5. Construction of household agricultural income indicators
6. Classification of diversification profiles
7. Construction of diversification–market participation typology
8. Descriptive statistics and survey-weighted analysis

The script produces a cleaned household-level dataset and descriptive outputs.
****************************************************************************************/


/****************************************************************************************
0. ENVIRONMENT SETUP
****************************************************************************************/
do "code/00_setup.do"

/****************************************************************************************
1. LOAD AGRICULTURAL MODULE
****************************************************************************************/

use "$ROOT\s16c_me_civ2018.dta", clear

sort grappe menage


*-------------------------------------------------------------*
* 1.1 Household identifier
*-------------------------------------------------------------*

egen menage_id = group(grappe menage), label


*-------------------------------------------------------------*
* 1.2 Plot identifier
*-------------------------------------------------------------*

egen id_parcelle = group(menage_id s16cq02 s16cq03), label


*-------------------------------------------------------------*
* 1.3 Diagnostic: duplicates at crop × plot level
*-------------------------------------------------------------*

duplicates report menage_id s16cq02 s16cq03 s16cq04


/*
s16cq02 : Field number
s16cq03 : Plot number
s16cq04 : Crop code

The following diagnostic checks whether multiple observations exist for the
same crop cultivated on the same plot and field within a household.
*/


/****************************************************************************************
2. DECLARED CROP DIVERSIFICATION
****************************************************************************************/

*=============================================================*
* 2.1 Number of distinct crops per household
*=============================================================*

egen byte tag_cult = tag(menage_id s16cq04)

bys menage_id: egen nb_cult = total(tag_cult)

label var nb_cult "Number of distinct crops cultivated by the household"


preserve
duplicates drop menage_id nb_cult, force
summ nb_cult
tab nb_cult
restore


/*
Interpretation guideline:

1–2 crops  → specialization or very low diversification
3–5 crops  → moderate diversification
6+ crops   → highly diversified households
*/


*-------------------------------------------------------------*
* 2.2 Simplified diversification indices
*-------------------------------------------------------------*

gen shannon = ln(nb_cult)
label var shannon "Simplified Shannon index (log of crop count)"

gen hhi = 1/nb_cult
label var hhi "Simple HHI index (1/nb_cult) – crop concentration"


duplicates drop menage_id shannon hhi nb_cult, force

summ nb_cult shannon hhi


/*
Since crop area or production value by crop is unavailable,
diversification indices are constructed using equal weights:

Shannon = ln(nb_cult)
HHI     = 1 / nb_cult
*/


/****************************************************************************************
3. CROP SALES REVENUE CLEANING
****************************************************************************************/

*=============================================================*
* 3.1 Crop-level revenue variable
*=============================================================*

gen rev_culture = s16cq17

label var rev_culture "Revenue from crop sales (CFA)"


* Indicator for valid crop revenue observations
gen byte valid_rev = (s16cq15 == 1 & !missing(rev_culture) & s16cq16a > 0)

label var valid_rev "Observed sales revenue with positive quantity"


*-------------------------------------------------------------*
* 3.2 Diagnostics
*-------------------------------------------------------------*

bys menage_id: egen vendeur_obs = max(valid_rev)

summ vendeur_obs

display "Households with at least one crop sale and observed revenue = " r(sum)

drop vendeur_obs


count if s16cq15 == 1 & missing(rev_culture)
display "Sold crops with missing revenue = " r(N)

count if s16cq15 == 1 & rev_culture <= 0 & !missing(rev_culture)
display "Sold crops with zero or negative revenue = " r(N)


/****************************************************************************************
4. IMPLICIT PRICE DIAGNOSTIC
****************************************************************************************/

gen prix_imp = .

replace prix_imp = rev_culture / s16cq16a if valid_rev

label var prix_imp "Implicit price (CFA per unit sold)"

summ prix_imp if valid_rev, detail


scalar p1_prix  = r(p1)
scalar p99_prix = r(p99)


list menage_id s16cq04 s16cq13b rev_culture s16cq12a s16cq16a prix_imp ///
    if valid_rev & (prix_imp <= p1_prix | prix_imp >= p99_prix), sepby(menage_id)


/****************************************************************************************
5. HOUSEHOLD AGRICULTURAL INCOME
****************************************************************************************/

*=============================================================*
* 5.1 Total agricultural revenue
*=============================================================*

bys menage_id: egen rev_tot = total(rev_culture) if valid_rev

label var rev_tot "Total household agricultural sales revenue"


preserve
duplicates drop menage_id rev_tot, force
summ rev_tot if rev_tot < ., detail
restore


*=============================================================*
* 5.2 Trim extreme values
*=============================================================*

preserve
duplicates drop menage_id rev_tot, force
summ rev_tot if rev_tot < ., detail
scalar p1_rev  = r(p1)
scalar p99_rev = r(p99)
restore


gen rev_trim = rev_tot

replace rev_trim = p1_rev  if rev_trim <  p1_rev  & rev_trim < .
replace rev_trim = p99_rev if rev_trim > p99_rev & rev_trim < .

label var rev_trim "Trimmed agricultural revenue (1st–99th percentile)"


*=============================================================*
* 5.3 Log transformation
*=============================================================*

gen lrev_trim = ln(rev_trim)

label var lrev_trim "Log agricultural revenue (trimmed)"


preserve
duplicates drop menage_id lrev_trim, force
summ lrev_trim, detail
restore


/*
Methodological note:

Household agricultural income is highly skewed with extreme values.
To mitigate the influence of outliers:

1. Only observed revenues are used (no imputation)
2. Revenue is trimmed at the 1st and 99th percentiles
3. Log transformation is used for econometric analysis
*/


/****************************************************************************************
6. MARKET PARTICIPATION STATUS
****************************************************************************************/

gen byte revenu_pos = (rev_tot > 0) & !missing(rev_tot)

label define revenu_pos 0 "Non-seller" 1 "Seller"

label values revenu_pos revenu_pos

label var revenu_pos "Household market participation (positive sales)"


preserve
duplicates drop menage_id revenu_pos, force
tab revenu_pos
restore


/***************************************************************************************
7. HOUSEHOLD-LEVEL DATASET
***************************************************************************************/

preserve

keep grappe menage menage_id nb_cult shannon hhi ///
     rev_tot rev_trim lrev_trim revenu_pos

duplicates drop menage_id, force

restore


/***************************************************************************************
8. DIVERSIFICATION CLASSIFICATION
***************************************************************************************/

duplicates drop menage_id nb_cult rev_tot rev_trim lrev_trim revenu_pos, force


gen byte div_decl = .

replace div_decl = 1 if nb_cult <= 2
replace div_decl = 2 if nb_cult >= 3 & nb_cult <= 5
replace div_decl = 3 if nb_cult >= 6


label define div_decl ///
    1 "1–2 crops" ///
    2 "3–5 crops" ///
    3 "6+ crops"


label values div_decl div_decl

label var div_decl "Declared crop diversification"


tab div_decl


/***************************************************************************************
9. DIVERSIFICATION × MARKET TYPOLOGY
***************************************************************************************/

gen byte typ6 = .


replace typ6 = 1 if div_decl==1 & revenu_pos==0
replace typ6 = 2 if div_decl==1 & revenu_pos==1
replace typ6 = 3 if div_decl==2 & revenu_pos==0
replace typ6 = 4 if div_decl==2 & revenu_pos==1
replace typ6 = 5 if div_decl==3 & revenu_pos==0
replace typ6 = 6 if div_decl==3 & revenu_pos==1


label define typ6 ///
1 "1–2 crops & Non-seller" ///
2 "1–2 crops & Seller" ///
3 "3–5 crops & Non-seller" ///
4 "3–5 crops & Seller" ///
5 "6+ crops & Non-seller" ///
6 "6+ crops & Seller"


label values typ6 typ6

label var typ6 "Diversification × market participation typology"


tab typ6, missing

tab div_decl revenu_pos, row col


/***************************************************************************************
10. SAVE OUTPUT DATASET
***************************************************************************************/

keep vague grappe menage menage_id nb_cult shannon hhi ///
     rev_culture valid_rev prix_imp rev_tot rev_trim lrev_trim ///
     revenu_pos div_decl typ6

gen year = 2018

order year

save "$OUT\hhi_2018.dta", replace


/****************************************************************************************
END OF SCRIPT
****************************************************************************************/