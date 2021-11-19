"""
Usage:
python3 scripts/validate_jsons.py input_json/test3/set3_rnaseq.json
            input_json/test4/test_batchac_rnaseq.json
"""
import argparse
import json


def main():
    parser = argparse.ArgumentParser(description="script to compare and validate json files")
    parser.add_argument("infile1", type=str, help="Input json filename")
    parser.add_argument("infile2", type=str, help="Name of the second input json")
    args = parser.parse_args()

    with open(args.infile1, encoding="utf-8") as json_file1:
        file_a = json.load(json_file1)

    with open(args.infile1, encoding="utf-8") as json_file2:
        file_b = json.load(json_file2)

    a, b = json.dumps(file_a, sort_keys=True), json.dumps(file_b, sort_keys=True)

    print("Validation results")
    if a == b:
        print("Two jsons are identical")
    elif a != b:
        print("Two jsons don't match")


if __name__ == "__main__":
    main()
