#!/bin/bash

gatk=/home/zhut/software/gatk-4.2.6.1/gatk
ref=/home/zhut/ref/GCF_019924925.1_HZGC01_genomic.fna


cd /home/zhut/grasscarp_salt/01.gvcf


if [ ! -d /home/zhut/grasscarp_salt/01.gvcf/$1 ]
then
mkdir  /home/zhut/grasscarp_salt/01.gvcf/$1
fi
cd  /home/zhut/grasscarp_salt/01.gvcf/$1



if [ ! -e $1\_clean_1.fq.gz ]
then
# echo /home/zhut/grasscarp_salt/00.data/GDS20050039-3_order_1/$1/$1\_1.fq.gz
fastp -i /home/zhut/grasscarp_salt/00.data/GDS20050039-3_order_1/$1/$1\_1.fq.gz \
-I /home/zhut/grasscarp_salt/00.data/GDS20050039-3_order_1/$1/$1\_2.fq.gz \
-o $1\_clean_1.fq.gz \
-O $1\_clean_2.fq.gz \
-h $1\.html
fi


if [ ! -e  $1.bam ]
then
bwa mem  -t 2 -M -R "@RG\tID:lane1\tPL:illumina\tLB:library\tSM:$1"  $ref $1\_clean_1.fq.gz $1\_clean_2.fq.gz|samtools view -b > $1.bam
fi

if [ ! -e $1\_marked.bam ]
then
$gatk  --java-options "-Djava.io.tmpdir=/home/zhut/.tmp/ "  SortSam -SO coordinate -I $1.bam -O $1\_sort.bam
#mark dupulicates
$gatk  --java-options "-Djava.io.tmpdir=/home/zhut/.tmp/ " MarkDuplicates \
-I $1\_sort.bam -O $1\_marked.bam \
-M $1\.metrics 

samtools index  $1\_marked.bam
fi

if [ ! -e $1\_raw.gvcf.gz ]
then
$gatk  --java-options "-Djava.io.tmpdir=/home/zhut/.tmp/ " HaplotypeCaller \
    --emit-ref-confidence GVCF \
     -R $ref  \
     -I $1\_marked.bam \
      -O $1\_raw.gvcf.gz
fi

if [ -e $1\_raw.gvcf.gz.tbi ]
then
#gzip $sample\_raw.gvcf
rm $1\_clean_1.fq.gz  $1\_clean_2.fq.gz   $1.bam $1\_sort.bam $1\_marked.bam $1\.metrics $1\_marked.bam.bai $1\.html *.json
fi

