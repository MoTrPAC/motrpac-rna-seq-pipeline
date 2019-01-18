cutadapt -a $INDEXED_ADAPTER_PREFIX -A $UNIVERSAL_ADAPTER -o out1.fastq -p out2.fastq -m 20 /Users/archanaraja/work/repo/RNAseq_v1/test_data/Lung_Powder_S10_R1_001.head.fastq.gz /Users/archanaraja/work/repo/RNAseq_v1/test_data/Lung_Powder_S10_R2_001.head.fastq.gz

java -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run cutadapt.wdl -i cutadapt_inputs.json
