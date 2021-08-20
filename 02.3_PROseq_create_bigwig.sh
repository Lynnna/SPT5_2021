#!/usr/bin/bash


### Making bigWig files with full-length reads adjusted by spike-in ###
mkdir -p ${bw_fulllength_dir}

cat  ${logs_dir}/scalefactor.txt | while read id;
do
arr=($id)
sample=${arr[0]}
scalefactor=${arr[9]}
bam_file=${exp_bam_rmdup}/${sample}_hg19.rmdup.bam
    if [ ! -s "${bw_fulllength_dir}/${sample}_fulllength_rmdup_fwd.bw" ]
    then
        echo "Generating file: ${bw_fulllength_dir}/${sample}_fulllength_rmdup_fwd.bw "
        bamCoverage \
        --bam ${bam_file} \
        --skipNonCoveredRegions \
        --outFileName ${bw_fulllength_dir}/${sample}_fulllength_rmdup_fwd.bw \
        --binSize 1 \
        --scaleFactor  $scalefactor \
        --numberOfProcessors 23 \
        --normalizeUsing None \
        --samFlagInclude 82
    fi
    
    if [ ! -s "${bw_fulllength_dir}/${sample}_fulllength_rmdup_rev_minus.bw" ]
    then
        echo "Generating file: ${bw_fulllength_dir}/${sample}_fulllength_rmdup_rev_minus.bw "
        bamCoverage \
        --bam ${bam_file} \
        --skipNonCoveredRegions \
        --outFileName ${bw_fulllength_dir}/${sample}_fulllength_rmdup_rev_minus.bw \
        --binSize 1 \
        --scaleFactor  -"${scalefactor}" \
        --numberOfProcessors 23 \
        --normalizeUsing None \
        --samFlagInclude 98
    fi
done

wait


### Making bigWig files with single base adjusted by spike-in for forward and reverse strands###
mkdir -p ${bw_singlebase_dir}
cat  ${logs_dir}/scalefactor.txt  | while read id;
do
arr=($id)
sample=${arr[0]}
scalefactor=${arr[9]}
bam_file=${exp_bam_rmdup}/${sample}_hg19.rmdup.bam
    if [ ! -s "${bw_singlebase_dir}/${sample}_singlebase_rmdup_fwd.bw" ]
    then
        echo "Generating file: ${bw_singlebase_dir}/${sample}_singlebase_rmdup_fwd.bw "
        bamCoverage \
        --bam ${bam_file} \
        --skipNonCoveredRegions \
        --outFileName ${bw_singlebase_dir}/${sample}_singlebase_rmdup_fwd.bw \
        --binSize 1 \
        --scaleFactor  $scalefactor \
        --numberOfProcessors 23 \
        --normalizeUsing None \
        --Offset 1 \
        --samFlagInclude 82
    fi
    
    if [ ! -s "${bw_singlebase_dir}/${sample}_singlebase_rmdup_rev_minus.bw" ]
    then
        echo "Generating file: ${bw_singlebase_dir}/${sample}_singlebase_rmdup_rev_minus.bw "
        bamCoverage \
        --bam ${bam_file} \
        --skipNonCoveredRegions \
        --outFileName ${bw_singlebase_dir}/${sample}_singlebase_rmdup_rev_minus.bw \
        --binSize 1 \
        --scaleFactor  -"${scalefactor}" \
        --numberOfProcessors 23 \
        --normalizeUsing None \
        --Offset 1 \
        --samFlagInclude 98
    fi
done





