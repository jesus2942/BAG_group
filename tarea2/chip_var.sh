#! /bin/bash


if [ $# -ne 1 ]
then
	echo "The number of arguments is: $#"
	echo "Usage: chip.sh <params.file>"
	echo ""
	echo "params.file: Input file with arguments"
	echo "An example of params.file can be found in the test folder"
	exit
fi

#Procesar params
PARAMS=$1

echo ""
echo "=================="
echo "LOADING PARAMETERS"
echo "=================="
echo ""

WD=$(grep working_directory $PARAMS | awk '{print($2)}')
echo "Working directory: $WD"


INSDIR=$(grep installation_directory $PARAMS | awk '{print($2)}')
echo "Installation directory: $INSDIR"


EXP=$(grep experiment_name $PARAMS | awk '{print($2)}')
echo "Experiment name: $EXP"

GENOME=$(grep path_genome $PARAMS | awk '{print($2)}')
echo "Genome path: $GENOME"

ANNOT=$(grep path_annotation $PARAMS | awk '{print($2)}')
echo "Annotation path: $ANNOT"


NUMINPUT=$(grep number_of_inputs $PARAMS | awk '{print($2)}')
echo "Number of inputs: $NUMINPUT"


INPUT_ARRAY=()

for((i=1;i <= $NUMINPUT; i++))
do
	INPUT_ARRAY+=($(grep path_input_$i $PARAMS | awk '{print($2)}'))
	#echo "Input path $i: ${INPUT_ARRAY[$i]}"
done

index_input=1
for element in "${INPUT_ARRAY[@]}"
do
	echo "Input path $index_input: $element"
	index_input=$((index_input + 1))
done

NUMSAM=$(grep number_of_samples $PARAMS | awk '{print($2)}')
echo "Number of samples: $NUMSAM"

SAM_ARRAY=()

for((j=1;j <= $NUMSAM; j++))
do
	SAM_ARRAY+=($(grep path_sample_$j $PARAMS | awk '{print($2)}'))
	#echo "Sample path $j: ${SAM_ARRAY[$j]}"
done

index_sam=1
for element in "${SAM_ARRAY[@]}"
do
        echo "Sample path $index_sam: $element"
        index_sam=$((index_sam + 1))
done

NUMTOTAL=$((NUMINPUT + NUMSAM))
echo "Total number of inputs and samples is $NUMTOTAL"



TF=$(grep transcription_factor $PARAMS | awk '{print($2)}')

if [ $TF == "Y" ]
then
	echo ""
	echo "================================================="
	echo "Running script adjusted for transcription factors"
	echo "================================================="
	echo ""
elif [ $TF == "N" ]
then
	echo ""
	echo "============================================================================="
	echo "Running script adjusted for histone modifications, no HOMER analysis included"
	echo "============================================================================="
	echo ""
else
	echo ""
        echo "=============================================================================="
        echo "Transcription factor / histone modification selection failed; check params.txt"
	echo "BE SURE TO USE ONLY UPPER CASE Y FOR TF OR UPPER CASE N FOR HM"
        echo "=============================================================================="
        echo ""
	exit
fi


#Crear espacio de trabajo
echo ""
echo "=================="
echo "CREATING WORKSPACE"
echo "=================="
echo ""


cd $WD
mkdir $EXP
cd $EXP
mkdir genome annotation results samples
cd samples
mkdir input chip
cd input
for((i=1;i <= $NUMINPUT; i++))
do
	mkdir input_$i
done
cd ..
cd chip
for((i=1;i <= $NUMSAM; i++))
do
	mkdir sample_$i
done 
cd ../..

cp $GENOME genome/genome.fa
cp $ANNOT annotation/annotation.gtf

input_index=1
for element in "${INPUT_ARRAY[@]}"
do
	cp $element samples/input/input_$input_index/input_$input_index.fq.gz
	input_index=$((input_index + 1))
done

sam_index=1
for element in "${SAM_ARRAY[@]}"
do
	cp $element samples/chip/sample_$sam_index/sample_$sam_index.fq.gz
	sam_index=$((sam_index + 1))
done

echo ""
echo "==============="
echo "BUILDING INDEX"
echo "==============="
echo ""

cd genome
bowtie2-build genome.fa index

echo ""
echo "============="
echo "INDEX CREATED"
echo "============="
echo ""

cd ..

for((i=1; i <= $NUMINPUT; i++))
do
	sbatch --job-name=proc_input_$i --output=input_$i.txt --error=err_input_$i.txt $INSDIR/input_proc.sh $WD/$EXP/samples/input/input_$i $i $INSDIR $WD $EXP $NUMTOTAL $NUMINPUT $NUMSAM $TF
done


for((i=1; i <= $NUMSAM; i++))
do
        sbatch --job-name=proc_sam_$i --output=sam_$i.txt --error=err_sam_$i.txt $INSDIR/sample_proc.sh $WD/$EXP/samples/chip/sample_$i $i $INSDIR $WD $EXP $NUMTOTAL $NUMINPUT $NUMSAM $TF
done

