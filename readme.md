# Core Threat Structured Interview (CTSI)

## Overview

This repository contains all materials, scripts, and supplementary documents related to the manuscript titled *The Core Threat Structured Interview (CTSI)*.
The CTSI is a tool designed to identify and analyze core threats underlying fear and anxiety.
This repository facilitates transparency, replication, and further exploration of the methodology and results presented in the manuscript.

## Contents

### 1. **Scripts**
- **Folder:** [`scripts/`](scripts/)
- Contains all analysis scripts used to process data, compute results, and generate visualizations for the manuscript. Scripts include:
  - Implementation of Krippendorff's alpha with custom agreement schemes ([scripts/krippendorff_alpha.R](scripts/krippendorf_alpha.R)).
  - Permutation tests for agreement analysis ([scripts/agreement.analysis.R](scripts/agreement.analysis.R)).
  - Diversity analysis using Simpson's Diversity Index ([scripts/simpsonD.R](scripts/simpsonD.R)).

### 2. **Supplementary Materials**
- **Folder:** [`supplementary/`](supplementary/)
- Includes:
  - Detailed coding instructions and criteria for threat categorization.
  - The taxonomy of values used for core and proximal threats (see [`threat_taxonomy.pdf`](supplementary/threat_taxonomy/threat_taxonomy.pdf)).
  - Full documentation of the Krippendorff's alpha algorithm with custom adaptations for multi-category data (see [`krippendorff_alpha.pdf`](supplementary/krippendorff/krippendorff_alpha.pdf)).
  - The Core Threat Structured Interview (CTSI) guide (see [`CTSI_Guide.pdf`](https://eladzlot.github.io/publications/core-fear-manual.pdf)).

### 3. **Data**
- **Folder:** [`data/`](data/)
- Contains processed datasets used in the analyses presented in the manuscript.
- **Note:** Raw data is not available to ensure participant confidentiality. Only de-identified and aggregated data are included.

### 4. **Manuscript**
- **Folder:** [`docs/`](docs/)
* Contains Rmd files used to produce the manuscript including all calculations
- The full manuscript of the study is included for reference.
  - **File:** [`ctsi.pdf`](docs/output/ctsi.pdf)
  - **File:** [`ctsi.docx`](docs/output/ctsi.docx)

## Instructions for Use

1. **Clone the Repository**  
Clone this repository to your local machine:
```bash
git clone https://github.com/eladzlot/ctsi-2025-public.git
```

2. **Install Dependencies**  
Ensure all required R packages are installed. The scripts depend on the following packages:
   - `tidyverse`
   - `here`
   - `psych`
   - `papaja`

  You can install these packages in R using:
```R
install.packages(c("tidyverse", "here", "psych", "papaja"))
```

3. **Knit the Document**  
   Knit the file `docs/ctsi.Rmd` in RStudio or using another method of your choice to generate the output document.

## Important Notes
- **Raw Data:** Raw data cannot be provided due to privacy concerns. Only redacted and processed data are included.
- **Licensing:** The contents of this repository are provided under an academic license. Please contact the corresponding author for permissions or collaborations.

## Contact
For questions or issues, please contact:
- **Elad Zlotnick** (elad.zlotnick@mail.huji.ac.il)
