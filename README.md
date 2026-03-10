# crop-diversification-poverty

Empirical analysis of the relationship between crop diversification and multidimensional poverty using household survey data (EHCVM).

## Research Question

Does crop diversification reduce multidimensional poverty among agricultural households in Côte d’Ivoire?

## Data

This project uses household survey data from the EHCVM (2018) and 2021 (in progress).


## Stylized Facts

This project documents a set of stylized facts on the relationship between crop diversification, market participation, and multidimensional poverty among agricultural households in Côte d’Ivoire, using EHCVM 2018 and 2021 household survey data.

**1. Limited diversification remains the dominant pattern.**  
Most agricultural households cultivate only a small number of crops. In 2018, 53% of households produced one or two crops, and this share increased to 57% in 2021, suggesting a slightly more concentrated productive structure in the later wave.

**2. Crop portfolios are organized around a stable core of dominant crops.**  
Across both years, agricultural systems remain centered on a relatively stable set of crops, including cocoa, yam, cashew, paddy rice, maize, and cassava. Diversification therefore appears to reflect an expansion around a common productive core rather than a complete shift in production systems. 

**3. Specialization is more closely associated with market participation than high diversification.**  
Descriptive evidence shows that more specialized households are more likely to sell agricultural output, especially in 2018. This suggests that specialization is often linked to stronger market orientation, whereas high diversification may reflect more mixed production logics. 

**4. The relationship between diversification and crop income is not stable across time.**  
In 2018, highly diversified households recorded lower average crop income than more specialized households. In 2021, however, income differences across diversification profiles became much smaller, suggesting that the economic meaning of diversification depends on the broader context. 

**5. Market participation does not automatically imply better multidimensional well-being.**  
At a given level of diversification, differences in multidimensional poverty between sellers and non-sellers are often small. This indicates that selling agricultural output is not, by itself, a reliable indicator of better living conditions.
**6. More diversified households tend to exhibit lower multidimensional poverty.**  
In both 2018 and 2021, households with more diversified crop portfolios generally display lower levels of multidimensional poverty than households cultivating only one or two crops. This pattern is descriptive and should not be interpreted as causal, but it is robust across both survey waves. 

**7. Income and multidimensional poverty do not rank households in the same way.**  
Households with relatively higher crop income are not necessarily those with the lowest multidimensional poverty. This confirms that monetary performance alone does not fully capture household well-being, especially in rural settings where non-monetary deprivations remain important. 

**8. Preliminary results suggest that specialization is more vulnerable to price shocks.**  
Early regression results indicate that crop concentration may be associated with higher crop income in the absence of price shocks, but that this advantage weakens as exposure to price shocks increases. This is consistent with the idea that diversification may play a partial risk-management role. These results should be treated as preliminary and interpreted with caution.

## Methodology

Crop diversification is measured using:
- number of crops cultivated
- Shannon diversity index
- Herfindahl-Hirschman index (HHI)

Multidimensional poverty is measured using an Alkire-Foster MPI framework.

## Repository Structure

code/  
data/  
doc/  
figures/  
output/

## Replication

To reproduce the analysis:

1. Download the EHCVM datasets.
2. Run the master script:

code/00_master.do

3. The script generates:

- Diversification indicators
- MPI dataset
- Figures
- Regression tables
