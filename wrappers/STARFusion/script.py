######################################
# wrapper for rule: STARFusion
######################################
import os
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)

f = open(log_filename, 'a+')
f.write("\n##\n## RULE: STARFusion \n##\n")
f.close()

version = str(subprocess.Popen("STAR-Fusion --version 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: "+version+"\n")
f.close()

command = "mkdir -p "+os.path.dirname(snakemake.output.tsv)+" 2>> "+log_filename
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

if snakemake.params.is_paired:
    input_files = " --left_fq " + snakemake.input.r1 + " --right_fq " + snakemake.input.r2

else:
    input_files = " --left_fq " + snakemake.input.r1

command = "STAR-Fusion --CPU " + str(snakemake.threads) + \
               input_files + \
               " --genome_lib_dir " + snakemake.input.ref_lib + \
               " --output_dir " + snakemake.params.dir + \
               " --FusionInspector validate" + \
               " --examine_coding_effect" + \
               " >> " + log_filename + " 2>&1 "
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()

try:
    shell(command)
except:
    f = open(log_filename, 'at')
    f.write("## COMMAND: "+command + " --- failed with error. However, if finspector.FusionInspector.fusions.abridged.tsv exists, I don't care. :-)\n")
    f.close()

command = "cp " + snakemake.params.dir + "/FusionInspector-validate/finspector.FusionInspector.fusions.abridged.tsv " + snakemake.output.tsv
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
