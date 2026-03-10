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


********************************************************************************
* 1) BASELINE ASSOCIATION BETWEEN DIVERSIFICATION AND MPI
********************************************************************************

describe mpi_score hhi shannon n_crops zae hhweight

sum mpi_score hhi shannon n_crops [aw=hhweight]

reg mpi_score hhi [pw=hhweight], vce(robust)

reg mpi_score hhi i.zae [pw=hhweight], vce(robust)

reg mpi_score shannon i.zae [pw=hhweight], vce(robust)

reg mpi_score n_crops [pw=hhweight], vce(robust)



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

reg hhi tools_trap [pw=hhweight], vce(robust)

reg n_crops total_tools_w [pw=hhweight], vce(robust)

reg hhi tools_trap i.zae [pw=hhweight], vce(robust)

reg shannon tools_trap [pw=hhweight], vce(robust)

reg shannon tools_trap i.zae [pw=hhweight], vce(robust)



********************************************************************************
* 2.2 CREDIT MARKET IMPERFECTIONS
********************************************************************************

describe credit_constraint

reg hhi credit_constraint [pw=hhweight], vce(robust)

reg hhi credit_constraint i.zae [pw=hhweight], vce(robust)

reg shannon credit_constraint [pw=hhweight], vce(robust)

reg shannon credit_constraint i.zae [pw=hhweight], vce(robust)



********************************************************************************
* 2.3 HUMAN CAPITAL / KNOW-HOW
********************************************************************************

describe knowhow_trap

reg hhi knowhow_trap [pw=hhweight], vce(robust)

reg hhi knowhow_trap i.zae [pw=hhweight], vce(robust)

reg shannon knowhow_trap [pw=hhweight], vce(robust)

reg shannon knowhow_trap i.zae [pw=hhweight], vce(robust)



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


reg hhi price_shock [pw=hhweight], vce(robust)

reg hhi price_shock i.zae [pw=hhweight], vce(robust)

reg n_crops n_price_shocks [pw=hhweight], vce(robust)

reg n_crops n_price_shocks i.zae [pw=hhweight], vce(robust)

reg hhi severe_price_shock [pw=hhweight], vce(robust)

reg hhi severe_price_shock i.zae [pw=hhweight], vce(robust)


table price_shock [pw=hhweight], statistic(mean hhi shannon)

table severe_price_shock [pw=hhweight], statistic(mean hhi shannon)

/*
Previous analyses have empirically tested the relevance of the mechanisms put forward by MIT theory to explain agricultural diversification strategies. The results indicate that, in the 2018 EHCVM data, diversification is primarily structured by the agro-ecological context (AEC): observed levels of diversification vary considerably depending on the area in which the household is located. Conversely, the constraints typically highlighted in the literature—access to agricultural equipment, credit constraints, and exposure to price shocks—explain little of the observed variation in diversification indices, once the spatial context is taken into account.

This finding suggests that observed diversification cannot be interpreted solely as a productive choice adjustable at the household level, but rather that it largely reflects a given productive environment. In this context, directly analyzing the average relationship between diversification and multidimensional poverty risks aggregating structurally heterogeneous situations, in which diversification can fulfill different economic functions. The subsequent analysis introduces a key distinction between market-oriented and subsistence households, in order to examine whether the association between diversification and well-being differs according to the degree of market integration, and to identify the underlying economic mechanisms.

*/

********************************************************************************
* 3) HETEROGENEITY: DIVERSIFICATION × MARKET PARTICIPATION
********************************************************************************

reg mpi_score c.hhi##i.market_participation i.zae ///
[pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/mkp_w_concentration.png", replace


reg mpi_score c.shannon##i.market_participation i.zae ///
[pw=hhweight], vce(robust)

margins market_participation, at(shannon=(0.2 0.5 0.8))

marginsplot
graph export "figures/mkp_w_shannon.png", replace

/* Estimating a model incorporating an interaction between high-yield integration (HHI) and market participation reveals a marked heterogeneity in the relationship between productive structure and multidimensional poverty. While agricultural concentration is not significantly associated with the MPI score for non-selling households, the significant negative interaction between HHI and market participation indicates that, for selling households, a higher concentration of production is associated with a lower level of multidimensional poverty. The predictive margins confirm this divergence in trajectories, which intensifies as concentration increases.

At this stage of the analysis, the key finding is not the existence of an average effect of diversification on poverty, but rather the identification of structural heterogeneity depending on the degree of market integration. This pattern methodologically justifies the next step in the analysis, which consists of progressively reintroducing structural constraints (human capital, access to tools, credit, vulnerability) in order to examine whether they modulate, explain, or mitigate this differentiated relationship between diversification, market participation, and multidimensional poverty.

*/

********************************************************************************
* 3.1 ADDING STRUCTURAL CONSTRAINTS
********************************************************************************

reg mpi_score c.hhi##i.market_participation tools_trap i.zae ///
[pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_tools_trap.png", replace


reg mpi_score c.hhi##i.market_participation credit_constraint ///
i.zae [pw=hhweight], vce(robust)
margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/mkp_add_cred_cons.png", replace


reg mpi_score c.hhi##i.market_participation knowhow_trap ///
i.zae [pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_knonhow.png", replace

reg mpi_score c.hhi##i.market_participation price_shock ///
i.zae [pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))
marginsplot
graph export "figures/mkp_add_prshock.png", replace

********************************************************************************
* FULL MODEL
********************************************************************************

reg mpi_score c.hhi##i.market_participation ///
tools_trap credit_constraint knowhow_trap price_shock ///
i.zae [pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/mkp_add_struc_constraint.png", replace





********************************************************************************
* 4) PRICE SHOCKS AND AGRICULTURAL INCOME
********************************************************************************

describe ln_crop_income hhi n_price_shocks zae hhweight

reg ln_crop_income i.n_price_shocks i.zae ///
[pw=hhweight], vce(robust)


reg ln_crop_income c.hhi##i.n_price_shocks i.zae ///
[pw=hhweight], vce(robust)

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

********************************************************************************
* 5) ROBUSTNESS: MONETARY POVERTY
********************************************************************************

use "$ROOT/ehcvm_welfare_civ2018.dta", clear

gen monetary_poverty = (pcexp < zref)

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

logit monetary_poverty c.hhi##i.market_participation ///
i.zae [pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/monetary_poverty_diversification.png", replace


********************************************************************************
* MONETARY WELFARE
********************************************************************************

gen ln_total_cons = ln(hh_total_cons_annual) if hh_total_cons_annual>0

reg ln_total_cons c.hhi##i.market_participation ///
i.zae [pw=hhweight], vce(robust)

margins market_participation, at(hhi=(0.2 0.5 0.8))

marginsplot
graph export "figures/conso.png", replace


gen ln_food_cons = ln(hh_food_cons_annual) if hh_food_cons_annual>0

gen ln_nonfood_cons = ln(hh_nonfood_cons_annual) if hh_nonfood_cons_annual>0


reg ln_food_cons c.hhi##i.market_participation ///
i.zae [pw=hhweight], vce(robust)

reg ln_nonfood_cons c.hhi##i.market_participation ///
i.zae [pw=hhweight], vce(robust)





********************************************************************************
* END OF SCRIPT
********************************************************************************
