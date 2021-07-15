import math
import subprocess
import json
import re
import os.path
import glob
import fnmatch
import pandas as pd
from snakemake.utils import R
from snakemake.utils import report
from os.path import split
from helper import define_variable


###########################################
# DEFINITION OF VARIABLES
#
#

cfg = pd.DataFrame(config)

REF_DIR = define_variable(cfg, "REF_DIR")
if "project" in cfg:
    PROJECT_NAME = define_variable(cfg, "PROJECT_NAME")
    PROJECT_DIR = define_variable(cfg, "PROJECT_DIR")
    INPUTS_DIR = define_variable(cfg, "INPUTS_DIR")
    DIR = define_variable(cfg, "ANALYSIS_DIR")
    SAMPLE = define_variable(cfg, "FULL_NAME")

# REF_DIR = "/mnt/ssd/ssd_3/references"
# if "project" in cfg:
#     PROJECT_NAME = cfg['project'].tolist()[0].replace("/",".")
#     PROJECT_DIR = os.path.join(cfg['project_owner'].tolist()[0]
#                         ,"sequencing_results"
#                         ,"projects"
#                         ,cfg['project'].tolist()[0])
#     INPUTS_DIR = os.path.join(PROJECT_DIR,"input_files")
#     DIR = os.path.join(PROJECT_DIR,cfg['analysis_name'].tolist()[0])
#     SAMPLE = "full_name"

# wildcards constrains  -- mainly are separated by '.' so can't contain it
#analysis_name

rule get_all_results:
    input:  xlsx = set(expand(DIR+"/results/{sample}_fusions.xlsx",sample = cfg[SAMPLE].tolist())),

rule parse_annotate_results:
    input:  arriba_tsv = DIR + "/arriba/{sample}.arriba.tsv",
            STARFusion_tsv = DIR + "/STARFusion/{sample}.STARFusion.tsv",
            bam = INPUTS_DIR + "/mapped/{sample}.bam",
            gtf = lambda wildcards:  expand("{dir}/{organism}/{ref}/annot/{ref}.gtf",dir = REF_DIR,organism = cfg.loc[cfg[SAMPLE] == wildcards.sample,"organism"].min(),ref = cfg.loc[cfg[SAMPLE] == wildcards.sample,"reference"].min()),
    output: xlsx = DIR+"/results/{sample}_fusions.xlsx",
    log:    run = DIR + "/sample_logs/{sample}/parse_annotate_results.log",
    conda:  "../wraps/fusion_genes/parse_annotate_results/env.yaml"
    script: "../wraps/fusion_genes/parse_annotate_results/script.py"

rule arriba:
    input:  bam = INPUTS_DIR + "/mapped/{sample}.bam",
            chim= INPUTS_DIR + "/mapped/{sample}/{sample}Chimeric.out.bam",
            ref = lambda wildcards:  expand("{dir}/{organism}/{ref}/seq/{ref}.fa", dir = REF_DIR,organism = cfg.loc[cfg[SAMPLE] == wildcards.sample,"organism"].min(),ref = cfg.loc[cfg[SAMPLE] == wildcards.sample,"reference"].min()),
            gtf = lambda wildcards:  expand("{dir}/{organism}/{ref}/annot/{ref}.gtf", dir = REF_DIR,organism = cfg.loc[cfg[SAMPLE] == wildcards.sample,"organism"].min(),ref = cfg.loc[cfg[SAMPLE] == wildcards.sample,"reference"].min()),
            bll = lambda wildcards:  expand("{dir}/{organism}/{ref}/other/arriba/blacklist.tsv.gz",dir = REF_DIR,organism = cfg.loc[cfg[SAMPLE] == wildcards.sample,"organism"].min(),ref = cfg.loc[cfg[SAMPLE] == wildcards.sample,"reference"].min()),
    output: good= DIR + "/arriba/{sample}.arriba.tsv",
            pdf = DIR+"/results/{sample}_arriba_fusion_viz.pdf",
            bad = DIR + "/arriba/{sample}.arriba.discarded.tsv",
    log:    run = DIR + "/sample_logs/{sample}/arriba.log",
    threads:    1
    resources:  mem = 30
    conda:  "../wraps/fusion_genes/arriba/env.yaml"
    script: "../wraps/fusion_genes/arriba/script.py"

rule STARFusion:
    input: r1 = INPUTS_DIR + "/cleaned_fastq/{sample}_R1.fastq.gz",
           r2 = INPUTS_DIR + "/cleaned_fastq/{sample}_R2.fastq.gz",
           chim_junction = INPUTS_DIR + "/mapped/{sample}/{sample}Chimeric.out.junction",
           ref_lib = lambda wildcards:  expand("{dir}/{organism}/{ref}/other/Trinity/{ref}_ctat_genome_lib_build_dir/ref_genome.fa",dir = REF_DIR,organism = cfg.loc[cfg[SAMPLE] == wildcards.sample,"organism"].min(),ref = cfg.loc[cfg[SAMPLE] == wildcards.sample,"reference"].min()),
    output: tsv = DIR + "/STARFusion/{sample}.STARFusion.tsv",
    log:    run = DIR + "/sample_logs/{sample}/STARFusion.log",
    threads:    20
    resources:  mem = 10
    params: dir = DIR + "/STARFusion/{sample}"
    conda:  "../wraps/fusion_genes/STARFusion/env.yaml"
    script: "../wraps/fusion_genes/STARFusion/script.py"


# rule jaffa:
#     input:  r1 = INPUTS_DIR + "/cleaned_fastq/{sample}_R1.fastq.gz",
#             r2 = INPUTS_DIR + "/cleaned_fastq/{sample}_R2.fastq.gz",
#             ref_lib = lambda wildcards:  expand("{dir}/{organism}/{ref}/other/jaffa/known_fusions.txt",dir = REF_DIR,organism = cfg.loc[cfg[SAMPLE] == wildcards.sample,"organism"].min(),ref = cfg.loc[cfg[SAMPLE] == wildcards.sample,"reference"].min()),
#     output: tsv = DIR + "/jaffa/{sample}.jaffa.tsv",
#             fasta = DIR + "/jaffa/{sample}.jaffa.fasta",
#     log:    run = DIR + "/sample_logs/{sample}/jaffa.log",
#     threads:    20
#     resources:  mem = 30
#     conda:  "../wraps/fusion_genes/jaffa/env.yaml"
#     script: "../wraps/fusion_genes/jaffa/script.py"

####################################
# PREPROCESS RULEs
#
# rule preprocess_PE:
#     input: r1 = INPUTS_DIR + "/raw_fastq/{sample}_R1.fastq.gz",
#            r2 = INPUTS_DIR + "/raw_fastq/{sample}_R2.fastq.gz",
#     output: c1 = DIR + "/cleaned_fastq/{sample}_R1.fastq.gz",
#             c2 = DIR + "/cleaned_fastq/{sample}_R2.fastq.gz",
#     log:    run = DIR + "/sample_logs/{sample}/preprocess_PE.log",
#             trim = DIR + "/trimmed/{sample}.PE.trim_stats.log",
#     threads:    10
#     resources:  mem = 10
#     params: adaptors = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"adaptors"].min(),
#             r1u = DIR + "/trimmed/{sample}_R1.discarded.fastq.gz",
#             r2u = DIR + "/trimmed/{sample}_R2.discarded.fastq.gz",
#             trim_left1 = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"trim_left1"].min(), # Applied only if trim left is true, trimming from R1 (different for classic:0, quant:10, sense:9)
#             trim_right1 = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"trim_right1"].min(), # Applied only if trim right is true, trimming from R1; you should allow this if you want to trim the last extra base and TRIM_LE is true as RD_LENGTH is not effective
#             trim_left2 = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"trim_left2"].min(), # Applied only if trim left is true, trimming from R2 (different for classic:0, quant:?, sense:7)
#             trim_right2 = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"trim_right2"].min(), # Applied only if trim right is true, trimming from R2; you should allow this if you want to trim the last extra base and TRIM_LE is true as RD_LENGTH is not effective
#             phred = "-phred33",
#             leading = 3,
#             trailing = 3,
#             crop = 250,
#             minlen = 35,
#             slid_w_1 = 4,
#             slid_w_2 = 5,
#     conda:  "../wraps/fastq2bam_RNA/preprocess_PE/env.yaml"
#     script: "../wraps/fastq2bam_RNA/preprocess_PE/script.py"
#
# rule preprocess_SE:
#     input: raw = INPUTS_DIR + "/raw_fastq/{sample}_SE.fastq.gz"
#     output: clean = DIR + "/cleaned_fastq/{sample}_SE.fastq.gz",
#     log:    run = DIR + "/sample_logs/{sample}/preprocess_SE.log",
#             trim = DIR + "/trimmed/{sample}.PE.trim_stats.log",
#     threads:    10
#     resources:  mem = 10
#     params: adaptors = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"adaptors"].min(),
#             trim_left1 = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"trim_left1"].min(), # Applied only if trim left is true, trimming from R1 (different for classic:0, quant:10, sense:9)
#             trim_right1 = lambda wildcards: cfg.loc[cfg[SAMPLE] == wildcards.sample,"trim_right1"].min(), # Applied only if trim right is true, trimming from R1; you should allow this if you want to trim the last extra base and TRIM_LE is true as RD_LENGTH is not effective
#             phred = "-phred33",
#             leading = 3,
#             trailing = 3,
#             crop = 250,
#             minlen = 35,
#             slid_w_1 = 4,
#             slid_w_2 = 5,
#     conda:  "../wraps/fastq2bam_RNA/preprocess_SE/env.yaml"
#     script: "../wraps/fastq2bam_RNA/preprocess_SE/script.py"
