######################################################

options(stringsAsFactors = F)
library(TxDb.Hsapiens.UCSC.hg19.knownGene) 
library(TxDb.Mmusculus.UCSC.mm10.knownGene) 
library(TxDb.Hsapiens.UCSC.hg38.knownGene) 
library(ChIPpeakAnno) 
library(ChIPseeker)
library(clusterProfiler) 
library(org.Mm.eg.db)
library(org.Hs.eg.db)
library(ggplot2)
## loading packages
txdb <- TxDb.Hsapiens.UCSC.hg19.knownGene




file_path="/Users/lynn/Downloads/Hushibin/ChIP-seq/07_downstream_analyis/peakannotation"
setwd(file_path)
samples=grep("final.narrowPeak",list.files(),value = T)

for (i in samples){
bedPeaksFile  = i
samplename =gsub(".final.narrowPeak", "",bedPeaksFile)
peak <- readPeakFile( bedPeaksFile )  
keepChr= !grepl('_',seqlevels(peak))
seqlevels(peak, pruning.mode="coarse") <- seqlevels(peak)[keepChr]


options(ChIPseeker.ignore_1st_exon = T)
options(ChIPseeker.ignore_1st_intron = T)
options(ChIPseeker.ignore_downstream = T)
options(ChIPseeker.ignore_promoter_subcategory = T)

peakAnno <- annotatePeak(peak, tssRegion=c(-3000, 3000), 
                         TxDb=txdb, annoDb="org.Hs.eg.db") 
peakAnno_df <- as.data.frame(peakAnno)
genes=unique(peakAnno_df$ENSEMBL)
write.csv(peakAnno_df, paste0(samplename,'_peakAnno_df.csv'))



pdf(paste0("Piechart_210414/",samplename,"_piechart.pdf"),width = 7,height = 4)
plotAnnoPie(peakAnno)
dev.off()
}
