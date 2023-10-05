# Confounder-MR
This pipeline conducts Confounder-Mendelian randomisation on two applied examples, using UK Biobank data. 
The applied examples are the potential causal relationships between cycling to work and cardiovascular disease, as well as processed meat consumption and all-casue dementia.

## Directory Structure
### The project folder has the following structure:
```
MultiverseMR/code
MultiverseMR/code/a_extract_data/bash
MultiverseMR/code/a_extract_data/R
MultiverseMR/code/b_process_and regress
MultiverseMR/code/c_process_GWAS_results
MultiverseMR/code/d_process_genetic_data
MultiverseMR/code/e_MR
MultiverseMR/code/f_Confounder-MR
MultiverseMR/code/inputs
MultiverseMR/data
MultiverseMR/output
``` 

## Scripts
### a_extract_data
This section of the pipeline extracts all the necessary variables from the UK Biobank data and codes these variables as required. 
### b_process_and_regress
This section of the pipeline excludes individuals to create the correct datasets for the different analyses (i.e., samples and subsamples for regression, GWAS and MR). 
It then creates phenotype and meta files to be submitted to the MRC IEU UK Biobank GWAS pipeline.
Finally, it conducts the standard regressions of the outcomes on the exposures.
### c_process_GWAS_results
This section of the pipeline processes the files outputted by the GWAS pipeline.
### d_process_genetic_data
This section of the pipeline extracts the SNPs listed in the files in the inputs folder from the UK Biobank genetic data, codes the dosage of these SNPs, and formats the data. 
### e_MR
This section of the pipeline first creates the genetic risk scores from the relevant GWAS summary data (both produced in this pipeline and external data from the inputs folder).
It then conducts all Mendelian randomisations using the different datasets, genetic risk scores and GWAS summary statistics (one-sample and latent heritable cause-Mendelian randomisation using GWAS summary data).
### f_Confounder-MR
This section of the pipeline calculates the Confounder-MR estimates using the linear regression and MR estimates. 
It also calculates 95% confidence intervals for all MRs and converts all relevant estimates to odds ratios, and converts units of exposure from standard deviations to the original units where relevant. 
