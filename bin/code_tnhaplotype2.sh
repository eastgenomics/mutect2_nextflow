#!/usr/bin/env bash

fastaFile="$1"
fastaIndex="$2"
gatkResource="$3"
bam="$4"
bam_bai="$5"
pathToBin="nextflow-bin"
nameOfSample=${bam%%_*}

#download fasta and index files
dx download ${fastaFile}
dx download ${fastaIndex}

mkdir genome
gunzip hs37d5.fa.gz
mv hs37d5.fa genome
mv hs37d5.fa.fai genome

# prepare GATK resource files
mkdir resources
tar --no-same-owner -zxvf ${gatkResource} -C resources --strip 1

# give permission to run Sentieon
chmod -R 777 ${pathToBin}

# get sentieon license
source ${pathToBin}/license/license_setup.sh
set -eu
export SENTIEON_INSTALL_DIR=${pathToBin}/sentieon-genomics-*
SENTIEON_BIN_DIR=$SENTIEON_INSTALL_DIR/bin
SENTIEON_APP=$SENTIEON_BIN_DIR/sentieon

export LD_PRELOAD=${pathToBin}/sentieon-genomics-202112.07/lib/libjemalloc.so.2
export MALLOC_CONF=metadata_thp:auto,background_thread:true,dirty_decay_ms:30000,muzzy_decay_ms:30000

#generate ignore_decoy bed file
grep -v "hs37d5" "genome/hs37d5.fa.fai"|grep -v "chrEBV"|grep -v "hs38d1"|grep -v "decoy"|awk 'BEGIN{OFS="\t"}{print $1,0,$2}' > ignore_decoy.bed

#tnhaplotyper2

$SENTIEON_APP driver -t 36 -r genome/hs37d5.fa --interval ignore_decoy.bed -i ${bam} --algo QualCal -k resources/1000G_phase1.indels.b37.vcf.gz -k resources/Mills_and_1000G_gold_standard.indels.b37.vcf.gz -k resources/dbsnp_138.b37.vcf.gz tumor_recal_data_Sentieon.table

$SENTIEON_APP driver -t 36 -r genome/hs37d5.fa -i ${bam} -q tumor_recal_data_Sentieon.table --interval ignore_decoy.bed --algo TNhaplotyper2 --tumor_sample ${nameOfSample} tnhaplotyper2.vcf.gz --algo OrientationBias --tumor_sample ${nameOfSample} ORIENTATION_DATA

$SENTIEON_APP driver -r genome/hs37d5.fa --algo TNfilter --tumor_sample ${nameOfSample} -v tnhaplotyper2.vcf.gz --orientation_priors ORIENTATION_DATA tnhaplotyper2.filtered.vcf.gz

mv tnhaplotyper2.filtered.vcf.gz ${nameOfSample}_markdup_recalibrated_tnhaplotyper2.vcf.gz
mv tnhaplotyper2.filtered.vcf.gz.tbi ${nameOfSample}_markdup_recalibrated_tnhaplotyper2.vcf.gz.tbi



