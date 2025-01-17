

rule parse_annotate_results:
    input:  arriba_tsv = "results/{sample}/arriba/{sample}.arriba_fusion.tsv",
            STARFusion_tsv = "results/{sample}/STARFusion/{sample}.STARFusion.tsv",
            bam = "mapped/{sample}.bam",
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
    output: xlsx = "results/{sample}_fusions.xlsx",
    log:    "logs/{sample}/parse_annotate_results.log",
    params: txt = workflow.basedir+"/wrappers/parse_annotate_results/Fusionhub_global_summary.txt",
    conda:  "../wrappers/parse_annotate_results/env.yaml"
    script: "../wrappers/parse_annotate_results/script.py"

rule arriba:
    input:  bam = "mapped/{sample}.bam",
            chim= "mapped/{sample}/{sample}Chimeric.out.bam",
            ref = expand("{ref_dir}/seq/{ref}.fa",ref_dir=reference_directory,ref=config["reference"])[0],
            gtf = expand("{ref_dir}/annot/{ref}.gtf",ref_dir=reference_directory,ref=config["reference"])[0],
            bll = expand("{ref_dir}/other/arriba/blacklist_hg38_GRCh38_v2.4.0.tsv.gz",ref_dir=reference_directory)[0],
    output: good= "results/{sample}/arriba/{sample}.arriba_fusion.tsv",
            pdf = "results/{sample}/arriba/{sample}.arriba_fusion_viz.pdf",
            bad = "results/{sample}/arriba/{sample}.arriba_discarded.tsv",
    log:    "logs/{sample}/arriba.log",
    threads: 1
    resources:  mem = 30
    conda:  "../wrappers/arriba/env.yaml"
    script: "../wrappers/arriba/script.py"

def STARFusion_input(wildcards):
    input = {
        'chim_junction': "mapped/{sample}/{sample}Chimeric.out.junction",
        'ref_lib': expand("{ref_dir}/other/STARfusion/GRCh38_gencode_v37_CTAT_lib_Mar012021",ref_dir=reference_directory)[0]
    }
    if not config["is_paired"]:
        input['r1'] = "cleaned_fastq/{sample}.fastq.gz"
    else:
        input['r1'] = "cleaned_fastq/{sample}_R1.fastq.gz"
        input['r2'] = "cleaned_fastq/{sample}_R2.fastq.gz"
    return input


rule STARFusion:
    input:  unpack(STARFusion_input)
    output: tsv = "results/{sample}/STARFusion/{sample}.STARFusion.tsv",
    log:    "logs/{sample}/STARFusion.log",
    threads: 20
    resources:  mem = 10
    params: tmpd = GLOBAL_TMPD_PATH,
            is_paired = config["is_paired"],
    conda:  "../wrappers/STARFusion/env.yaml"
    script: "../wrappers/STARFusion/script.py"
