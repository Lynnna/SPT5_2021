####################################################################################################
######################################   ATAC-seq analysis #########################################
####################################################################################################




###Aligning#####
mkdir -p ${align_exp_dir}
mkdir -p ${alignexp_log_dir}


for fq1 in `ls ${trimmedFastq_dir}/*_1.fq.gz`
do 
fq2=${fq1/R1_val_1.fq.gz/R2_val_2.fq.gz}
sample="$(basename ${fq1/_R1_val_1.fq.gz/})"
if [ ! -s ${align_exp_dir}/${sample}.last.bam ]
then
    (bowtie2  -p 25  -t -q -N 1 -L 25 -X 2000 --no-mixed --no-discordant -x  ${GENOME_EXP} -1 $fq1 -2 $fq2 \
    2> ${alignexp_log_dir}/${sample}_align.log) \
    |samtools sort  -O bam  -@ 25 -o - > ${align_exp_dir}/${sample}.raw.bam 
    samtools index ${align_exp_dir}/${sample}.raw.bam 
    bedtools bamtobed -i ${align_exp_dir}/${sample}.raw.bam  > ${align_exp_dir}/${sample}.raw.bed
    samtools flagstat ${align_exp_dir}/${sample}.raw.bam  > ${align_exp_dir}/${sample}.raw.stat
 
    # picard

    picard MarkDuplicates -REMOVE_DUPLICATES True \
        -I ${align_exp_dir}/${sample}.raw.bam \
        -O ${align_exp_dir}/${sample}.rmdup.bam \
        -M ${align_exp_dir}/${sample}.rmdup.metrics
    samtools index   ${align_exp_dir}/${sample}.rmdup.bam 
    
    ## ref:https://www.biostars.org/p/170294/ 
    ## Calculate %mtDNA:
    mtReads=$(samtools idxstats  ${align_exp_dir}/${sample}.rmdup.bam | grep 'chrM' | awk '{SUM += $3} END {print SUM}')
    totalReads=$(samtools idxstats  ${align_exp_dir}/${sample}.rmdup.bam | awk '{SUM += $3} END {print SUM}')
    echo "${sample} ==> mtDNA Content: $(bc <<< "scale=2;100*$mtReads/$totalReads")%" >> ${alignexp_log_dir}/align_mt_genome.log
    
    samtools flagstat  ${align_exp_dir}/${sample}.rmdup.bam > ${align_exp_dir}/${sample}.rmdup.stat

    samtools view  -h  -f 2 -q 10    ${align_exp_dir}/${sample}.rmdup.bam  \
     |grep -v chrM |samtools sort  -O bam  -@ 25 -o - > ${align_exp_dir}/${sample}.last.bam
    
    samtools index   ${align_exp_dir}/${sample}.last.bam 
    samtools flagstat  ${align_exp_dir}/${sample}.last.bam > ${align_exp_dir}/${sample}.last.stat 
    bedtools bamtobed -i ${align_exp_dir}/${sample}.last.bam  > ${align_exp_dir}/${sample}.bed
fi
done 




### Making RPKM-normalized bigWig files ###

mkdir -p ${bw_fulllength_dir}

ls ${align_exp_dir}/*last.bam |while read id;
do
    sample=$(basename ${id%%.*})
    if [ ! -s "${bw_fulllength_dir}/${sample}_rpkm.bw" ]
    then
        bamCoverage -p 22 \
        --normalizeUsing RPKM \
        --binSize 1 \
        -b $id \
        -o ${bw_fulllength_dir}/${sample}_rpkm.bw
    fi
done


      

###call peak
mkdir -p ${peak_dir}
mkdir -p ${peak_log_dir}

ls ${align_exp_dir}/*last.bam |while read id;
do
    sample=$(basename ${id%%.*})
    if [ ! -s ${peak_log_dir}/${sample}_macs2.log ]
    then

    macs2 callpeak -f BAMPE --min-length 100 --keep-dup all --nolambda --bdg -g hs -n ${sample} \
    -t $id --outdir ${peak_dir} 2> ${peak_log_dir}/${sample}_macs2.log
fi
done









