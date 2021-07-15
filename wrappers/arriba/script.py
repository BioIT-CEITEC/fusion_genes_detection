######################################
# wrapper for rule: arriba
######################################
import os
import sys
import math
import subprocess
import glob
import re
from snakemake.shell import shell

shell.executable("/bin/bash")

TOOL = "arriba"

f = open(snakemake.log.run, 'a+')
f.write("\n##\n## RULE: arriba \n##\n")
f.close()

version = str(subprocess.Popen("arriba -h | grep '^[vV]ersion' 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(snakemake.log.run, 'at')
f.write("## VERSION: arriba "+version+"\n")
f.close()

command = "arriba -c " + snakemake.input.chim + \
            " -x " + snakemake.input.bam + \
            " -a " + snakemake.input.ref[0] + \
            " -g " + snakemake.input.gtf[0] + \
            " -b " + snakemake.input.bll[0] + \
            " -o " + snakemake.output.good + \
            " -O " + snakemake.output.bad + \
            " -T -T -P -P " + " >> " + snakemake.log.run + " 2>&1"
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = " Rscript `dirname $(which arriba)`/draw_fusions.R "+\
          " --fusions=" + snakemake.output.good + \
          " --alignments=" + snakemake.input.bam +\
          " --output=" + snakemake.output.pdf +\
          " --annotation=" + snakemake.input.gtf[0] +\
          " --cytobands=`dirname $(which arriba)`/../var/lib/arriba/cytobands_hg38_GRCh38_2018-02-23.tsv" +  \
          " --proteinDomains=`dirname $(which arriba)`/../var/lib/arriba/protein_domains_hg38_GRCh38_2018-03-06.gff3"
f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
