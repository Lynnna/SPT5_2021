#!/bin/bash



#### Quantification
mkdir -p $path/03-0_Quantification
for rmdup_bam in $path/02-0_align/*hg19.rmdup.bam
do
    rmdup_bam_base=$(basename $rmdup_bam)
    Rscript ~/Scripts/RNA-seq/run-featurecounts.R \
        -b ${rmdup_bam} \
        -g ~/Project/reference/annotation/hg19.gencode_chr.gtf \
        -o $path/03-0_Quantification/${rmdup_bam_base/_hg19.rmdup.bam/}_withoutscalefactor
done

mkdir -p $path/03-1_QuanMerge
ls $path/03-0_Quantification/*_withoutscalefactor*count >$path/03-1_QuanMerge/genes.quant_withoutscale_files.txt
cd $path/03-1_QuanMerge
perl ~/Scripts/RNA-seq/abundance_estimates_to_matrix.pl --est_method featureCounts --quant_files $path/03-1_QuanMerge/genes.quant_withoutscale_files.txt --out_prefix genes_withoutscale
cd $path


