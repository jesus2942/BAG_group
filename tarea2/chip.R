args_script <- commandArgs(trailingOnly = T)
results_dir <- as.character(args_script[[1]])
print(results_dir)
ins_dir <- as.character(args_script[[2]])
print(ins_dir)
tf <- as.character(args_script[[3]])
print(tf)

cat("EXECUTING R SCRIPT")


library(ChIPseeker)
library(TxDb.Athaliana.BioMart.plantsmart28)
txdb <- TxDb.Athaliana.BioMart.plantsmart28


## Leer fichero de picos
if(tf == "Y")
{
  prr5.peaks <- readPeakFile(peakfile = "working_file.narrowPeak",header=FALSE)
} else if(tf == "N")
{
  prr5.peaks <- readPeakFile(peakfile = "working_file.broadPeak",header=FALSE)
}


## Definir la región que se considera promotor entorno al TSS
promoter <- getPromoters(TxDb=txdb, 
                         upstream=1000, 
                         downstream=1000)

## Anotación de los picos
prr5.peakAnno <- annotatePeak(peak = prr5.peaks, 
                              tssRegion=c(-1000, 1000),
                              TxDb=txdb)

cat("CISTROME GLOBAL DISTRIBUTION ANALYSIS")

#Pie plot
png("pie.plot.png")
plotAnnoPie(prr5.peakAnno)
dev.off()
#Bar plot
png("bar.plot.png")
plotAnnoBar(prr5.peakAnno)
dev.off()
#Plot of distance to TSS Transcription Start Site (TTS Transcription Termination Site)
png("dist.to.tss.plot.png")
plotDistToTSS(prr5.peakAnno,
              title="Distribution of genomic loci relative to TSS",
              ylab = "Genomic Loci (%) (5' -> 3')")
dev.off()





cat("REGULOME DETERMINATION")

## Convertir la anotación a data frame
prr5.annotation <- as.data.frame(prr5.peakAnno)
head(prr5.annotation)

target.genes <- prr5.annotation$geneId[prr5.annotation$annotation == "Promoter"]

write(x = target.genes,file = "prr5_target_genes.txt")



cat("GO TERM ENRICHMENT ANALYSIS")

## Enriquecimiento funcional. 


library(clusterProfiler)

library(org.At.tair.db)

prr5.enrich.go <- enrichGO(gene = target.genes,
                           OrgDb         = org.At.tair.db,
                           ont           = "BP",
                           pAdjustMethod = "BH",
                           pvalueCutoff  = 0.05,
                           readable      = FALSE,
                           keyType = "TAIR")

png("enrich.go.bar.plot.png")
barplot(prr5.enrich.go,showCategory = 20)
dev.off()

png("enrich.go.dot.plot.png")
dotplot(prr5.enrich.go,showCategory = 20)
dev.off()


library(enrichplot)

png("enrich.go.emap.plot.png")
emapplot(pairwise_termsim(prr5.enrich.go),showCategory = 20, cex_label_category=0.5)
dev.off()

#Se representan los procesos biologicos enriquecidos y ademas los genes involucrados
png("enrich.go.cnet.plot.png")
cnetplot(prr5.enrich.go,showCategory = 20, cex_label_category=0.5, cex_label_gene=0.5)
dev.off()


cat("KEGG")

#Encontrar rutas metabolicas enriquecidas
prr5.enrich.kegg <- enrichKEGG(gene  = target.genes,
                               organism = "ath",
                               pAdjustMethod = "BH",
                               pvalueCutoff  = 0.05)
df.prr5.enrich.kegg <- as.data.frame(prr5.enrich.kegg)
#head(df.prr5.enrich.kegg)
write.table(df.prr5.enrich.kegg, "enrich.kegg.csv")
