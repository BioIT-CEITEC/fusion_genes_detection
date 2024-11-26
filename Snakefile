import os
import pandas as pd
import json
from snakemake.utils import min_version

configfile: "config.json"

min_version("5.18.0")

configfile: "config.json"

GLOBAL_REF_PATH = config["globalResources"]
GLOBAL_TMPD_PATH = config["globalTmpdPath"]

os.makedirs(GLOBAL_TMPD_PATH, exist_ok=True)

##### BioRoot utilities #####

module BR:
    snakefile: github("BioIT-CEITEC/bioroots_utilities", path="bioroots_utilities.smk",branch="master")
    config: config

use rule * from BR as other_*

##### Config processing #####

sample_tab = BR.load_sample()

config = BR.load_organism()

wildcard_constraints:
     sample = "|".join(sample_tab.sample_name) + "|all_samples",

##### Target rules #####

rule all:
    input: expand("results/{sample}_fusions.xlsx",sample = sample_tab.sample_name),

##### Modules #####
include: "rules/fusion_genes.smk"
