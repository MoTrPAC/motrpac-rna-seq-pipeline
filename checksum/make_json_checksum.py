# This script generated input json files for a set of files for computing md5sums
import sys
import os
import simplejson
#Usage : python make_json.py comma_separated_list_of_files path_to_run_folder
#python make_json.py segaa,segab,segac,segad,segae,segaf,segag,segah /Users/archanaraja/work/repo/motrpac-rna-seq-pipeline/checksum/sinai/rrbs/
#filelist=["sinaib1aa","sinaib1ab","sinaib1ac","sinaib1ad","sinaib1ae","sinaib1af","sinaib1ag","sinaib1ah"]
#filelist=["stanford_b1rnaaa","stanford_b1rnaab","stanford_b1rnaac","stanford_b1rnaad","stanford_b1rnaae","stanford_b1rnaaf","stanford_b1rnaag","stanford_b1rnaah","stanford_b1rnaai"]
filelist=sys.argv[1].split(',')
output_path=sys.argv[2]
os.chdir(output_path)
for i in filelist:
#  fn=i+".json"
#  file_path=os.path.join(output_path,fn)
  f=open(i+".json","w")
#  f=open(file_path,"w")
  my_list = [line.strip("\n") for line in open(i)]
  d= {"checksum_workflow.checksum.num_preempt": "0","checksum_workflow.checksum.memory": "20","checksum_workflow.checksum.disk_space": "30","checksum_workflow.checksum.num_threads": "4","checksum_workflow.checksum.docker": "gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19","checksum_workflow.sample_files":my_list}
  simplejson.dump(d, f)
  f.close()

