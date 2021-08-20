#!/usr/bin/bash

MAPQ=10

###Aligning to experimental genome#####

mkdir -p  ${align_exp_dir}
mkdir -p  ${alignexp_log_dir}

for PAIR in $(ls ${rmrRNAdata_dir} | sed 's/_R[1-2].*//' | uniq )
do
if [ ! -s "${align_exp_dir}/${PAIR}_hg19.bam" ]
then
    echo "aligning ${PAIR} to experimental genome"
    (bowtie2 \
    --local \
    --sensitive-local \
    --threads 25 \
    -x "$GENOME_EXP" \
    -1 "${rmrRNAdata_dir}/${PAIR}_R1.fq.gz" \
    -2 "${rmrRNAdata_dir}/${PAIR}_R2.fq.gz" \
    2> ${alignexp_log_dir}/${PAIR}_align.log) |
    samtools view -bS -f 2 -q ${MAPQ} |
    samtools sort -@ 20 -o ${align_exp_dir}/${PAIR}_hg19.bam
    samtools index ${align_exp_dir}/${PAIR}_hg19.bam
fi
done


### Aligning to spike-in genome to get normalization factors ###

mkdir -p ${align_spike_dir}
mkdir -p ${alignspike_log_dir}

for PAIR in $(ls ${rmrRNAdata_dir} | sed 's/_R[1-2].*//' | uniq )
do
if [ ! -s "${align_spike_dir}/${PAIR}_onlymm10.bam" ]
    then
    echo "aligning ${PAIR} to spike-in genome"
    (bowtie2 \
    --local \
    --very-sensitive-local \
    --threads 25 \
    --no-unal \
    --no-mixed \
    --no-discordant \
    -x "$GENOME_SPIKE" \
    -1 "${rmrRNAdata_dir}/${PAIR}_R1.fq.gz" \
    -2 "${rmrRNAdata_dir}/${PAIR}_R2.fq.gz" \
    2> ${alignspike_log_dir}/${PAIR}_onlymm10Align.log) |
    samtools view -bS -f 2 -q ${MAPQ} |
    samtools sort -@ 20 -o ${align_spike_dir}/${PAIR}_onlymm10.bam
    samtools index ${align_spike_dir}/${PAIR}_onlymm10.bam
fi
done

