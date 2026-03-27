********************************************************************************
*  DIVERSIFY OR SPECIALIZE?
*  The Role of Market Access in Rural Poverty Reduction
*
*  Empirical pipeline:
*  Baseline relationship -> Mechanism tests (MIT framework) ->
*  Identification of robust empirical patterns ->
*  Interpretable outputs (margins, contrasts, predicted effects)
*
*  DATA
*  Source: EHCVM 2018 household survey (Côte d'Ivoire)
*  Unit of analysis: Household
*
*  MAIN OUTCOME VARIABLE
*  mpi_score : severity of multidimensional poverty (MPI intensity)
*
*  PRODUCTIVE STRUCTURE VARIABLES
*  hhi      : Herfindahl–Hirschman Index of crop concentration
*             (higher value = greater specialization)
*
*  shannon  : Shannon diversity index
*             (higher value = greater diversification)
*
*  n_crops  : number of cultivated crops
*
*  MARKET INTEGRATION
*  market_participation : household sells agricultural output
*
*  STRUCTURAL CONSTRAINTS
*  tools_trap         : lack of agricultural equipment
*  credit_constraint  : credit market imperfections
*  knowhow_trap       : low human capital / lack of productive know-how
*  price_shock        : exposure to agricultural price shocks
*
*  OBJECTIVE
*  This script investigates whether agricultural diversification is associated
*  with multidimensional poverty and explores the economic mechanisms that may
*  explain this relationship.
*
********************************************************************************

do "$CODE/00_setup.do"

clear all
set more off


********************************************************************************
* LOAD HOUSEHOLD DATASET
********************************************************************************

use "$OUT/diversification_MPI_dataset_2018.dta", clear


/*
Conceptual framework (MIT Development Economics)

The empirical strategy follows a progressive approach:

1. Baseline tests
   Examine the unconditional association between diversification
   and multidimensional poverty.

2. Market heterogeneity
   Test whether the diversification–poverty relationship differs
   depending on market participation.

3. Structural constraints
   Evaluate whether diversification patterns are associated with
   structural constraints such as asset ownership, credit access,
   human capital, and exposure to shocks.

4. Income channels
   Investigate whether price shocks affect agricultural income
   and whether specialization amplifies these effects.

5. Robustness
   Verify whether similar patterns appear when monetary welfare
   indicators are used.
*/

label var mpi_score "MPI (intensity)"
label var hhi "HHI"
label var shannon "Shannon index"
label var n_crops "Number of crops"

label var market_participation "Seller"
label var price_shock "Price shock"

label var tools_trap "No agricultural equipment"
label var credit_constraint "Credit constraint"
label var knowhow_trap "Low human capital"

label var ln_crop_income "Log agricultural income"


label var zae "Agro-ecological zone"

********************************************************************************
* 0) TABLE 1: DESCRIPTIVE STATISTICS
********************************************************************************

tabstat mpi_score hhi shannon n_crops [aw=hhweight], ///
    stat(mean sd min max) save

matrix M = r(StatTotal)'

putexcel set "$OUT/tables/descriptive_stats.xlsx", replace
putexcel A1 = "Table 1: Descriptive Statistics", bold
putexcel A3 = matrix(M), names nformat(number_d2)

********************************************************************************
* 1) BASELINE ASSOCIATION BETWEEN DIVERSIFICATION AND MPI
********************************************************************************

describe mpi_score hhi shannon n_crops zae hhweight

sum mpi_score hhi shannon n_crops [aw=hhweight]

eststo m0: reg mpi_score hhi [pw=hhweight], vce(cluster cluster)

eststo m1: reg mpi_score hhi i.zae [pw=hhweight], vce(cluster cluster)

reg mpi_score shannon i.zae [pw=hhweight], vce(cluster cluster)

reg mpi_score n_crops i.zae [pw=hhweight], vce(cluster cluster)



********************************************************************************
* 2) STRUCTURAL CONSTRAINTS AND PRODUCTIVE STRATEGIES
********************************************************************************

describe hhi shannon_index n_crops tools_trap total_tools_w ///
credit_constraint knowhow_trap price_shock ///
n_price_shocks severe_price_shock

sum hhi shannon_index n_crops tools_trap credit_constraint ///
knowhow_trap price_shock n_price_shocks severe_price_shock ///
[aw=hhweight]


********************************************************************************
* 2.1 AGRICULTURAL EQUIPMENT CONSTRAINTS
********************************************************************************

describe tools_trap total_tools_w

reg hhi tools_trap [pw=hhweight], vce(cluster cluster)

reg n_crops total_tools_w [pw=hhweight], vce(cluster cluster)

reg hhi tools_trap i.zae [pw=hhweight], vce(cluster cluster)

reg shannon tools_trap [pw=hhweight], vce(cluster cluster)

reg shannon tools_trap i.zae [pw=hhweight], vce(cluster cluster)



********************************************************************************
* 2.2 CREDIT MARKET IMPERFECTIONS
********************************************************************************

describe credit_constraint

reg hhi credit_constraint [pw=hhweight], vce(cluster cluster)

reg hhi credit_constraint i.zae [pw=hhweight], vce(cluster cluster)

reg shannon credit_constraint [pw=hhweight], vce(cluster cluster)

reg shannon credit_constraint i.zae [pw=hhweight], vce(cluster cluster)



********************************************************************************
* 2.3 HUMAN CAPITAL / KNOW-HOW
********************************************************************************

describe knowhow_trap

reg hhi knowhow_trap [pw=hhweight], vce(cluster cluster)

reg hhi knowhow_trap i.zae [pw=hhweight], vce(cluster cluster)

reg shannon knowhow_trap [pw=hhweight], vce(cluster cluster)

reg shannon knowhow_trap i.zae [pw=hhweight], vce(cluster cluster)



********************************************************************************
* DESCRIPTIVE COMPARISON
********************************************************************************

table tools_trap [pw=hhweight], statistic(mean hhi shannon)

table credit_constraint [pw=hhweight], statistic(mean hhi shannon)

table knowhow_trap [pw=hhweight], statistic(mean hhi shannon)



********************************************************************************
* 2.4 RISK EXPOSURE AND PRICE SHOCKS
********************************************************************************

describe price_shock n_price_shocks severe_price_shock

sum price_shock n_price_shocks severe_price_shock [aw=hhweight]


reg hhi price_shock [pw=hhweight], vce(cluster cluster)

reg hhi price_shock i.zae [pw=hhweight], vce(cluster cluster)

reg n_crops n_price_shocks [pw=hhweight], vce(cluster cluster)

reg n_crops n_price_shocks i.zae [pw=hhweight], vce(cluster cluster)

reg hhi severe_price_shock [pw=hhweight], vce(cluster cluster)

reg hhi severe_price_shock i.zae [pw=hhweight], vce(cluster cluster)


table price_shock [pw=hhweight], statistic(mean hhi shannon)

table severe_price_shock [pw=hhweight], statistic(mean hhi shannon)

/*
Previous analyses have empirically tested the relevance of the mechanisms put forward by MIT theory to explain agricultural diversification strategies. The results indicate that, in the 2018 EHCVM data, diversification is primarily structured by the agro-ecological context (AEC): observed levels of diversification vary considerably depending on the area in which the household is located. Conversely, the constraints typically highlighted in the literature—access to agricultural equipment, credit constraints, and exposure to price shocks—explain little of the observed variation in diversification indices, once the spatial context is taken into account.

This finding suggests that observed diversification cannot be interpreted solely as a productive choice adjustable at the household level, but rather that it largely reflects a given productive environment. In this context, directly analyzing the average relationship between diversification and multidimensional poverty risks aggregating structurally heterogeneous situations, in which diversification can fulfill different economic functions. The subsequent analysis introduces a key distinction between market-oriented and subsistence households, in order to examine whether the association between diversification and well-being differs according to the degree of market integration, and to identify the underlying economic mechanisms.

*/

********************************************************************************
* 3) HETEROGENEITY: DIVERSIFICATION × MARKET PARTICIPATION
********************************************************************************

eststo m2: reg mpi_score c.hhi##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)
margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_w_concentration.png", replace


reg mpi_score c.shannon##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)

margins market_participation, at(shannon=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_w_shannon.png", replace

reg mpi_score c.n_crops##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)
margins market_participation, at(n_crops=(2 6 8))
marginsplot
graph export "figures/mkp_w_n_crops.png", replace

/* Estimating a model incorporating an interaction between high-yield integration (HHI) and market participation reveals a marked heterogeneity in the relationship between productive structure and multidimensional poverty. While agricultural concentration is not significantly associated with the MPI score for non-selling households, the significant negative interaction between HHI and market participation indicates that, for selling households, a higher concentration of production is associated with a lower level of multidimensional poverty. The predictive margins confirm this divergence in trajectories, which intensifies as concentration increases.

At this stage of the analysis, the key finding is not the existence of an average effect of diversification on poverty, but rather the identification of structural heterogeneity depending on the degree of market integration. This pattern methodologically justifies the next step in the analysis, which consists of progressively reintroducing structural constraints (human capital, access to tools, credit, vulnerability) in order to examine whether they modulate, explain, or mitigate this differentiated relationship between diversification, market participation, and multidimensional poverty.

*/

********************************************************************************
* 3.1 ADDING STRUCTURAL CONSTRAINTS
********************************************************************************

eststo a1: reg mpi_score c.hhi##i.market_participation tools_trap i.zae [pw=hhweight], vce(cluster cluster)
margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_tools_trap.png", replace

eststo a2: reg mpi_score c.hhi##i.market_participation credit_constraint i.zae [pw=hhweight],vce(cluster cluster)
margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_cred_cons.png", replace


eststo a3: reg mpi_score c.hhi##i.market_participation knowhow_trap i.zae [pw=hhweight], vce(cluster cluster)
margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_knonhow.png", replace

eststo a4: reg mpi_score c.hhi##i.market_participation price_shock i.zae [pw=hhweight], vce(cluster cluster)
margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_prshock.png", replace


esttab a1 a2 a3 a4 using "$OUT/tables/appendix_constraints.rtf", replace se star(* 0.10 ** 0.05 *** 0.01) label compress b(3) se(3) keep(hhi 1.market_participation 1.market_participation#c.hhi tools_trap credit_constraint knowhow_trap price_shock) stats(N, labels("Observations")) mtitles("Tools" "Credit" "Know-how" "Price shock") title("Appendix: Structural Constraints") addnotes("Robust standard errors in parentheses")

********************************************************************************
* FULL MODEL
********************************************************************************

eststo m3: reg mpi_score c.hhi##i.market_participation tools_trap credit_constraint knowhow_trap price_shock i.zae [pw=hhweight], vce(cluster cluster)
margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_struc_constraint.png", replace


* Export main table
esttab m0 m1 m2 m3 using "$OUT/tables/main_results.rtf", ///
    replace ///
    se star(* 0.10 ** 0.05 *** 0.01) ///
    label ///
    compress ///
    nogaps ///
    b(3) se(3) ///
    drop(*.zae 0.market_participation 0.market_participation#c.hhi) ///
    stats(N r2, labels("Obs." "R2")) ///
    mtitles("Base" "ZAE" "Market" "Full") ///
    title("Main Results: Crop Structure, Market Participation and Price Shocks") ///
    addnotes("Robust standard errors in parentheses","ZAE fixed effects included")


********************************************************************************
* 4) PRICE SHOCKS AND AGRICULTURAL INCOME
********************************************************************************

describe ln_crop_income hhi n_price_shocks zae hhweight

eststo x1: reg ln_crop_income i.n_price_shocks i.zae [pw=hhweight], vce(cluster cluster)
eststo x2: reg ln_crop_income c.hhi##i.n_price_shocks i.zae [pw=hhweight], vce(cluster cluster)

lincom _b[c.hhi]

lincom _b[c.hhi] + _b[1.n_price_shocks#c.hhi]

lincom _b[c.hhi] + _b[2.n_price_shocks#c.hhi]


margins n_price_shocks, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/hhi_price_shocks_margins.png", replace


margins, dydx(hhi) at(n_price_shocks=(0 1 2))
marginsplot
graph export "figures/decrease_in_income.png", replace


test 1.n_price_shocks#c.hhi = 2.n_price_shocks#c.hhi

/*The interaction terms suggest that the marginal effect of crop concentration declines as the number of price shocks increases. A test of equality of the interaction coefficients indicates that the difference between one and two shocks is marginally significant (p = 0.093), suggesting that specialization becomes less beneficial under higher exposure to price shocks.*/


esttab x1 x2 using "$OUT/tables/price_shocks.rtf", replace se star(* 0.10 ** 0.05 *** 0.01) label ///
    title("Price Shocks and Agricultural Income") ///
    mtitles("Shock only" "Shock × Specialization") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    addnotes("Robust standard errors in parentheses") ///
    compress drop(*.zae *.zae 0.n_price_shocks 0.n_price_shocks#c.hhi)
    
	
********************************************************************************
* 5) ROBUSTNESS: MONETARY POVERTY
********************************************************************************

use "$ROOT/ehcvm_welfare_civ2018.dta", clear

gen monetary_poverty = (pcexp < zref)
label var monetary_poverty "Monetary poverty"

keep vague grappe menage monetary_poverty dali dnal dtot

rename vague wave
rename grappe cluster
rename menage household

rename dali hh_food_cons_annual
rename dnal hh_nonfood_cons_annual
rename dtot hh_total_cons_annual


sort wave cluster household

save "$OUT/pvm.dta", replace


use "$OUT/diversification_MPI_dataset_2018.dta", clear

sort wave cluster household

merge 1:1 wave cluster household using "$OUT/pvm.dta"

keep if _merge==3
drop _merge


********************************************************************************
* MONETARY POVERTY MODEL
********************************************************************************

eststo r0: logit monetary_poverty c.hhi##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)

margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/monetary_poverty_diversification.png", replace


********************************************************************************
* MONETARY WELFARE
********************************************************************************

gen ln_total_cons = ln(hh_total_cons_annual) if hh_total_cons_annual>0
label var ln_total_cons "Log total consumption"

eststo r1: reg ln_total_cons c.hhi##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)

margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/conso.png", replace


gen ln_food_cons = ln(hh_food_cons_annual) if hh_food_cons_annual>0
label var ln_food_cons "Log food consumption"
gen ln_nonfood_cons = ln(hh_nonfood_cons_annual) if hh_nonfood_cons_annual>0
label var ln_nonfood_cons "Log non-food consumption"

eststo r2: reg ln_food_cons c.hhi##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)
eststo r3: reg ln_nonfood_cons c.hhi##i.market_participation i.zae [pw=hhweight], vce(cluster cluster)

esttab r0 r1 r2 r3 using "$OUT/tables/robustness.rtf", replace se star(* 0.10 ** 0.05 *** 0.01) label title("Robustness: Monetary Poverty and Consumption") mtitles("Logit poverty" "Total cons" "Food cons" "Non-food cons") ///
    stats(N r2, labels("Observations" "R-squared")) ///
    addnotes("Robust standard errors in parentheses") ///
    compress drop(*.zae *.zae 0.market_participation 0.market_participation#c.hhi)


********************************************************************************
* END OF SCRIPT
********************************************************************************
