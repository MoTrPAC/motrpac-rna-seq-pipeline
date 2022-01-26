"""
This script generated input json files for a set of files for computing md5sums

Usage : python make_json.py comma_separated_list_of_files path_to_run_folder
"""
import sys
import os
import simplejson


def main():
    filelist = sys.argv[1].split(",")
    output_path = sys.argv[2]
    os.chdir(output_path)
    for filename in filelist:
        with open(f"{filename}.json", "w", encoding="utf-8") as file:
            my_list = [line.strip("\n") for line in file]

        json_d = {
            "checksum_workflow.checksum.memory": "20",
            "checksum_workflow.checksum.disk_space": "30",
            "checksum_workflow.checksum.ncpu": "4",
            "checksum_workflow.checksum.docker": "gcr.io/***REMOVED***/motrpac_rnaseq:v0.1_04_20_19",
            "checksum_workflow.sample_files": my_list,
        }

        with open(f"{filename}.json", "w", encoding="utf-8") as outfile:
            simplejson.dump(json_d, outfile)


if __name__ == "__main__":
    main()
