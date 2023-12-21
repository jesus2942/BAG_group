#! /bin/bash
#SCRATCH=ALL

INPUTDIR=$1
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
echo "PROCESSING INPUT $i"
echo "===================="
echo ""

cd $INPUTDIR

#Análisis de calidad

echo ""
echo "================"
echo "QUALITY ANALYSIS"
echo "================"
echo ""


fastqc input_$i.fq.gz



echo ""
echo "============"
echo "READ MAPPING"
echo "============"
echo ""

bowtie2 -x ../../../genome/index -U input_$i.fq.gz -S input_$i.sam

samtools sort -o input_$i.bam input_$i.sam
samtools index input_$i.bam



echo ${INPUTDIR}/input_$i.bam.bai >> ../../../results/count_list.txt

NUMPROC=$(wc -l ../../../results/count_list.txt | awk '{print($1)}' )


#Hacer sbatch para peak

if [ $NUMPROC -eq $NUMTOTAL ]
then
        echo "All samples processed"
        cd ../../..
        sbatch --job-name=peak_calling --output=peak_out.txt --error=peak_err.txt $INSDIR/peak_calling.sh $WD/$EXP/results $INSDIR $NUMINPUT $NUMSAM $WD/$EXP/samples/input $TF
fi

