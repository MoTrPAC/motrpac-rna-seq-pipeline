grep "R1" sinai_batch1_filenames.txt |wc -l
split -l 80 sinai_batch1_filenamesR1.txt sinai_batch1
python make_json_rnaseq.py
