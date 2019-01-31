 ~/work/tools/subread-1.6.3-MacOSX-x86_64/bin/featureCounts -a Rattus_norvegicus.Rnor_6.0.94_only_transcripts.gtf -o PE_Rnor_FC.out -p -M --fraction PE_Rnor.Aligned.sortedByCoord.out.bam

 java -jar /Users/archanaraja/work/tools/cromwell/cromwell-36.jar run fc.wdl -i fc_inputs.json
