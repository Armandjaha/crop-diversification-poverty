/****************************************************************************************
PROJECT: Agricultural Diversification and Multidimensional Poverty
FILE:    03_structural_controls_diversification.do

PURPOSE
Construct structural control variables related to agricultural diversification:

1. Agricultural capital constraints (tools)
2. Credit market constraints
3. Know-how trap (household head literacy)
4. Price shock vulnerability
5. Merge structural controls with diversification dataset

DATA SOURCE
EHCVM 2018 – Côte d'Ivoire

AUTHOR: Armand Djaha, MSc
VERSION: 2026.1
****************************************************************************************/

do "$CODE/00_setup.do"

clear all
set more off
set maxvar 10000


********************************************************************************
* SECTION 1 — AGRICULTURAL CAPITAL CONSTRAINTS (TOOLS)
********************************************************************************

use "$ROOT/s19_me_civ2018.dta", clear

egen menage_id = group(grappe menage), label

* Detect inconsistencies
gen miss_q4 = missing(s19q04)

count if s19q03==2 & !missing(s19q04)
count if s19q03==1 & missing(s19q04)

* Binary tool ownership
gen has_tool = cond(s19q03==1,1,0)

label define bin 0 "No" 1 "Yes"
label values has_tool bin

replace s19q04 = 0 if s19q04==.

gen nb_tools = has_tool * s19q04

bys menage_id: egen total_tools = total(nb_tools)

* Winsorization
gen total_tools_w = total_tools
replace total_tools_w = 30 if total_tools > 30

label var total_tools_w "Total agricultural tools (winsorized)"

* Poverty trap indicator
gen trap_tools = (total_tools_w == 0)
label var trap_tools "Household owns no agricultural tools"

* Equipment level
gen tool_level = .
replace tool_level = 0 if total_tools_w == 0
replace tool_level = 1 if inrange(total_tools_w,1,3)
replace tool_level = 2 if total_tools_w >= 4

label define tool_lvl ///
0 "No tools" ///
1 "Very low equipment" ///
2 "Minimum equipment"

label values tool_level tool_lvl

bys menage_id: keep if _n==1

keep vague grappe menage menage_id total_tools_w trap_tools tool_level

save "$OUT/tools_household_2018.dta", replace


********************************************************************************
* SECTION 2 — CREDIT MARKET CONSTRAINTS
********************************************************************************

use "$ROOT/s06_me_civ2018.dta", clear

egen menage_id = group(grappe menage), label

gen rep_s06q04 = !missing(s06q04)

label var rep_s06q04 "Individual responded to credit question"

gen obstacle_credit = .
replace obstacle_credit = inlist(s06q04,1,2,3,4,6) if rep_s06q04==1

label var obstacle_credit "Credit market obstacle"

bys menage_id: egen credit_constraint = max(obstacle_credit)

bys menage_id: egen n_credit_constraint = total(obstacle_credit)

label var credit_constraint "Household structurally credit constrained"
label var n_credit_constraint "Number of reported credit obstacles"

bys menage_id: keep if _n==1

keep vague grappe menage menage_id credit_constraint n_credit_constraint

save "$OUT/credit_household_2018.dta", replace


********************************************************************************
* SECTION 3 — KNOW-HOW TRAP (HOUSEHOLD HEAD LITERACY)
********************************************************************************

use "$ROOT/s02_me_civ2018.dta", clear

egen menage_id = group(grappe menage), label

merge 1:1 grappe menage s01q00a ///
using "$ROOT/s01_me_civ2018.dta", keepusing(s01q02)

drop _merge

* Keep household head only
keep if s01q02 == 1

egen n_nonmiss_lit = rownonmiss( ///
s02q01__1 s02q01__2 s02q01__3 ///
s02q02__1 s02q02__2 s02q02__3)

gen chef_lit_info_complete = (n_nonmiss_lit == 6)

* Reading indicators
gen lire1 = (s02q01__1==1)
gen lire2 = (s02q01__2==1)
gen lire3 = (s02q01__3==1)

* Writing indicators
gen ecrire1 = (s02q02__1==1)
gen ecrire2 = (s02q02__2==1)
gen ecrire3 = (s02q02__3==1)

egen yes_lire = rowtotal(lire1 lire2 lire3)
egen yes_ecrire = rowtotal(ecrire1 ecrire2 ecrire3)

gen chef_alphabetise = (yes_lire>=1 | yes_ecrire>=1) if chef_lit_info_complete==1

gen trap_knowhow = (chef_alphabetise==0)

label var trap_knowhow "Know-how trap: household head illiterate"

keep menage_id grappe menage trap_knowhow

save "$OUT/knowhow_household_2018.dta", replace


********************************************************************************
* SECTION 4 — PRICE SHOCK VULNERABILITY
********************************************************************************

use "$ROOT/s14_me_civ2018.dta", clear

egen menage_id = group(grappe menage), label

gen shock_price = inlist(s14q01,109,110)

label define chocprix 0 "No" 1 "Yes", replace
label values shock_price chocprix

gen affected = (s14q02==1) if !missing(s14q02)

gen impact_agri = (s14q04a==2 | s14q04c==2) if shock_price==1 & affected==1

gen trap_price_risk = (shock_price==1 & affected==1 & impact_agri==1)

bys menage_id: egen volat_prix = max(shock_price==1 & affected==1)

bys menage_id: egen nb_chocs_prix = total(shock_price==1 & affected==1)

bys menage_id: egen choc_grave = max(trap_price_risk==1)

bys menage_id: keep if _n==1

keep vague grappe menage menage_id volat_prix choc_grave nb_chocs_prix

save "$OUT/price_shocks_household_2018.dta", replace


********************************************************************************
* SECTION 5 — MERGE STRUCTURAL CONTROLS
********************************************************************************

use "$OUT/hhi_2018.dta", clear

merge 1:1 grappe menage ///
using "$OUT/credit_household_2018.dta", keep(master match) nogenerate

merge 1:1 menage_id ///
using "$OUT/knowhow_household_2018.dta", keep(master match) nogenerate

merge 1:1 menage_id ///
using "$OUT/price_shocks_household_2018.dta", keep(master match) nogenerate

merge 1:1 menage_id ///
using "$OUT/tools_household_2018.dta", keep(master match) nogenerate

save "$OUT/diversification_controls_2018.dta", replace


********************************************************************************
* SECTION 6 — MERGE WITH MPI DATASET
********************************************************************************


import excel "$OUT\MPI_national",  firstrow clear
save "$OUT\MPI_national",  replace

use "$OUT/diversification_controls_2018.dta", clear

merge 1:1 grappe menage ///
using "$OUT/MPI_national.dta"

keep if _merge==3
drop _merge


rename vague          wave
rename grappe         cluster
rename menage         household
rename nb_cult        n_crops
rename shannon        shannon_index
rename rev_culture    crop_income
rename valid_rev      valid_income
rename prix_imp       implicit_price
rename rev_tot        total_crop_income
rename rev_trim       total_crop_income_trim
rename lrev_trim      ln_crop_income
rename revenu_pos     market_participation
rename div_decl       declared_diversification
rename typ6           diversification_typology
rename credit_constraint credit_constraint
rename n_credit_constraint      n_credit_constraint
rename trap_knowhow   knowhow_trap
rename volat_prix     price_shock
rename nb_chocs_prix  n_price_shocks
rename choc_grave     severe_price_shock
rename trap_tools     tools_trap
rename tool_level     tools_level

rename dep_biens      dep_assets
rename dep_elec       dep_electricity
rename dep_eau        dep_water
rename dep_energie    dep_energy
rename dep_housing    dep_housing
rename dep_food       dep_food
rename dep_desco      dep_schooling
rename dep_educ       dep_education

rename si_mpi         mpi_score
rename poor_mpi       mpi_poor


label var year        "Survey year"
label var wave        "Survey wave"
label var cluster     "Sampling cluster"
label var household   "Household ID"
label var zae 		  "Household agro-ecological zone (ZAE)"
label var n_crops     "Number of distinct crops grown"
label var shannon_index "Shannon diversity index (log number of crops)"
label var hhi         "Herfindahl-Hirschman Index (crop concentration)"

label var crop_income "Crop income (CFA), sold crops only"
label var valid_income "Positive income and quantity observed"
label var implicit_price "Implicit crop price (CFA per unit)"
label var total_crop_income "Total crop income (sold crops)"
label var total_crop_income_trim "Total crop income (trimmed 1–99%)"
label var ln_crop_income "Log total crop income (trimmed)"

label var market_participation "Household participates in crop market (income > 0)"
label var declared_diversification "Declared diversification level (3 categories)"
label var diversification_typology "Diversification × market participation typology"

label var credit_constraint "Structurally credit-constrained household (1=yes)"
label var n_credit_constraint "Number credit-constrained household"
label var knowhow_trap "Know-how trap (no literate adult); (1=yes)"

label var price_shock "Household experienced a price shock (1=yes)"
label var n_price_shocks "Number of price shocks experienced (0..2)"
label var severe_price_shock "Severe price shock with negative impact (1=yes)"

label var total_tools_w "Total agricultural tools (winsorized)"
label var tools_trap "No agricultural tools owned (1=yes)"
label var tools_level "Agricultural equipment level; 0=no tool;1=limited ressources"

label var dep_assets "Asset deprivation"
label var dep_electricity "Electricity deprivation"
label var dep_water "Water deprivation"
label var dep_energy "Energy deprivation"
label var dep_housing "Housing deprivation"
label var dep_food "Food deprivation"
label var dep_schooling "School attendance deprivation"
label var dep_education "Education deprivation"

* Deprivation indicators: 1 = deprived, 0 = not deprived
label var dep_assets       "Household is deprived in assets (1=yes)"
label var dep_electricity  "Household is deprived in electricity (1=yes)"
label var dep_water        "Household is deprived in drinking water (1=yes)"
label var dep_energy       "Household is deprived in clean cooking fuel (1=yes)"
label var dep_housing      "Household is deprived in housing quality (1=yes)"
label var dep_food         "Household is deprived in food security (1=yes) fcs"
*label var dep_food_1        "Household is deprived in food security (1=yes) sdam"
label var dep_schooling    "Household is deprived in school attendance (1=yes)"
label var dep_education    "Household is deprived in educational attainment (1=yes)"

label var mpi_score "Multidimensional Poverty score"
label var mpi_poor "Multidimensionally poor household (1=yes)"

* 1) List all string variables 
ds, has(type string)

* 2) Encode each string -> numerical with same name
foreach v in `r(varlist)' {
    encode `v', gen(_`v')   // create numeric version
    drop `v'               // drop string
    rename _`v' `v'        // use the same name
}

* 3) Check that there are no strings left
ds, has(type string)


codebook dep_toilet, tab(100)
recode dep_toilet (2=1) (1=0)
label define lblt 1 "deprived" 0 "Ndeprived"
label values dep_toilet lblt
ren dep_toilet dep_sanitation
label var dep_sanitation   "Household is deprived in sanitation (1=yes)"  

codebook mpi_poor , tab(100)
recode mpi_poor (2=1) (1=0)
label define lblp 1 "poor" 0 "Not poor"
label values mpi_poor lblp
label var  mpi_poor "Household is multidimensionnally poor (1=yes)"
save, replace

save "$OUT/diversification_MPI_dataset_2018.dta", replace


********************************************************************************
* END OF SCRIPT

********************************************************************************





