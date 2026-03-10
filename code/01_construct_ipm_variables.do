/****************************************************************************************
PROJECT: Agricultural Diversification and Multidimensional Poverty
FILE:    01_construct_ipm_variables.do

PURPOSE
Construct all indicators required for the Multidimensional Poverty Index (MPI)
using the EHCVM 2018 survey.

AUTHOR:  Armand Djaha
VERSION: 2026
****************************************************************************************/

do "code/00_setup.do"

clear all
set more off
set maxvar 10000

global list_var_menage "grappe menage"

********************************************************************************
* SECTION 1 — FOOD SECURITY (Food Consumption Score - FCS)
********************************************************************************

use "$ROOT/s08b1_me_civ2018.dta", clear

egen menage_id = group($list_var_menage)

* Apply WFP nutritional weights
gen fcs_cereales   = s08b02a * 2
gen fcs_legumineux = s08b02c * 3
gen fcs_legumes    = s08b02d * 1
gen fcs_viande     = s08b02e * 4
gen fcs_fruits     = s08b02f * 1
gen fcs_lait       = s08b02g * 4
gen fcs_huile      = s08b02h * 0.5
gen fcs_sucre      = s08b02i * 0.5
gen fcs_condiments = s08b02j * 0

egen fcs = rowtotal(fcs_cereales fcs_legumineux fcs_legumes ///
                    fcs_viande fcs_fruits fcs_lait fcs_huile fcs_sucre)

label variable fcs "Food Consumption Score (0–112)"

gen fcs_cat = .
replace fcs_cat = 1 if fcs <= 21
replace fcs_cat = 2 if fcs > 21 & fcs <= 35
replace fcs_cat = 3 if fcs > 35

label define fcs_lbl ///
1 "Poor" ///
2 "Borderline" ///
3 "Acceptable"

label values fcs_cat fcs_lbl

gen dep_food_fcs = (fcs_cat==1)

bysort menage_id: keep if _n==1

keep vague grappe menage menage_id fcs fcs_cat dep_food_fcs

save "$OUT/fcs_household_2018.dta", replace


********************************************************************************
* SECTION 2 — FOOD DIVERSITY (SDAM)
********************************************************************************

use "$ROOT/s07b_me_civ2018.dta", clear

egen menage_id = group($list_var_menage)

gen g1 = inlist(s07bq01,1,2,3,4,5,6,7,8,10,11,12,13,14,15,16,17,18,19,20,21,22,123,124,125,126,127,128) & s07bq02==1
gen g2 = inlist(s07bq01,112,113,114,115,116,117,118,120,121) & s07bq02==1
gen g3 = inlist(s07bq01,88,89,90,91,92,93,94,95,96,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111) & s07bq02==1
gen g4 = inlist(s07bq01,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87) & s07bq02==1
gen g5 = inlist(s07bq01,27,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,60) & s07bq02==1
gen g6 = inlist(s07bq01,52,53,54,55,56,57,58,59,173) & s07bq02==1
gen g7 = inlist(s07bq01,61,62,63,64,67,68,70) & s07bq02==1

egen grp1 = max(g1), by(menage_id)
egen grp2 = max(g2), by(menage_id)
egen grp3 = max(g3), by(menage_id)
egen grp4 = max(g4), by(menage_id)
egen grp5 = max(g5), by(menage_id)
egen grp6 = max(g6), by(menage_id)
egen grp7 = max(g7), by(menage_id)

duplicates drop menage_id, force

gen sdam = grp1 + grp2 + grp3 + grp4 + grp5 + grp6 + grp7

gen dep_food = (sdam < 5)

bysort menage_id: keep if _n==1

keep vague grappe menage menage_id dep_food

save "$OUT/sdam_household_2018.dta", replace


********************************************************************************
* SECTION 3 — EDUCATION DIMENSION
********************************************************************************

use "$ROOT/ehcvm_individu_civ2018.dta", clear

egen menage_id = group(grappe menage)

* School attendance deprivation
gen nonsco = inrange(age,6,14) & scol != 1
bys menage_id: egen nbnsco = total(nonsco)
gen dep_desco = (nbnsco > 0)

drop nonsco nbnsco

label variable dep_desco "School attendance deprivation"

* Years of schooling deprivation
gen has_primary = (educ_hi >= 3)
gen age10plus = (age >= 10)

gen prim10plus = has_primary & age10plus

bys menage_id: egen nb_prim = total(prim10plus)

gen dep_educ = (nb_prim == 0)

drop has_primary age10plus prim10plus nb_prim

keep grappe menage menage_id hhweight zae region sousregion milieu sexe dep_desco dep_educ

bys menage_id: keep if _n==1

save "$OUT/education_household_2018.dta", replace


********************************************************************************
* SECTION 4 — LIVING STANDARDS (HOUSING)
********************************************************************************

use "$ROOT/s11_me_civ2018.dta", clear

egen menage_id = group(grappe menage)

gen dep_elec = !inlist(s11q38,1,2,6)

gen dep_eau = !inlist(s11q27a,1,2,3,4,7,8,9,10,11,14) ///
              & !inlist(s11q27b,1,2,3,4,7,8,9,10,11,14)

gen dep_energie = (s11q53__1==1 | s11q53__2==1 | s11q53__3==1 | s11q53__6==1 | s11q53__7==1 | s11q53__8==1)

gen dep_toilet = .
replace dep_toilet = 0 if inlist(s11q55,1,2,3,4,5,6,7)
replace dep_toilet = 1 if inlist(s11q55,8,9,10,11,12)

gen dep_sol = !inlist(s11q21,1,2)
gen dep_toit = !inlist(s11q20,1,2,3)

gen dep_murs = .
replace dep_murs = 0 if inlist(s11q19,1,2,3)
replace dep_murs = 1 if inlist(s11q19,4,5,6,7,8)

gen dep_housing = dep_sol | dep_toit | dep_murs

keep grappe menage vague menage_id dep_elec dep_eau dep_energie dep_toilet dep_housing

save "$OUT/housing_household_2018.dta", replace


********************************************************************************
* SECTION 5 — DURABLE ASSETS
********************************************************************************

use "$ROOT/s12_me_civ2018.dta", clear

egen menage_id = group(grappe menage)

gen radio = (s12q01==19 & s12q02==1)
gen tele = (s12q01==20 & s12q02==1)
gen phone = (s12q01==35 & s12q02==1)
gen ordi = (s12q01==37 & s12q02==1)
gen velo = (s12q01==30 & s12q02==1)
gen moto = (s12q01==29 & s12q02==1)
gen frigo = (s12q01==16 & s12q02==1)
gen voiture = (s12q01==28 & s12q02==1)

egen own_radio = max(radio), by(grappe menage)
egen own_tele = max(tele), by(grappe menage)
egen own_phone = max(phone), by(grappe menage)
egen own_ordi = max(ordi), by(grappe menage)
egen own_velo = max(velo), by(grappe menage)
egen own_moto = max(moto), by(grappe menage)
egen own_frigo = max(frigo), by(grappe menage)
egen own_voiture = max(voiture), by(grappe menage)

gen nb_biens = own_radio + own_tele + own_phone + own_ordi + own_velo + own_moto + own_frigo

gen dep_biens = (nb_biens <= 1 & own_voiture != 1)

bys grappe menage: keep if _n==1

keep grappe menage menage_id vague dep_biens

save "$OUT/assets_household_2018.dta", replace


********************************************************************************
* SECTION 6 — MERGE HOUSEHOLD DATABASE
********************************************************************************

use "$OUT/assets_household_2018.dta", clear

merge 1:1 menage_id using "$OUT/housing_household_2018.dta", nogen
merge 1:1 grappe menage using "$OUT/fcs_household_2018.dta", nogen
merge 1:1 grappe menage using "$OUT/sdam_household_2018.dta", nogen
merge 1:1 grappe menage using "$OUT/education_household_2018.dta", nogen

save "$OUT/household_MPI_database_2018.dta", replace


********************************************************************************
* SECTION 7 — MPI COMPUTATION
********************************************************************************

svyset grappe [pweight=hhweight], strata(zae)

replace dep_food = 1 if dep_food == .

mpi d1(dep_educ dep_desco) ///
    d2(dep_biens dep_elec dep_eau dep_energie dep_toilet dep_housing) ///
    d3(dep_food) ///
    w1(.1666 .1666) ///
    w2(.05555 .05555 .05555 .05555 .05555 .05555) ///
    w3(.3333) ///
    [pweight=hhweight], cutoff(.3333) ///
    deprivedscore(si_mpi) depriveddummy(poor_mpi)

keep vague grappe menage milieu zae region sousregion hhweight menage_id ///
     dep_biens dep_elec dep_eau dep_energie dep_toilet dep_housing ///
     dep_food dep_desco dep_educ poor_mpi si_mpi

export excel using "$OUT/MPI_national.xlsx", firstrow(variables) replace


********************************************************************************
* END OF SCRIPT

********************************************************************************
