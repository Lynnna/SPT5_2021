#!/bin/bash



# track plus minus
mkdir -p $path/06-1_trackStrand
mkdir -p $path/logs/06-1_trackStrand
for ID in $path/00-0_rawdata/RNA*rep1*;do

    sample=$(basename $ID | sed 's/_rep.*$//g')
    MM10reads=`grep $sample $path/02-1_spikein/scalefactor.txt | cut -f 9 | xargs | awk '{printf ("%.0f\n",($1+$2)/2)}'`
    scalefactor=$(echo "10*1000000/$MM10reads"|bc -l)

    ~/geneapps/miniconda3/envs/chipseq/bin/bamCoverage -b \
    $path/02-2_bamMerge/${sample}.bam --binSize 1 \
    --numberOfProcessors 25 \
    --filterRNAstrand forward \
    -o $path/06-1_trackStrand/${sample}_fwd.bw --scaleFactor $scalefactor 2>$path/logs/06-1_trackStrand/${sample}_fwd.log
    ~/geneapps/miniconda3/envs/chipseq/bin/bamCoverage -b \
    $path/02-2_bamMerge/${sample}.bam --binSize 1 \
    --numberOfProcessors 25 \
    --filterRNAstrand reverse \
    -o $path/06-1_trackStrand/${sample}_rev.bw --scaleFactor -$scalefactor 2>$path/logs/06-1_trackStrand/${sample}_rev.log
done



