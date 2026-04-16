Transparency & Trust in AI Governance
> **Data Analysis STAT 4620/5620 — Winter 24-25 | Final Project**
---
📌 Project Overview
This project empirically examines whether transparency-related themes co-occur with trust-related themes in AI governance literature across multiple application domains — technology, health, education, hiring, and law.
Transparency is widely assumed to be a pathway to trust in AI systems, but this assumption is rarely tested empirically. Rather than relying on conceptual argument alone, this study applies keyword-based text analysis, chi-square testing, and penalized logistic regression to a curated bibliographic dataset to generate statistical evidence for or against this assumption.
---
🔬 Research Question
> *To what extent do transparency-related themes co-occur with trust-related themes in AI governance literature across domains such as technology, health, education, and hiring?*
---
👥 Team Members
Name	Role
Nancy Eke-Agu	Collaborator
Chinedu Obiefuna	Collaborator
	
---
📂 Repository Structure
```
├── data/
│   ├── Datasets.xlsx                          # Final integrated dataset used for analysis
│   └── initial_dataset/                       # Raw source datasets (pre-cleaning)
├── code/
│   ├── Descriptive_Transparency.R             # Descriptive statistics and visualizations
│   ├── Inferential_Transparency.R             # Chi-square test and contingency analysis
│   └── Modeling_Transparency.R                # Penalized logistic regression (Firth method)
├── outputs/
│   ├── plots/                                 # All generated figures (PNG, 300 DPI)
│   ├── penalized_logistic_results.csv         # Regression results table
│   └── penalized_predicted_probabilities.csv  # Predicted probabilities by domain
├── report/
│   └── Transparency_Trust_AI_Governance_Report.docx   # Full written report
└── README.md
```
---
📊 Data Sources
Five bibliographic datasets were compiled from three academic databases to ensure interdisciplinary coverage across both technical AI research and governance-focused literature.
Dataset	Source	Records
Dataset 1	IEEE Xplore	29,779
Dataset 2	ACM Digital Library	27,947
Dataset 3	Scopus	30,001
Dataset 4	Scopus	30,298
Dataset 5	Supplementary	4,693
Total		122,718
Each record contains up to 20 metadata and text variables, including title, abstract, DOI, publication year, application domain, and country/region.
---
🧹 Data Cleaning Pipeline
Duplicate Removal — Records with identical title, DOI, or abstract were identified and removed
Screening & Filtering — Articles filtered for relevance using AI governance keyword filters
Missing Data Audit — Fields with significant missingness (ISSN, PMC ID, pages) were documented and flagged
Integration — All five datasets were standardized and merged into a single analytical dataset
---
🔑 Key Variables
Variable	Type	Description
`title`	Text	Used for keyword detection and pattern matching
`abstract`	Text	Primary field for thematic coding and keyword frequency
`domain_filter`	Categorical	Application domain (technology, health, education, hiring, law)
`year`	Numeric	Publication year for temporal trend analysis (2021–2025)
`transparency_indicator`	Binary (0/1)	1 if transparency-related keywords detected in abstract
`trust_indicator`	Binary (0/1)	1 if trust-related keywords detected in abstract
Keyword Dictionaries
Transparency keywords:
`explain`, `interpret`, `transparent`, `accountab`, `ethic`, `govern`, `oversight`, `audit`, `compliance`, `disclosure`, `responsib`, `traceab`, `justif`, `document`, `report`, `regulat`, `policy`, `standard`, `guideline`, `framework`, `monitor`, `review`, `assess`
Trust keywords:
`fair`, `bias`, `equity`, `reliab`, `robust`, `depend`, `trust`, `confidence`, `credible`, `safe`, `secure`, `privacy`, `risk`, `uncertain`, `certainty`, `consistent`, `valid`, `accuracy`, `assurance`, `accept`, `satisf`
---
⚙️ Methods
The analysis followed a four-stage workflow:

Stage 1: Data Preparation
         → Binary indicators constructed via keyword string matching in R

Stage 2: Descriptive Statistics
         → Theme frequencies, cross-tabulations by domain and year
         → Visualizations: bar charts, stacked plots, heatmaps

Stage 3: Inferential Testing
         → Chi-square test of independence (transparency × trust)
         → Fisher's Exact Test (supplementary, given small n)
         → Effect size: Cramer's V

Stage 4: Predictive Modeling
         → Penalized logistic regression (Firth method)
         → Outcome: trust_indicator
         → Predictors: transparency_indicator + domain_filter
         → Reference category: Technology

Why Penalized Logistic Regression?
Standard logistic regression is susceptible to bias with small samples (n = 37). The Firth method adds a penalty term to the likelihood function that reduces this bias, making it the most appropriate choice for this dataset.
---
📈 Key Results
Descriptive Findings
Top themes overall: framework (n=16), ethic (n=15), fair (n=13), risk (n=11)
Technology domain: privacy (19.2%) and assess (17.3%) dominated
Hiring domain: framework (36.4%) was most prominent — reflecting structural equity concerns
Health domain: ethic (27.3%) led — consistent with bioethical traditions in medical AI research
Temporal trend: Publications grew from 1 paper in 2021 to 19 papers in 2025, with thematic focus shifting from individual ethics concerns toward systemic governance frameworks
Contingency Table
	Trust: No	Trust: Yes	Total
Transparency: No	6	7	13
Transparency: Yes	4	20	24
Total	10	27	37
> When transparency was **present**, trust was present in **83.3%** of articles.
> When transparency was **absent**, trust was present in only **53.8%** of articles.
Chi-Square Test
Statistic	Value
χ²(1)	2.373
p-value	0.123
Cramer's V	0.253
> The association did not reach statistical significance (p > .05), but the **effect size indicates a small-to-moderate relationship**. The non-significance is likely attributable to limited sample size rather than the absence of a true association.
Predicted Probabilities (Penalized Regression)
Domain	P(Trust | No Transparency)	P(Trust | Transparency Present)	Change
Technology	0.77	0.82	+0.05
Education	0.71	0.76	+0.05
Law	0.51	0.58	+0.07
Health	0.43	0.51	+0.08
Hiring	0.39	0.47	+0.08
> **The probability of trust was consistently higher when transparency was present across ALL five domains** — a uniform directional pattern that reinforces the descriptive and inferential findings.
---
🧠 Conclusions
To answer the research question: transparency and trust themes co-occur to a small but consistent extent across all five domains examined. The consistent directional pattern across descriptive, inferential, and modeling analyses provides preliminary empirical support for the widely held assumption that transparency contributes to trust in AI governance contexts.
The lack of statistical significance is best interpreted as a power limitation (n = 37) rather than evidence against the relationship. A sample of approximately 120–150 observations would be needed to detect an effect of this size at 80% power.
Contributions
Type	Contribution
🔬 Methodological	Demonstrates replicable text-derived binary indicators and cross-domain inference for AI governance themes
📚 Theoretical	Advances empirical grounding of the transparency-trust relationship beyond conceptual argument
🏛️ Practical	Informs governance and policy priorities where transparency may influence perceived trustworthiness
---
⚠️ Limitations
Analysis relies on abstract-level keyword detection — theme depth and context are not captured
Binary coding identifies keyword presence but not semantic nuance or argumentative framing
Identifies statistical association, not causal relationships
Domain classification depends on metadata labeling consistency across databases
Small final sample (n = 37) limits statistical power and generalizability
---
🔭 Future Work
[ ] Extend analysis using full-text corpus processing
[ ] Apply topic modeling (LDA) or embedding-based semantic analysis
[ ] Explore longitudinal trends in transparency–trust relationships over time
[ ] Incorporate additional governance indicators: accountability, safety, robustness
[ ] Collect larger datasets to achieve adequate statistical power
---
🛠️ How to Reproduce
Requirements
```r
install.packages(c(
  "readxl", "dplyr", "tidyr", "stringr", "janitor",
  "writexl", "ggplot2", "forcats", "scales", "tibble",
  "logistf", "viridis"
))
```
Run the Analysis
```r
# Step 1: Descriptive analysis and visualizations
source("code/Descriptive_Transparency.R")

# Step 2: Inferential testing (chi-square + effect size)
source("code/Inferential_Transparency.R")

# Step 3: Penalized logistic regression + predicted probabilities
source("code/Modeling_Transparency.R")
```
> **Note:** Update the file path in each script to point to your local copy of `Datasets.xlsx` before running.
---
📚 References
Firth, D. (1993). Bias reduction of maximum likelihood estimates. Biometrika, 80(1), 27–38.
Jobin, A., Ienca, M., & Vayena, E. (2019). The global landscape of AI ethics guidelines. Nature Machine Intelligence, 1(9), 389–399.
Mittelstadt, B. D., et al. (2016). The ethics of algorithms: Mapping the debate. Big Data & Society, 3(2), 1–21.
R Core Team. (2024). R: A language and environment for statistical computing. R Foundation for Statistical Computing.
Wickham, H. (2016). ggplot2: Elegant graphics for data analysis. Springer-Verlag.
Wachter, S., Mittelstadt, B., & Russell, C. (2017). Counterfactual explanations without opening the black box. Harvard Journal of Law & Technology, 31(2), 841–887.
---
📄 License
This project was developed for academic purposes as part of Data Analysis STAT 4620/5620, Winter 24-25 , Masters in Duigital Innovation at Dalhousie University.

For questions or collaboration inquiries, please open an issue or contact the project team via the repository.
