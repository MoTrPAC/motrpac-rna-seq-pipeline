grep "R1" sinai_batch1_filenames.txt |wc -l
split -l 80 sinai_batch1_filenamesR1.txt sinai_batch1
python make_json_rnaseq.py


###NOTES
#>>> r1="gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/80000885506_R1.fastq.gz"
#>>> r2=r1.replace("_R1.fastq.gz","_R2.fastq.gz")
#>>> r2
#'gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/80000885506_R2.fastq.gz'
#>>> i1=r1.replace("_R1.fastq.gz","_I1.fastq.gz")
#>>> i1
#'gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/80000885506_I1.fastq.gz'
#>>> a='gs://***REMOVED***-transfer-sinai/rna-seq/PASS1A/90028013001_I1.fastq.gz'
#>>> a.split("/")
#['gs:', '', '***REMOVED***-transfer-sinai', 'rna-seq', 'PASS1A', '90028013001_I1.fastq.gz']
#>>> a.split("/")[-1]
#'90028013001_I1.fastq.gz'
#>>> a.split("/")[-1].split("_I1.fastq.gz")[0]
#'90028013001'
#gs://***REMOVED***/references/rn/v96/star_2.7.0d_04-20-19/sorted/Rnor6_v96_star_index.tar.gz

