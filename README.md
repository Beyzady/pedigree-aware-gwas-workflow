# pedigree-aware-gwas-workflow

Reproducible pedigree-aware GWAS preprocessing and association analysis workflow using PLINK and ClassicMendel, demonstrated with simulated genomic data.

## Overview

This repository demonstrates a pedigree-aware GWAS preprocessing and analysis workflow inspired by large whole-genome sequencing studies investigating genetic risk factors for autism spectrum disorder. The project focuses on characterizing the genetic architecture and historical aspects of pathogenic repeat expansions in the human genome. Analyses are performed on whole-genome sequence data to map variants to a single locus, associate haplotypes with repeat expansions, and estimate variant frequencies within the population. These insights are relevant for identifying genetic factors contributing to the disorder.

To protect participant privacy and comply with data governance requirements, all examples in this repository use simulated data and generalized file paths while preserving the structure and methodology of real-world analyses.

## Key Features
- Pedigree-aware association testing using ClassicMendel
- Variant-level QC, filtering, and preprocessing using PLINK
- Support for family-based datasets and haplotype analyses
- Modular, reproducible workflow design suitable for large cohorts
- Demonstration with simulated data mimicking real-world genomic datasets

## Input Data
The workflow expects PLINK binary files (.bed, .bim, .fam) as input:
- .fam: Contains family ID, sample ID, father ID, mother ID, sex, and phenotype. Randomized identifiers and phenotypes are included in the example data.
- .bim: Contains reference genome variant information. Realistic chromosome, position, and allele data are used; these values do not need to be randomized.
- .bed: Genotype calls for each variant; example data are simulated to maintain privacy.

Example .fam and .bim formats are provided in the example_input/ folder for reference.

## Scientific Context
The workflow is designed for studies investigating inherited genetic variation, haplotype structure, and repeat expansion risk in complex traits, particularly neurodevelopmental disorders like autism spectrum disorder.

## Reproducibility
All scripts are portable and reproducible, with software versions and dependencies documented. The workflow covers preprocessing, QC, and association testing, providing a framework adaptable to real-world datasets while maintaining participant privacy.
