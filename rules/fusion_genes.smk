

rule parse_annotate_results:
    input:  arriba_tsv = "fusion_genes_detection/{sample}/arriba/{sample}.arriba_fusion.tsv",
            STARFusion_tsv = "fusion_genes_detection/{sample}/STARFusion/{sample}.STARFusion.tsv",
            bam = "mapped/{sample}.bam",
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
    output: xlsx = "fusion_genes_detection/{sample}_fusions.xlsx",
    log:    "logs/{sample}/parse_annotate_results.log",
    params: txt = workflow.basedir+"/wrappers/parse_annotate_results/Fusionhub_global_summary.txt",
    conda:  "../wrappers/parse_annotate_results/env.yaml"
    script: "../wrappers/parse_annotate_results/script.py"

rule arriba:
    input:  bam = "mapped/{sample}.bam",
            chim= "mapped/{sample}/{sample}Chimeric.out.bam",
            ref = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])[0],
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
            bll = expand("{ref_dir}/other/arriba/blacklist.tsv.gz",ref_dir=reference_directory)[0],
    output: good= "fusion_genes_detection/{sample}/arriba/{sample}.arriba_fusion.tsv",
            pdf = "fusion_genes_detection/{sample}/arriba/{sample}.arriba_fusion_viz.pdf",
            bad = "fusion_genes_detection/{sample}/arriba/{sample}.arriba_discarded.tsv",
            bam = "fusion_genes_detection/{sample}/mapped/{sample}.bam",
            chim = "fusion_genes_detection/{sample}/mapped/{sample}Chimeric.out.bam",
    log:    "logs/{sample}/arriba.log",
    threads: 1
    resources:  mem = 30
    conda:  "../wrappers/arriba/env.yaml"
    script: "../wrappers/arriba/script.py"

rule STARFusion:
    input:  r1 = "cleaned_fastq/{sample}_R1.fastq.gz",
            r2= "cleaned_fastq/{sample}_R2.fastq.gz",
            ref_lib = expand("{ref_dir}/other/STARfusion/GRCh38_gencode_v33_CTAT_lib_Apr062020", ref_dir=reference_directory)[0]
    output: tsv = "fusion_genes_detection/{sample}/STARFusion/{sample}.STARFusion.tsv",
    log:    "logs/{sample}/STARFusion.log",
    threads: 20
    resources:  mem = 10
    params: dir = "fusion_genes_detection/{sample}/STARFusion/data",
            is_paired = config["is_paired"]
    conda:  "../wrappers/STARFusion/env.yaml"
    script: "../wrappers/STARFusion/script.py"
