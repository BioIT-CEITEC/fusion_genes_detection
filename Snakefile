import os
import pandas as pd
import json
from snakemake.utils import min_version

configfile: "config.json"

min_version("5.18.0")

GLOBAL_REF_PATH = "/mnt/references/"

# # Reference processing
# #

# setting organism from reference
f = open(os.path.join(GLOBAL_REF_PATH,"reference_info","reference.json"),)
reference_dict = json.load(f)
f.close()
config["organism"] = [organism_name.lower().replace(" ","_") for organism_name in reference_dict.keys() if isinstance(reference_dict[organism_name],dict) and config["reference"] in reference_dict[organism_name].values()][0]

##### Config processing #####
# Folders
#
reference_directory = os.path.join(GLOBAL_REF_PATH,config["organism"],config["reference"])

# Samples
#
sample_tab = pd.DataFrame.from_dict(config["samples"],orient="index")


if config["is_paired"]:
    read_pair_tags = [""]
    paired = "SE"
else:
    read_pair_tags = ["_R1","_R2"]
    paired = "PE"

wildcard_constraints:
     sample = "|".join(sample_tab.sample_name) + "|all_samples",

##### Target rules #####

rule all:
    input: expand("results/{sample}_fusions.xlsx",sample = sample_tab.sample_name),

##### Modules #####
include: "rules/fusion_genes.smk"
