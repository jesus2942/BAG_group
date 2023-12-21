#! /bin/bash
#SCRATCH=ALL

RESDIR=$1
INSDIR=$2
NUMINPUT=$3
NUMSAM=$4
INPUTDIR=$5
TF=$6

if [ $NUMINPUT -ge 2 ]
then
	echo ""
	echo "=============="
	echo "MERGING INPUTS"
	echo "=============="
	echo ""

	cd $INPUTDIR
	input_files=()
	for ((i=1; i <= $NUMINPUT; i++))
	do
		input_files+=" input_$i/input_$i.bam"
	done
	samtools merge input_merge.bam $input_files
fi



echo ""
echo "============"
echo "PEAK CALLING"
echo "============"
echo ""

cd $RESDIR

if [ $NUMINPUT -ge 2 ]
then
	if [ $TF == "Y" ]
	then
		for((i=1; i <= $NUMSAM; i++))
		do
			macs2 callpeak -t ../samples/chip/sample_$i/sample_$i.bam -c ../samples/input/input_merge.bam -f BAM --outdir . -n prr5_$i
		done
	elif [ $TF == "N" ]
	then
		for((i=1; i <= $NUMSAM; i++))
                do
                        macs2 callpeak -t ../samples/chip/sample_$i/sample_$i.bam -c ../samples/input/input_merge.bam -f BAM --outdir . -n prr5_$i --broad
                done
	fi
else
	if [ $TF == "Y" ]
	then
		for((i=1; i <= $NUMSAM; i++))
        	do
                	macs2 callpeak -t ../samples/chip/sample_$i/sample_$i.bam -c ../samples/input/input_1/input_1.bam -f BAM --outdir . -n prr5_$i
        	done
	elif [ $TF == "N" ]
	then
		for((i=1; i <= $NUMSAM; i++))
                do
                        macs2 callpeak -t ../samples/chip/sample_$i/sample_$i.bam -c ../samples/input/input_1/input_1.bam -f BAM --outdir . -n prr5_$i --broad
                done
	fi
fi



#Intersect

if [ $NUMSAM -ge 2 ]
then
	echo ""
	echo "==============================="
	echo "PERFORMING INTERSECT OF SAMPLES"
	echo "==============================="
	echo ""

	if [ $TF == "Y" ]
	then
		bedtools intersect -a prr5_1_peaks.narrowPeak -b prr5_2_peaks.narrowPeak > intersected.narrowPeak
		if [ $NUMSAM -gt 2 ]
		then
			for((i=1; i <= $NUMSAM; i++))
			do
				bedtools intersect -a intersected.narrowPeak -b prr5_${i+2}_peaks.narrowPeak > temp_intersected.narrowPeak
				mv temp_intersected.narrowPeak intersected.narrowPeak
			done
		fi
	elif [ $TF == "N" ]
	then
		bedtools intersect -a prr5_1_peaks.broadPeak -b prr5_2_peaks.broadPeak > intersected.broadPeak
                if [ $NUMSAM -gt 2 ]
                then
                        for((i=1; i <= $NUMSAM; i++))
                        do
                                bedtools intersect -a intersected.broadPeak -b prr5_${i+2}_peaks.broadPeak > temp_intersected.broadPeak
                                mv temp_intersected.broadPeak intersected.broadPeak
                        done
                fi
	fi
fi


if [ $TF == "Y" ]
then
	if [ $NUMSAM -eq 1 ]
	then
		mv prr5_1_peaks.narrowPeak working_file.narrowPeak
	else
		mv intersected.narrowPeak working_file.narrowPeak
	fi
elif [ $TF == "N" ]
then
	if [ $NUMSAM -eq 1 ]
        then
                mv prr5_1_peaks.broadPeak working_file.broadPeak
        else
                mv intersected.broadPeak working_file.broadPeak
        fi

fi


#Hacer sbatch para R

Rscript $INSDIR/chip.R $RESDIR $INSDIR $TF



if [ $TF == "Y" ]
then
	echo ""
	echo "====="
	echo "HOMER"
	echo "====="
	echo ""
	findMotifsGenome.pl working_file.narrowPeak tair10 dnaMotifs -size 100 -len 8
fi
