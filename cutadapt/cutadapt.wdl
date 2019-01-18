version 1.0

import "common.wdl" as common_wdl

task Cutadapt {
    input {
        FastqPair inputFastq
        String read1output
        String? read2output
        String? format
        Int cores = 1
        Int memory = 8
        Array[String]+? adapter
        Array[String]+? adapterRead2
        Int? minimumLength # Necessary to prevent creation of empty reads
        String? reportPath
        String? tooShortOutputPath
        String? tooShortPairedOutputPath
    }

    String read2outputArg = if (defined(read2output)) then "mkdir -p $(dirname " + read2output + ")" else ""

    command {
        set -e -o pipefail
        ~{"mkdir -p $(dirname " + read1output + ")"}
        ~{read2outputArg}
        ~{"mkdir -p $(dirname " + reportPath + ")"}
        cutadapt \
        ~{"--cores=" + cores} \
        ~{true="-a" false="" defined(adapter)} ~{sep=" -a " adapter} \
        ~{true="-A" false="" defined(adapterRead2)} ~{sep=" -A " adapterRead2} \
        --output ~{read1output} ~{"--paired-output " + read2output} \
        ~{"--too-short-output " + tooShortOutputPath} \
        ~{"--too-short-paired-output " + tooShortPairedOutputPath} \
        ~{"--minimum-length " + minimumLength} \
        ~{inputFastq.R1} \
        ~{inputFastq.R2} \
        ~{"> " + reportPath}
    }

    output{
        FastqPair cutOutput = object {
          R1: read1output,
          R2: read2output
        }
        File report = if defined(reportPath) then select_first([reportPath]) else stdout()
        File? tooShortOutput=tooShortOutputPath
        File? tooShortPairedOutput=tooShortPairedOutputPath
    }

    runtime {
        cpu: cores
        memory: memory
    }
}
workflow Cutadapt_workflow {
    call Cutadapt
}


