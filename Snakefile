from snakemake.utils import min_version
min_version("8.0.0")
configfile: "config.yml"



rule all:
    """
    Collect the main outputs of the workflow.
    """
    input:
        expand("results/BEAST/{sample}/DivergenceTables/{sample}_{type}_div_{branch}.txt", sample=config["samples"], type=config["types"], branch=["all", "int"]),
        
        expand("results/BEAST/{sample}/RateFiles/{sample}_{type}_rates.txt", sample=config["samples"], type=config["types"])


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
        N_file="results/BEAST/{sample}/ExtractedTrees/EN_trees.txt",
        S_file="results/BEAST/{sample}/ExtractedTrees/ES_trees.txt",
        T_file="results/BEAST/{sample}/ExtractedTrees/Time_trees.txt"

    input:
        "results/BEAST/{sample}/{sample}_AbsDiv_combinedTrees.trees"

    params:
        n=config["ntrees"]
    shell:
        """
        python code/TreeGenerator.py --input_trees {input} --n_trees {params.n}
        mv EN_trees.txt {output.N_file}
        mv ES_trees.txt {output.S_file}
        mv Time_trees.txt {output.T_file}
        """

rule analyse_rates:
    """
    Estimate rates and associated summary statistics for internal and external branches
    """

    output:
        "results/BEAST/{sample}/RateFiles/{sample}_{type}_rates.txt",
        
    input:
        S_file="results/BEAST/{sample}/ExtractedTrees/{type}_trees.txt",
        T_file="results/BEAST/{sample}/ExtractedTrees/Time_trees.txt"
    shell:
        """
        java -jar code/RateAnalyzer.jar {input.T_file} {input.S_file} > {output}
        
        rm ./ratesAnnotated.trees
        rm ./rates.txt
        """

rule extract_divergence:
    """
    Combine the time trees with subst. trees to get divergence at given times
    """

    output:
        "results/BEAST/{sample}/DivergenceTables/{sample}_{type}_div_all.txt", 
        int_file="results/BEAST/{sample}/DivergenceTables/{sample}_{type}_div_int.txt"
    input:
        S_file="results/BEAST/{sample}/ExtractedTrees/{type}_trees.txt",
        T_file="results/BEAST/{sample}/ExtractedTrees/Time_trees.txt"
    shell:
        """
        java -jar code/BayesianDivergencePlotter.jar {input.T_file} {input.S_file} 0 all > {output.all_file}
        java -jar code/BayesianDivergencePlotter.jar {input.T_file} {input.S_file} 0 int > {output.int_file}

        """    




