# Estimator of absolute synonymous and nonsynonymous divergence rates from phylogenetic trees for applications in within-host virus evolution 

# Project Description: 
The overall aim of this project is to create .xml files for running BEAST to reconstruct phylogenies, combine the trees, extract a subset of the trees and extract the synonymous and nonsynonyomus divergence at given time stamps.

# Steps:
1. Generate .XML files
2. Run BEAST
3. Run post-run pipeline
4. Plot results
    
# Input files
aligned .fasta file

# File tree
AbsoluteDivergence/
    README.md
    Snakefile
    config.yml
    bin/
    code/
        BayesianDivergencePlotter.jar
        generate_xml.sh
        Make_XML_for_absolute_divergence.template
        RateAnalyzer.jar
        run_beast.sh
        TreeGenerator.py
    data/
        Fasta/
        XMLs/
    documentation/
    env/
        environment.yml
    results/
        BEAST/

# Required software and packages:
Programs and versions needed to run the pipeline are included in environment.yml (for AbsDiv_env)

- BEASTGen v0.3 (not available in environment, available at the BEAST GitHub page)
- BEAST v1.10.4
    - logcombiner v1.10.4
- Snakemake v9.19.0
- r-base v

# Process:
1. Generate .XML files

    To generate the trees, one must generate .xml files that runs in BEAST. 
    - Input: fasta files with aligned sequences (should be codon-aligned nucleotides)

    /data/Fasta/[file].fasta

    - Output: .xml file instructing BEAST how to build trees from the sequences
    
    /data/XMLs/[file].AbsRate.xml

    - **Assumptions: the fasta file is named [ID].fasta, and the headers in the fasta file contain sampling times in days since infection, in the fourth field separated by "_", e.g., >ID01_samp1_xx_1030_clone**
    
    Run scipt "code/generate.sh" **from the root directory**, which takes each input fasta file, and creates a custom .xml for the analysis.

    `code/generate.sh`

2. Run BEAST

    - Input: .xml file instructing BEAST how to build trees from the sequences

    /data/XMLs/[file].AbsRate.xml

    - Output: .log, .trees, and .dNdS.log files from BEAST run

    /results/BEAST/[file].log, /results/BEAST/[file].trees, /results/BEAST/[file].dNdS.log

    Run scipt "code/run_beast.sh" **from the root directory**, which takes the input XML files and runs BEAST.
    
    `code/run_beast.sh`

3. Run the post-run Snakemake pipeline

    The steps in the pipeline include:
        - Combine_trees: Reformat trees to format compatible with downstream analyses (treeanotator, default burnin=1000000, can be adjusted in config.yml)
        - Extract_trees: extract 200 (can be adjusted in config.yml) trees from the posterior distribution, from the trees, produce three new trees with times, N and S annotated. 
        - Analyse_rates: get summary of rates
        - Extract_divergence: get divergence estimates at given time points.

    - Input: 
    
    /results/BEAST/[file].trees

    - Output:

    /results/BEAST/[ID]/[file]_combinedTrees.trees
    /results/BEAST/[ID]/DivergenceTables/[ID]_E[N|S]_div_[all|int].txt
    /results/BEAST/[ID]/ExtractedTrees/[ES|EN|Time]_trees.txt
    /results/BEAST/[ID]/RateFiles/[ID]_E[N|S]_rates.txt

    First, make sure the pipeline is ready to be run, then run the same command without the **-n** flag to execute the pipeline.

    `snakemake -c 1 -p -n`

4. Plot results

    If desired, example output is displayed in "documentation/PlotAbsoluteDivergence.qmd". Adjust the path to the root directory before rendering.
    
    Open and render file in RStudio or other IDE of preference:
    `documentation/PlotAbsoluteDivergence.qmd`

    or run in command-line:
    `quarto render documentation/PlotAbsoluteDivergence.qmd`
