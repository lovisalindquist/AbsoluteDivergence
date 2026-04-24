

# Title: Estimator of absolute synonymous and nonsynonymous divergence rates from phylogenetic trees for applications in within-host virus evolution 

# Project Description: 
The overall aim of this project is to create .xml files for running BEAST to reconstruct phylogenies, combine the trees, extract a subset of the trees and extract the synonymous and nonsynonyomus divergence at given time stamps.

# Steps:
1. Generate .XML files
2. Run BEAST
3. Run post-run pipeline
    3.1. 
    
# Input files

# File tree

AbsoluteDivergence/
    README.md
    code/
        generate_xml.sh
        Make_XML_for_absolute_divergence.template
    data/
        Fasta/
        XMLs/
    documentation/
    env/
        environment.yml
    results/
        BEAST/

# Required software and packages:

Programs and versions needed to run the pipeline are included in envonrment.yml (for AbsDiv_env)

- BEASTgen xxx
- BEAST v1.10.4
    - logcombiner v1.10.4
- 

# Process:
1. Generate .XML files

    To generate the trees, one must generate .xml files that runs in BEAST. 
    - Input: fasta file with aligned sequences
    - Output: .xml file instructing BEAST how to build trees from the sequences
    **Assumptions: the fasta file is named [ID].fasta, and the headers in the fasta file contain sampling times in days since infection, in the fourth field separated by "_", e.g., >ID01_samp1_xx_1030_clone**
    
    Run scipt "code/generate.sh", which takes the input fasta file, and creates a custom .xml for the analysis.

    ``code/generate.sh``





