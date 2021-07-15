######################################
# wrapper for rule: STARFusion
######################################
import os
import sys
import math
import subprocess
import glob
from snakemake.shell import shell
import igv_reports

shell.executable("/bin/bash")

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: STARFusion \n##\n")
f.close()

version = str(subprocess.Popen("STAR-Fusion --version 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.tsv)+" 2>> "+snakemake.log.run
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

input_files = " --left_fq " + snakemake.input.r1 + " --right_fq " + snakemake.input.r2
# input_files = " -J " + snakemake.input.chim_junction

command = "STAR-Fusion --CPU " + str(snakemake.threads) + \
               input_files + \
               " --genome_lib_dir " + os.path.dirname(snakemake.input.ref_lib[0]) + \
               " --output_dir " + snakemake.params.dir + \
               " --FusionInspector validate" + \
               " --examine_coding_effect" + \
               " >> " + snakemake.log.run + " 2>&1 "
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()

try:
    shell(command)
except:
    f = open(snakemake.log.run, 'at')
    f.write("## COMMAND: "+command + " --- failed with error. However, if finspector.FusionInspector.fusions.abridged.tsv exists, I don't care. :-)\n")
    f.close()

command = "cp " + snakemake.params.dir + "/FusionInspector-validate/finspector.FusionInspector.fusions.abridged.tsv " + snakemake.output.tsv
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
