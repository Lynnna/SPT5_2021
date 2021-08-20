#!/bin/bash

##align
echo -e "\n***************************\nalign begins at $(date +%Y"-"%m"-"%d" "%H":"%M":"%S)\n***************************"
mkdir $path/02-0_align || true
cd $path/02-0_align
index=~/../Blueberry/reference/index/star/hg19_star_index
mm10index=~/../Blueberry/reference/index/star/mm10_star_index
cat $path/samples | while read i;do
    if [ ! -s $path/02-0_align/${i}_hg19.rmdup.bam ]
    then
    cleanfq1=`ls $path/01-0_cleandata/${i}*R1*gz`;
    cleanfq2=`ls $path/01-0_cleandata/${i}*R2*gz`;
    mkdir -p ${path}/logs/02-0_align/${i}
    STAR --runThreadN 26 --genomeDir $index \
        --readFilesIn $cleanfq1 $cleanfq2 \
        --readFilesCommand  zcat \
        --outSAMtype BAM SortedByCoordinate --twopassMode Basic --outFilterMismatchNmax 2 --outSJfilterReads Unique \
        --quantMode GeneCounts --outFileNamePrefix ${i}_hg19.
    STAR --runThreadN 26 --genomeDir $mm10index \
        --readFilesIn $cleanfq1 $cleanfq2 \
        --readFilesCommand  zcat \
        --outSAMtype BAM SortedByCoordinate --twopassMode Basic --outFilterMismatchNmax 2 --outSJfilterReads Unique \
        --quantMode GeneCounts --outFileNamePrefix ${i}_mm10.

    #echo "$cleanfq1"
    input=`ls $path/02-0_align/${i}_hg19*bam`
    picard MarkDuplicates REMOVE_DUPLICATES=True INPUT=$input output=${i}_hg19.rmdup.bam METRICS_FILE=${i}_hg19.metrics 2>$path/logs/02-0_align/${i}/${i}_hg19.dup.log;
    input=`ls $path/02-0_align/${i}_mm10*bam`
    picard MarkDuplicates REMOVE_DUPLICATES=True INPUT=$input output=${i}_mm10.rmdup.bam METRICS_FILE=${i}_mm10.metrics 2>$path/logs/02-0_align/${i}/${i}_mm10.dup.log;
    samtools index -@ 25 ${i}_hg19.rmdup.bam
    samtools index -@ 25 ${i}_mm10.rmdup.bam
    samtools flagstat ${i}_hg19.rmdup.bam > $path/logs/02-0_align/${i}/${i}_hg19.rmdup.stat
    samtools flagstat ${i}_mm10.rmdup.bam > $path/logs/02-0_align/${i}/${i}_mm10.rmdup.stat
    fi
done




