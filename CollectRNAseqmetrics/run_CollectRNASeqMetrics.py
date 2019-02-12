#!/usr/bin/env python3
# Author: Archana Raja

import argparse
import os
import struct
import subprocess
from datetime import datetime
import contextlib

@contextlib.contextmanager
def cd(cd_path):
    saved_path = os.getcwd()
    os.chdir(cd_path)
    yield
    os.chdir(saved_path)


parser = argparse.ArgumentParser(description='Convert BAM to FASTQ using SamToFastq from Picard.')
parser.add_argument('input_bam', type=str, help='BAM file output by STAR')
parser.add_argument('prefix', type=str, help='Prefix for output files; usually <sample_id>')
parser.add_argument('ref_flat', type=str, help='Gene annotations in refFlat form')
parser.add_argument('-o', '--output_dir', default=os.getcwd(), help='Output directory')
parser.add_argument('-m', '--memory', default='3', type=str, help='Memory, in GB')
#parser.add_argument('--strand', default='FIRST_READ_TRANSCRIPTION_STRAND', type=str , help='For strand-specific library prep. For unpaired reads, use FIRST_READ_TRANSCRIPTION_STRAND,if the reads are expected to be on the transcription strand.  Required. Possible values:{NONE, FIRST_READ_TRANSCRIPTION_STRAND, SECOND_READ_TRANSCRIPTION_STRAND}')
parser.add_argument('--jar', default='/opt/picard-tools/picard.jar', help='Path to Picard jar')
args = parser.parse_args()

print('['+datetime.now().strftime("%b %d %H:%M:%S")+'] Starting CollectRnaSeqMetrics', flush=True)

if not os.path.exists(args.output_dir):
    os.makedirs(args.output_dir)

with cd(args.output_dir):
    subprocess.check_call('java -jar -Xmx'+args.memory+'g '+args.jar\
        +' CollectRnaSeqMetrics I='+args.input_bam\
        +' O='+os.path.split(args.input_bam)[1].replace('.bam', '.RNA_Metrics')\
        +' REF_FLAT='+args.ref_flat \
        +' STRAND=FIRST_READ_TRANSCRIPTION_STRAND',shell=True)

print('['+datetime.now().strftime("%b %d %H:%M:%S")+'] Finished CollectRnaSeqMetrics', flush=True)
