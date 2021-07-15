suppressMessages(library(data.table))
suppressMessages(library(xlsx))

run_all <- function(args){
  var_file <- args[1]
  
arriba_tab <- fread("/mnt/nfs/shared/000000-Shared/groups/CFBioinformatics/sequencing_results/projects/gene_fusion/RNA_panel_fusion_gene_detection/arriba/SK0402_fuze.arriba.tsv")
star_tab <- fread("/mnt/nfs/shared/000000-Shared/groups/CFBioinformatics/sequencing_results/projects/gene_fusion/RNA_panel_fusion_gene_detection/STARFusion/SK0402_fuze/FusionInspector-validate/finspector.FusionInspector.fusions.abridged.tsv")


fusion_hub_annot <- fread("/mnt/nfs/shared/999993-Bioda/bioda_snakemake/wraps/fusion_genes/parse_annotate_results/Fusionhub_global_summary.txt")
fusion_hub_annot[,(tail(names(fusion_hub_annot),1)) := NULL]
fusion_hub_annot <- melt.data.table(fusion_hub_annot,id.vars = "Fusion_gene")
fusion_hub_annot <- fusion_hub_annot[value == "+",.(DB_count = .N,DB_list = paste(variable,collapse = ", ")),by = Fusion_gene]

setnames(arriba_tab,"#gene1","gene1")
arriba_tab[,c("chrom1","pos1") := tstrsplit(breakpoint1,":")]
arriba_tab[,c("chrom2","pos2") := tstrsplit(breakpoint2,":")]
arriba_tab[,.(gene2_sep = unlist(strsplit(gene2,",")))]
arriba_tab[,gene2_sep := strsplit(gene2,",")]
arriba_tab <- arriba_tab[rep(arriba_tab[,.I], lengths(gene2_sep))][, gene2_sep := unlist(arriba_tab$gene2_sep)][]

arriba_tab <- arriba_tab[,.(gene1 = gene1
            ,gene2 = gsub("\\(.*","",gene2_sep)
            ,chrom1 = paste0("chr",chrom1)
            ,pos1 = as.integer(pos1)
            ,strand1 = gsub("^..","",`strand1(gene/fusion)`)
            ,chrom2 = paste0("chr",chrom2)
            ,pos2 = as.integer(pos2)
            ,strand2 = gsub("^..","",`strand2(gene/fusion)`)
            ,arriba.confidence = confidence
            ,arriba.split_reads = split_reads1 + split_reads2
            ,arriba.discordant_mates = discordant_mates
            ,arriba.break_coverage = coverage1
            ,arriba.break2_coverage = coverage2
            ,arriba.site1 = site1
            ,arriba.site2 = site2
            ,arriba.break_seq = fusion_transcript
            ,arriba.called = TRUE)]


star_tab[,c("chrom1","pos1","strand1") := tstrsplit(LeftBreakpoint,":")]
star_tab[,c("chrom2","pos2","strand2") := tstrsplit(RightBreakpoint,":")]
star_tab <- star_tab[,.(gene1 = gsub("\\^.*","",LeftGene)
           ,gene2 = gsub("\\^.*","",RightGene)
           ,chrom1 = chrom1
           ,pos1 = as.integer(pos1)
           ,strand1 = strand1
           ,chrom2 = chrom2
           ,pos2 = as.integer(pos2)
           ,strand2 = strand2
           ,starfus.split_reads = JunctionReadCount
           ,starfus.discordant_mates = SpanningFragCount
           ,starfus.counter_fusion1 = NumCounterFusionLeft
           ,starfus.counter_fusion2 = NumCounterFusionRight
           ,starfus.splice_type = SpliceType
           ,starfus.break_seq = NA
           ,starfus.called = TRUE)]




combined_res <- merge(arriba_tab,star_tab,by = c("gene1","gene2","chrom1","pos1","strand1","chrom2","pos2","strand2"),all = T)
combined_res[is.na(arriba.called),arriba.called := F]
combined_res[is.na(starfus.called),starfus.called := F]
combined_res[,overall_support := rowSums(.SD,na.rm = T),.SDcols = c("arriba.split_reads","arriba.discordant_mates","starfus.split_reads","starfus.discordant_mates")]
combined_res[,num_called := arriba.called + starfus.called]
setorder(combined_res,-num_called,-overall_support)
combined_res[,num_called := NULL]
setcolorder(combined_res,c("gene1"
         ,"gene2"
         ,"chrom1"
         ,"pos1"
         ,"strand1"
         ,"chrom2"
         ,"pos2"
         ,"strand2"
         ,"arriba.called"
         ,"starfus.called"
         ,"overall_support"
         ,"arriba.confidence"
         ,"arriba.split_reads"
         ,"arriba.discordant_mates"
         ,"arriba.break_coverage"
         ,"arriba.break2_coverage"
         ,"arriba.site1"
         ,"arriba.site2"
         ,'starfus.split_reads'
         ,"starfus.discordant_mates"
         ,"starfus.counter_fusion1"
         ,"starfus.counter_fusion2"
         ,"starfus.splice_type"
         ,"starfus.break_seq"))

write.xlsx(combined_res,file = "")

}

# script_dir <- dirname(sub("--file=", "", commandArgs()[grep("--file=", commandArgs())]))
# args <- commandArgs(trailingOnly = T)
# run_all(args)

# develop and test
# args <- character(3)
# args[1] <- "/Volumes/share/000000-Shared/groups/MedGen/sequencing_results/projects/TP53/March_2019/germline_variant_calling/merged/1077.germline.not_filtered.vcf"
# args[2] <- "/mnt/ssd/ssd_1/snakemake/CLG/sequencing_results/projects/BRONCO/11/germline_variant_calling/merged/H-0062.germline.not_filtered.tsv"
# args[3] <- "germline"

# develop and test
# args <- character(3)
# args[1] <- "/mnt/ssd/ssd_1/snakemake/MedGen/sequencing_results/projects/Cosimo/pub_WES_Crescenzo/somatic_variant_calling/merged/GPS27_pos.somatic.not_filtered.vcf"
# args[2] <- "/mnt/ssd/ssd_1/snakemake/MedGen/sequencing_results/projects/Cosimo/pub_WES_Crescenzo/somatic_variant_calling/merged/GPS27_pos.somatic.tsv"
# args[3] <- "somatic"

# develop and test
# args <- character(3)6393947
# args[1] <- "/mnt/ssd/ssd_1/snakemake/CFGenomics/sequencing_results/projects/Yvone/somatic_variant_calling/merged/21185.somatic.vcf"
# args[2] <- "/mnt/ssd/ssd_1/snakemake/CFGenomics/sequencing_results/projects/Yvone/somatic_variant_calling/merged/21185.somatic.tsv"
# args[3] <- "somatic"

#run as Rscript

# args <- commandArgs(trailingOnly = T)
# run_all(args)


