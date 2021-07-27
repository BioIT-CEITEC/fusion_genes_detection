######################################
# wrapper for rule: arriba
######################################
import subprocess
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'a+')
f.write("\n##\n## RULE: arriba \n##\n")
f.close()

version = str(subprocess.Popen("arriba -h | grep '^[vV]ersion' 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
f = open(log_filename, 'at')
f.write("## VERSION: arriba "+version+"\n")
f.close()

command = "arriba -c " + snakemake.input.chim + \
            " -x " + snakemake.input.bam + \
            " -a " + snakemake.input.ref + \
            " -g " + snakemake.input.gtf + \
            " -b " + snakemake.input.bll + \
            " -o " + snakemake.output.good + \
            " -O " + snakemake.output.bad + \
            " -I " + " >> " + log_filename + " 2>&1"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

command = " Rscript `dirname $(which arriba)`/draw_fusions.R "+ \
          " --annotation=" + snakemake.input.gtf + \
          " --fusions=" + snakemake.output.good + \
          " --output=" + snakemake.output.pdf + \
          " --alignments=" + snakemake.input.bam +\
          " --cytobands=`dirname $(which arriba)`/../var/lib/arriba/cytobands_hg38_GRCh38_v2.1.0.tsv " +  \
          " --proteinDomains=`dirname $(which arriba)`/../var/lib/arriba/protein_domains_hg38_GRCh38_v2.1.0.gff3"
f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
