#Usage : python3 scripts/validate_jsons.py input_json/test3/set3_rnaseq.json input_json/test4/test_batchac_rnaseq.json
import argparse
import json

parser = argparse.ArgumentParser(description='script to compare and validate json files')
parser.add_argument('infile1', type=str, 
                    help='Input json filename')
parser.add_argument('infile2', type=str , help ='Name of the second input json')
args = parser.parse_args()
#json_file1=open("/Users/archanaraja/work/repo/motrpac-rna-seq-pipeline/input_json/test_batchsubset_rnaseq.json")
#json_file2=open("/Users/archanaraja/work/repo/motrpac-rna-seq-pipeline/input_json/test2/set1_rnaseq.json")
json_file1=open(args.infile1)
json_file2=open(args.infile2)
a=json.load(json_file1)
b=json.load(json_file2)
a, b = json.dumps(a, sort_keys=True), json.dumps(b, sort_keys=True)
print ("Validation results")
if (a == b) :
    print ("Two jsons are identical")
elif (a != b) :
   print ("Two jsons don't match") 
