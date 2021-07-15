######################################
# wrapper for rule: jaffa
######################################
import os
import re
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: jaffa \n##\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.tsv)+" 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

input_files = snakemake.input.r1 + " " + snakemake.input.r2

# TODO: find how to add options to conda jaffa
# -n " + str(snakemake.threads) + \
#                " -m " + str(snakemake.resources.mem) + \
command_prep = "export JAFFA_REF_BASE=\""+os.path.dirname(snakemake.input.ref_lib)+"\""
command = "jaffa-hybrid" + \
               " " + input_files + \
               " >> " + log_filename + " 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command_prep+"\n"+command+"\n")
f.close()
shell("""
    {command_prep}
    {command}
""")

command = "mv jaffa_results.csv " + snakemake.output.tsv
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv jaffa_results.fasta " + snakemake.output.fasta
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv " + re.sub("_.*", "", snakemake.wildcards.sample) + " " + os.path.dirname(snakemake.output.tsv) + "/" + snakemake.wildcards.sample
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv commandlog.txt " + os.path.dirname(snakemake.output.tsv) + "/" + snakemake.wildcards.sample
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = "mv checks " + os.path.dirname(snakemake.output.tsv) + "/" + snakemake.wildcards.sample
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
