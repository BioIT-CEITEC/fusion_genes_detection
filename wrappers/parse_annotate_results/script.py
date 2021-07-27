######################################
# wrapper for rule: parse_annotate_results
######################################
import os
from snakemake.shell import shell
shell.executable("/bin/bash")
log_filename = str(snakemake.log)


f = open(log_filename, 'wt')
f.write("\n##\n## RULE: parse_annotate_results \n##\n")
f.close()


command = " Rscript "+os.path.abspath(os.path.dirname(__file__))+"/parse_annotate_results.R "+\
            snakemake.input.arriba_tsv+ " " +\
            snakemake.input.STARFusion_tsv + " " +\
            snakemake.params.txt + " " +\
            snakemake.output.xlsx

f = open(log_filename, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)
