from snakemake.utils import min_version
min_version("8.0.0")
configfile: "config.yml"



rule all:
    """
    Collect the main outputs of the workflow.
    """
    input:
        expand("results/BEAST/{sample}/DivergenceTables/{sample}_ES_div_all.txt", sample=config["samples"]),
        expand("results/BEAST/{sample}/DivergenceTables/{sample}_EN_div_all.txt", sample=config["samples"]),
        expand("results/BEAST/{sample}/DivergenceTables/{sample}_ES_div_int.txt", sample=config["samples"]),
        expand("results/BEAST/{sample}/DivergenceTables/{sample}_EN_div_int.txt", sample=config["samples"]),
        expand("results/BEAST/{sample}/RateFiles/{sample}_ES_rates.txt", sample=config["samples"]),
        expand("results/BEAST/{sample}/RateFiles/{sample}_EN_rates.txt", sample=config["samples"])


rule combine_trees:
    """
    Take tree(s) and combined, generate combined tree"
    """

    output:
        "results/BEAST/{sample}/{sample}_AbsDiv_combinedTrees.trees"
    input:
        "results/BEAST/{sample}/{sample}_RC_ABS_run01.trees"
    params:
        burnin=config["burnin"]
    shell:
        """
        logcombiner -trees -burnin {params.burnin} {input} {output}
        """ 

rule extract_trees:
    """
    Extract a given number of trees, split into times, N and S
    """
    
    output: 
        "results/BEAST/{sample}/ExtractedTrees/EN_trees.txt",
        "results/BEAST/{sample}/ExtractedTrees/ES_trees.txt",
        "results/BEAST/{sample}/ExtractedTrees/Time_trees.txt" 
    input:
        "results/BEAST/{sample}/{sample}_AbsDiv_combinedTrees.trees"
    params:
        n=config["ntrees"]
    shell:
        """
        python code/TreeGenerator.py --input_trees {input} --n_trees {params.n}
	mv *_trees.txt results/BEAST/{wildcards.sample}/ExtractedTrees/
        """

rule analyse_rates:
    """
    Estimate rates and associated summary statistics for internal and external branches
    """

    output:
        S_file="results/BEAST/{sample}/RateFiles/{sample}_ES_rates.txt",
        N_file="results/BEAST/{sample}/RateFiles/{sample}_EN_rates.txt"
    input:
        N_file="results/BEAST/{sample}/ExtractedTrees/EN_trees.txt",
        S_file="results/BEAST/{sample}/ExtractedTrees/ES_trees.txt",
        T_file="results/BEAST/{sample}/ExtractedTrees/Time_trees.txt"
    shell:
        """
        java -jar code/RateAnalyzer.jar {input.T_file} {input.S_file} > {output.S_file}
        mv ./rates.txt results/BEAST/{wildcards.sample}/RateFiles/ES_rates.txt 
        java -jar code/RateAnalyzer.jar {input.T_file} {input.N_file} > {output.N_file}
        mv ./rates.txt results/BEAST/{wildcards.sample}/RateFiles/EN_rates.txt
        rm ./ratesAnnotated.trees
        """

rule extract_divergence:
    """
    Combine the time trees with subst trees to get divergence at given times
    """

    output:
        S_all="results/BEAST/{sample}/DivergenceTables/{sample}_ES_div_all.txt",
        N_all="results/BEAST/{sample}/DivergenceTables/{sample}_EN_div_all.txt", 
        S_int="results/BEAST/{sample}/DivergenceTables/{sample}_ES_div_int.txt", 
        N_int="results/BEAST/{sample}/DivergenceTables/{sample}_EN_div_int.txt" 
    input:
        N_file="results/BEAST/{sample}/ExtractedTrees/EN_trees.txt",
        S_file="results/BEAST/{sample}/ExtractedTrees/ES_trees.txt",
        T_file="results/BEAST/{sample}/ExtractedTrees/Time_trees.txt"
    shell:
        """
        java -jar code/BayesianDivergencePlotter.jar {input.T_file} {input.S_file} 0 all > {output.S_all}
        java -jar code/BayesianDivergencePlotter.jar {input.T_file} {input.N_file} 0 all > {output.N_all}
        java -jar code/BayesianDivergencePlotter.jar {input.T_file} {input.S_file} 0 int > {output.S_int}
        java -jar code/BayesianDivergencePlotter.jar {input.T_file} {input.N_file} 0 int > {output.N_int}
        """    




