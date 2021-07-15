######################################
# wrapper for rule: parse_annotate_results
######################################
import os
import sys
import math
import subprocess
import re
from snakemake.shell import shell
import argparse
import urllib.request
import shutil
import collections
import csv

f = open(snakemake.log.run, 'wt')
f.write("\n##\n## RULE: parse_annotate_results \n##\n")
f.close()

# version = str(subprocess.Popen("arriba -h | grep '^[vV]ersion' 2>&1", shell=True, stdout=subprocess.PIPE).communicate()[0], 'utf-8')
# f = open(snakemake.log.run, 'at')
# f.write("## VERSION: arriba "+version+"\n")
# f.close()

command = " Rscript "+os.path.abspath(os.path.dirname(__file__))+"/parse_annotate_results.R "+\
            snakemake.input.arriba_tsv+ " " +\
            snakemake.input.STARFusion_tsv + " " +\
            snakemake.output.xlsx

f = open(snakemake.log.run, 'at')
f.write("## COMMAND: "+command+"\n")
f.close()
shell(command)

# command = "cat `ls -tr "+ os.path.dirname(snakemake.log.run) +"/*.log` > "+ os.path.dirname(snakemake.log.run) + "." + snakemake.wildcards.analysis_subclass +  ".log"
# f = open(snakemake.log.run, 'at')
# f.write("## COMMAND: "+command+"\n")
# f.close()
# shell(command)







# # assign to variable
# output_name = snakemake.output.tsv
# fusionhub_db = os.path.abspath(os.path.dirname(__file__)) + "/Fusionhub_global_summary.txt"
# project_name = snakemake.params.project_name
#
# # download FusionHub db
# def download_fusionhub_db(
#                     out_dir, file_name = 'Fusionhub_global_summary.txt',
#                     URL = 'https://fusionhub.persistent.co.in/out/global/Fusionhub_global_summary.txt'
#                     ):
#     ''' download fusion hub database from source '''
#     file_name_path = os.path.join(out_dir, file_name)
#     log.write(f'[i] download FusionHub database from {URL} to {file_name_path}')
#     with urllib.request.urlopen(URL) as response, open(file_name_path, 'wb') as out_file:
#         shutil.copyfileobj(response, out_file)
#     assert os.path.isfile(file_name_path), '[!] Fusionhub db download failed'
#     log.write('[i] download completed')
#     return(file_name_path)
#
# def read_db(fusionhub_file):
#     ''' store Fusion Hub db as dictionary with
#         key:value == fusion gene:databases '''
#     log.write(f'[i] reading Fusionhub db from {fusionhub_file}')
#     fusionhub_table = csv.DictReader(open(fusionhub_file, 'r'), delimiter = '\t')
#     fusionhub_db, HEADER = {}, next(fusionhub_table)
#     for line in fusionhub_table:
#         fusionhub_db[line['Fusion_gene']] = [ db for db in HEADER if line[db] == '+' ]
#     return(fusionhub_db)
#
# def interrogate_fusionhub(fusion, fusionhub_db):
#     ''' check if fusion exists in fusionhub '''
#     db_names, db_number = [], 0
#     fusion_rev = f'{fusion.split("--")[1]}--{fusion.split("--")[0]}'
#     if fusion in fusionhub_db:
#         db_names += fusionhub_db[fusion]
#         db_number += len(fusionhub_db[fusion])
#     if fusion_rev in fusionhub_db:
#         db_names += [ i + '*' for i in fusionhub_db[fusion_rev] ]
#         db_number += len(fusionhub_db[fusion_rev])
#     return(db_names, db_number)
#
# def format_output(fusion, tool, fusionhub_db, project_name, sample):
#     ''' input named tuple from each tool's table
#         is arranged in a standard format '''
#     if tool == 'star':
#         chrom1, start1, strand1 = fusion.LeftBreakpoint.split(':')
#         chrom2, start2, strand2 = fusion.RightBreakpoint.split(':')
#         fusion_name = fusion.fusion_genes
#         FFPM = fusion.FFPM
#     elif tool == 'jaffa':
#         chrom1, start1, strand1 = fusion.chrom1, fusion.base1, fusion.strand1
#         chrom2, start2, strand2 = fusion.chrom2, fusion.base2, fusion.strand2
#         fusion_name = fusion.fusion_genes.replace(':', '--')
#         FFPM = '.'
#     tot_reads = int(fusion.spanning_reads) + int(fusion.spanning_pairs.replace('-', '0'))
#     if chrom1 == chrom2:
#         identity = 'intraChrom'
#     else:
#         identity = 'translocation'
#     db_names, db_number = interrogate_fusionhub(fusion_name, fusionhub_db)
#     format_string = (
#                     f'{project_name}\t{sample}\t{fusion_name}\t{tool}\t{identity}\t{db_names}\t'
#                     + f'{db_number}\t{tot_reads}\t{fusion.spanning_reads}\t'
#                     + f'{fusion.spanning_pairs}\t{FFPM}\t{chrom1}\t'
#                     + f'{start1}\t{strand1}\t{chrom2}\t{start2}\t{strand2}\n'
#                     )
#     return(format_string)
#
# def read_fusion_csv(table_path, project_name, fusionhub_db):
#     ''' read tool's fusion table, and arrange each
#     fusion gene to a standard format '''
#     table = re.sub(".*/([^\.]+\.[^\.]+)\..*","\\1",table_path)
#     sample, fusion_list = table.split('.')[0].replace('_R1', ''), []
#     if os.stat(table_path).st_size <= 206:
#         log.write(f'\t[!] {table} is empty, skip..')
#         return(fusion_list)
#     if 'jaffa' in table:
#         tool = 'jaffa'
#         HEADER = (
#             'sample,fusion_genes,chrom1,'
#             + 'base1,strand1,chrom2,base2,'
#             + 'strand2,gap_kb,spanning_pairs,'
#             + 'spanning_reads,inframe,aligns,'
#             + 'rearrangement,contig,contig_break,'
#             + 'classification,known'
#             )
#         csv_to_list = csv.reader(open(table_path, "r"))
#         next(csv_to_list) # skip header
#     elif 'STARFusion' in table:
#         tool = 'star'
#         HEADER = (
#             'fusion_genes,spanning_reads,spanning_pairs,'
#             + 'SpliceType,LeftGene,LeftBreakpoint,RightGene,'
#             + 'RightBreakpoint,LargeAnchorSupport,FFPM,'
#             + 'LeftBreakDinuc,LeftBreakEntropy,'
#             + 'RightBreakDinuc,RightBreakEntropy,annots'
#             )
#         csv_to_list = csv.reader(open(table_path, "r"), delimiter = '\t')
#         next(csv_to_list) # skip header
#     elif 'arriba' in table:
#         tool = 'arriba'
#         HEADER = (
#             'gene1,gene2,strand1(gene/fusion),strand2(gene/fusion),'
#             + 'breakpoint1,breakpoint2,site1,site2,type,direction1,'
#             + 'direction2,split_reads1,split_reads2,discordant_mates,'
#             + 'coverage1,coverage2,confidence,closest_genomic_breakpoint1,'
#             + 'closest_genomic_breakpoint2,filters,fusion_transcript,'
#             + 'reading_frame,peptide_sequence,read_identifiers'
#             )
#         csv_to_list = csv.reader(open(table_path, "r"), delimiter = '\t')
#         next(csv_to_list) # skip header
#     else:
#         log.write(f'\t[!] {table} is not a target, skip..')
#         return(fusion_list)
#     Fusion = collections.namedtuple( 'Fusion', HEADER )
#     log.write(f'\t[i] {table} size is OK, formatting..')
#     fusion_list += [ format_output(fusion, tool, fusionhub_db, project_name, sample)
#                     for fusion in map(Fusion._make, csv_to_list) ]
#     return(fusion_list)
#
# def print_output_table(sample_fusions_list, output_name):
#     ''' print final table '''
#     with open(f'{output_name}', 'w') as OUTPUT:
#         HEADER = ('run\tsample\tfusion\ttool\tidentity\t'
#                 + 'FusionHub_DB (*=reverse)\tFusionHub_tot\tcoverage:total\t'
#                 + 'coverage:onBP\tcoverage:pair\tFFPM\tchrom1\t'
#                 + 'pos1\tstrand\tchrom2\tpos2\tstrand\n')
#         OUTPUT.write(HEADER)
#         for sample_fusions in sample_fusions_list:
#             [OUTPUT.write(f'{fusion}') for fusion in sample_fusions if fusion]
#
#     log.write(f'[i] wrapping completed.')
#     return()
#
# ##### Tools Wrapper #####
# if __name__ == "__main__":
#     fusionhub_db = read_db(fusionhub_db)
#     wrapped_fusion_tables = [ read_fusion_csv(fusion_file, project_name, fusionhub_db)
#                     for fusion_file in snakemake.input.tsv]
#     print_output_table(wrapped_fusion_tables, output_name)
#
# log.close()
