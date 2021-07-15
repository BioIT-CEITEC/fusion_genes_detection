######################################
# wrapper for rule: jaffa
######################################
import os
import sys
import math
import subprocess
import glob
import re
from snakemake.shell import shell

shell.executable("/bin/bash")


f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: jaffa \n##\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.tsv)+" 2>> "+snakemake.log.run
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

input_files = snakemake.input.r1 + " " + snakemake.input.r2

# TODO: find how to add options to conda jaffa
# -n " + str(snakemake.threads) + \
#                " -m " + str(snakemake.resources.mem) + \
command_prep = "export JAFFA_REF_BASE=\""+os.path.dirname(snakemake.input.ref_lib[0])+"\""
command = "jaffa-hybrid" + \
               " " + input_files + \
               " >> " + snakemake.log.run + " 2>&1 "
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command_prep+"\n"+command+"\n")
f.close()
shell("""
    {command_prep}
    {command}
""")

command = "mv jaffa_results.csv " + snakemake.output.tsv
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv jaffa_results.fasta " + snakemake.output.fasta
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv " + re.sub("_.*", "", snakemake.wildcards.sample) + " " + os.path.dirname(snakemake.output.tsv) + "/" + snakemake.wildcards.sample
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv commandlog.txt " + os.path.dirname(snakemake.output.tsv) + "/" + snakemake.wildcards.sample
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv checks " + os.path.dirname(snakemake.output.tsv) + "/" + snakemake.wildcards.sample
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
