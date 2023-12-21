#! /bin/bash
#SCRATCH=ALL

SAMPLEDIR=$1
i=$2
INSDIR=$3
WD=$4
EXP=$5
NUMTOTAL=$6
NUMINPUT=$7
NUMSAM=$8
TF=$9

echo ""
echo "===================="
echo "PROCESSING SAMPLE $i"
echo "===================="
echo ""

cd $SAMPLEDIR

#Análisis de calidad

echo ""
echo "================"
echo "QUALITY ANALYSIS"
echo "================"
echo ""


fastqc sample_$i.fq.gz



echo ""
echo "============"
echo "READ MAPPING"
echo "============"
echo ""

bowtie2 -x ../../../genome/index -U sample_$i.fq.gz -S sample_$i.sam

samtools sort -o sample_$i.bam sample_$i.sam
samtools index sample_$i.bam




echo ${SAMPLEDIR}/sample_$i.bam.bai >> ../../../results/count_list.txt

NUMPROC=$(wc -l ../../../results/count_list.txt | awk '{print($1)}' )


#Hacer sbatch para peak

if [ $NUMPROC -eq $NUMTOTAL ]
then
	echo "All samples processed"
	cd ../../..
	sbatch --job-name=peak_calling --output=peak_out.txt --error=peak_err.txt $INSDIR/peak_calling.sh $WD/$EXP/results $INSDIR $NUMINPUT $NUMSAM $WD/$EXP/samples/input $TF
fi

