

rule parse_annotate_results:
    input:  arriba_tsv = "results/arriba/{sample}.arriba.tsv",
            STARFusion_tsv = "results/STARFusion/{sample}.STARFusion.tsv",
            bam = "mapped/{sample}.bam",
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
    output: xlsx = "results/{sample}_fusions.xlsx",
    log:    "logs/{sample}/parse_annotate_results.log",
    conda:  "../wrappers/parse_annotate_results/env.yaml"
    script: "../wrappers/parse_annotate_results/script.py"

rule arriba:
    input:  bam = "mapped/{sample}.bam",
            chim= "mapped/{sample}/{sample}Chimeric.out.bam",
            ref = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])[0],
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
            bll = expand("{ref_dir}/other/arriba/blacklist.tsv.gz",ref_dir=reference_directory)[0],
    output: good= "results/arriba/{sample}.arriba.tsv",
            pdf = "/results/arriba/{sample}_arriba_fusion_viz.pdf",
            bad = "results/arriba/{sample}.arriba.discarded.tsv",
    log:    "logs/{sample}/arriba.log",
    threads:    1
    resources:  mem = 30
    conda:  "../wrappers/arriba/env.yaml"
    script: "../wrappers/arriba/script.py"

rule STARFusion:
    input: r1 = "cleaned_fastq/{sample}_R1.fastq.gz",
           r2 = "cleaned_fastq/{sample}_R2.fastq.gz",
           chim_junction = "mapped/{sample}/{sample}Chimeric.out.junction",
           ref_lib = expand("{ref_dir}/other/Trinity/{ref}_ctat_genome_lib_build_dir/ref_genome.fa",ref_dir=reference_directory,ref=config["reference"])[0],
    output: tsv = "results/STARFusion/{sample}.STARFusion.tsv",
    log:    "logs/{sample}/STARFusion.log",
    threads:    20
    resources:  mem = 10
    params: dir = "results/STARFusion/{sample}"
    conda:  "../wrappers/STARFusion/env.yaml"
    script: "../wrappers/STARFusion/script.py"


# rule jaffa:
#     input:  r1 = "cleaned_fastq/{sample}_R1.fastq.gz",
#             r2 = "cleaned_fastq/{sample}_R2.fastq.gz",
#             ref_lib = expand("{ref_dir}/other/jaffa/known_fusions.txt",dref_dir=reference_directory,ref=config["reference"])[0],
#     output: tsv = "results/jaffa/{sample}.jaffa.tsv",
#             fasta =  "results/jaffa/{sample}.jaffa.fasta",
#     log:    run = "logs/{sample}/jaffa.log",
#     threads:    20
#     resources:  mem = 30
#     conda:  "../wrappers/jaffa/env.yaml"
#     script: "../wrappers/jaffa/script.py"
