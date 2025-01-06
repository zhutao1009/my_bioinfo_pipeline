#!/bin/bash

gatk=/path/to/gatk-4.2.6.1/gatk
ref=/path/to/reference_genome.fna


cd /path/to/raw_data_dir


if [ ! -d /path/to/out_dir/01.gvcf/$1 ]
then
mkdir  /path/to/out_dir/01.gvcf/$1
fi
cd  /path/to/out_dir/01.gvcf/$1



if [ ! -e $1\_clean_1.fq.gz ]
then

fastp -i /path/to/raw_data_dir/$1/$1\_1.fq.gz \
-I /path/to/raw_data_dir/$1/$1\_2.fq.gz \
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
$gatk  --java-options "-Djava.io.tmpdir=/path/to/existing/cache/dir/ "  SortSam -SO coordinate -I $1.bam -O $1\_sort.bam
#mark dupulicates
$gatk  --java-options "-Djava.io.tmpdir=/path/to/existing/cache/dir/ " MarkDuplicates \
-I $1\_sort.bam -O $1\_marked.bam \
-M $1\.metrics 

samtools index  $1\_marked.bam
fi

if [ ! -e $1\_raw.gvcf.gz ]
then
$gatk  --java-options "-Djava.io.tmpdir=/path/to/existing/cache/dir/ " HaplotypeCaller \
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

