suppressMessages(library(data.table))
suppressMessages(library(openxlsx))
Sys.setenv("R_ZIPCMD" = "zip")

run_all <- function(args){
  arriba_tab_filename <- args[1]
  star_tab_filename <- args[2]
  output_xlsx_filename <- args[3]
  
  
arriba_tab <- fread(arriba_tab_filename)
star_tab <- fread(star_tab_filename)

if(nrow(arriba_tab) + nrow(star_tab) > 0){
  fusion_hub_annot <- fread(paste0(script_dir,"/Fusionhub_global_summary.txt"))
  fusion_hub_annot[,(tail(names(fusion_hub_annot),1)) := NULL]
  fusion_hub_annot <- melt.data.table(fusion_hub_annot,id.vars = "Fusion_gene")
  fusion_hub_annot <- fusion_hub_annot[value == "+",.(DB_count = .N,DB_list = paste(variable,collapse = ", ")),by = Fusion_gene]
  
  setnames(arriba_tab,"#gene1","gene1")
  arriba_tab[,c("chrom1","pos1") := tstrsplit(breakpoint1,":")]
  arriba_tab[,c("chrom2","pos2") := tstrsplit(breakpoint2,":")]
  arriba_tab[,.(gene2_sep = unlist(strsplit(gene2,",")))]
  arriba_tab[,gene2_sep := strsplit(gene2,",")]
  arriba_tab <- arriba_tab[rep(arriba_tab[,.I], lengths(gene2_sep))][, gene2_sep := unlist(arriba_tab$gene2_sep)][]
  
  if(nrow(arriba_tab) > 0){
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
  } else {
    arriba_tab <- data.table(gene1 = character()
                             ,gene2 = character()
                             ,chrom1 = character()
                             ,pos1 = integer()
                             ,strand1 = character()
                             ,chrom2 = character()
                             ,pos2 = integer()
                             ,strand2 = character()
                             ,arriba.confidence = character()
                             ,arriba.split_reads = numeric()
                             ,arriba.discordant_mates = numeric()
                             ,arriba.break_coverage = numeric()
                             ,arriba.break2_coverage = numeric()
                             ,arriba.site1 = character()
                             ,arriba.site2 = character()
                             ,arriba.break_seq = character()
                             ,arriba.called = logical())
  }
  
  
  if(nrow(star_tab) > 0){
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
  } else {
    star_tab <- data.table(gene1 = character()
                           ,gene2 = character()
                           ,chrom1 = character()
                           ,pos1 = integer()
                           ,strand1 = character()
                           ,chrom2 = character()
                           ,pos2 = integer()
                           ,strand2 = character()
                           ,starfus.split_reads = numeric()
                           ,starfus.discordant_mates = numeric()
                           ,starfus.counter_fusion1 = numeric()
                           ,starfus.counter_fusion2 = numeric()
                           ,starfus.splice_type = character()
                           ,starfus.break_seq = character()
                           ,starfus.called = logical())
  }
  
  
  
  
  
  
  combined_res <- merge(arriba_tab,star_tab,by = c("gene1","gene2","chrom1","pos1","strand1","chrom2","pos2","strand2"),all = T)
  combined_res[is.na(arriba.called),arriba.called := F]
  combined_res[is.na(starfus.called),starfus.called := F]
  combined_res[,overall_support := rowSums(.SD,na.rm = T),.SDcols = c("arriba.split_reads","arriba.discordant_mates","starfus.split_reads","starfus.discordant_mates")]
  combined_res[,num_called := arriba.called + starfus.called]
  setorder(combined_res,-num_called,-overall_support)
  combined_res[,num_called := NULL]
  combined_res[,Fusion_gene := paste0(gene1,"--",gene2)]
  combined_res <- merge(combined_res,fusion_hub_annot,by = "Fusion_gene",all.x = T)
  combined_res[is.na(DB_count),DB_count := 0]
  combined_res[is.na(DB_list),DB_list := ""]
  combined_res[,Fusion_gene := NULL]
  
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
                             ,"DB_count"
                             ,"DB_list"
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
                             ,"arriba.break_seq"
                             ,"starfus.break_seq"))
} else {
  combined_res <- data.table("NO FUSIONS DETECTED")
}


if(!dir.exists(dirname(output_xlsx_filename))){
  dir.create(dirname(output_xlsx_filename))
}

write.xlsx(combined_res,file = output_xlsx_filename)

}

# script_dir <- dirname(sub("--file=", "", commandArgs()[grep("--file=", commandArgs())]))
# args <- commandArgs(trailingOnly = T)
# run_all(args)

# develop and test
# args <- character(3)
# args[1] <- "/mnt/ssd/ssd_1/snakemake/stage250_solid_tumors_children.74_fusions/RNA_panel_fusion_gene_detection/arriba/VC1057fuze.arriba.tsv"
# args[2] <- "/mnt/ssd/ssd_1/snakemake/stage250_solid_tumors_children.74_fusions/RNA_panel_fusion_gene_detection/STARFusion/VC1057fuze.STARFusion.tsv"
# args[3] <- "/mnt/ssd/ssd_1/snakemake/stage250_solid_tumors_children.74_fusions/RNA_panel_fusion_gene_detection/results/VC1057fuze_fusions.xlsx"
# script_dir <<- "/mnt/nfs/shared/999993-Bioda/bioda_snakemake/wraps/fusion_genes/parse_annotate_results"

#run as Rscript
# 
script_dir <<- dirname(sub("--file=", "", commandArgs()[grep("--file=", commandArgs())]))
args <- commandArgs(trailingOnly = T)
run_all(args)


