#!/usr/bin/bash



####filtering rRNA reads#####

mkdir -p ${rmrRNAdata_dir}
mkdir -p ${rmrRNAdata_log_dir}

for fq1 in `ls ${trimmedFastq_dir}/*_1.fq.gz`
do
    fq2=${fq1/R1_val_1.fq.gz/R2_val_2.fq.gz}
    sample=$(basename ${fq1/_R1_val_1.fq.gz/})
    if [ ! -s ${rmrRNAdata_log_dir}/${sample}_rRNA_bowtie.log ]
    then
        echo "Generating file: ${rmrRNAdata_log_dir}/${sample}_rRNA_bowtie.log; "
    bowtie2 \
                --fast-local \
                -x ${RDNA} \
                -1 $fq1 \
                -2 $fq2 \
                --un-conc-gz  ${rmrRNAdata_dir}/${sample}_rmrRNA.fq.gz \
                --threads 25 2> ${rmrRNAdata_log_dir}/${sample}_rRNA_bowtie.log > /dev/null
    fi

done




#####rename rmrRNAdata####
for FILE in ${rmrRNAdata_dir}/*.fq.1.gz
do
    if [ ! -s ${FILE/_rmrRNA.fq.1.gz/_R1.fq.gz} ]
    then
        mv "$FILE" ${FILE/_rmrRNA.fq.1.gz/_R1.fq.gz}
    fi
done

for FILE in ${rmrRNAdata_dir}/*.fq.2.gz
do
    if [ ! -s ${FILE/_rmrRNA.fq.2.gz/_R2.fq.gz} ]
    then
        mv "$FILE" ${FILE/_rmrRNA.fq.2.gz/_R2.fq.gz}
    fi
done






