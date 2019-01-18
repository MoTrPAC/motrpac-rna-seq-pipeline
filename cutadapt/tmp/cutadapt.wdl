version 1.0

import "common.wdl"

task Cutadapt {
    input {
        FastqPair inputFastq
        String read1output
        String? read2output
        String? format
        String? preCommand
        Int cores = 1
        Int memory = 8
        Array[String]+? adapter
        Array[String]+? front
        Array[String]+? anywhere
        Array[String]+? adapterRead2
        Array[String]+? frontRead2
        Array[String]+? anywhereRead2
        Boolean? interleaved
        String? pairFilter
        Float? errorRate
        Boolean? noIndels
        Int? times
        Int? overlap
        Boolean? matchReadWildcards
        Boolean? noMatchAdapterWildcards
        Boolean? noTrim
        Boolean? maskAdapter
        Int? cut
        String? nextseqTrim
        String? qualityCutoff
        Int? qualityBase
        Int? length
        Boolean? trimN
        String? lengthTag
        String? stripSuffix
        String? prefix
        String? suffix
        Int? minimumLength # Necessary to prevent creation of empty reads
        Int? maximumLength
        Int? maxN
        Boolean? discardTrimmed
        Boolean? discardUntrimmed
        String? infoFilePath
        String? restFilePath
        String? wildcardFilePath
        String? tooShortOutputPath
        String? tooLongOutputPath
        String? untrimmedOutputPath
        String? tooShortPairedOutputPath
        String? tooLongPairedOutputPath
        String? untrimmedPairedOutputPath
        Boolean? colorspace
        Boolean? doubleEncode
        Boolean? trimPrimer
        Boolean? stripF3
        Boolean? maq
        Boolean? bwa
        Boolean? zeroCap
        Boolean? noZeroCap
        String? reportPath
    }

    String read2outputArg = if (defined(read2output)) then "mkdir -p $(dirname " + read2output + ")" else ""

    command {
        set -e -o pipefail
        ~{"mkdir -p $(dirname " + read1output + ")"}
        ~{read2outputArg}
        ~{"mkdir -p $(dirname " + reportPath + ")"}
        ~{preCommand}
        cutadapt \
        ~{"--cores=" + cores} \
        ~{true="-a" false="" defined(adapter)} ~{sep=" -a " adapter} \
        ~{true="-A" false="" defined(adapterRead2)} ~{sep=" -A " adapterRead2} \
        ~{true="-g" false="" defined(front)} ~{sep=" -g " front} \
        ~{true="-G" false="" defined(frontRead2)} ~{sep=" -G " frontRead2} \
        ~{true="-b" false="" defined(anywhere)} ~{sep=" -b " anywhere} \
        ~{true="-B" false="" defined(anywhereRead2)} ~{sep=" -B " anywhereRead2} \
        --output ~{read1output} ~{"--paired-output " + read2output} \
        ~{"--too-short-output " + tooShortOutputPath} \
        ~{"--too-short-paired-output " + tooShortPairedOutputPath} \
        ~{"--to-long-output " + tooLongOutputPath} \
        ~{"--to-long-paired-output " + tooLongPairedOutputPath} \
        ~{"--untrimmed-output " + untrimmedOutputPath} \
        ~{"--untrimmed-paired-output " + untrimmedPairedOutputPath} \
        ~{"--pair-filter " + pairFilter} \
        ~{"--error-rate " + errorRate} \
        ~{"--times " + times} \
        ~{"--overlap " + overlap} \
        ~{"--cut " + cut} \
        ~{"--nextseq-trim " + nextseqTrim} \
        ~{"--quality-cutoff " + qualityCutoff} \
        ~{"--quality-base " + qualityBase} \
        ~{"--length " + length} \
        ~{"--length-tag " + lengthTag} \
        ~{"--strip-suffix " + stripSuffix} \
        ~{"--prefix " + prefix} \
        ~{"--suffix " + suffix} \
        ~{"--minimum-length " + minimumLength} \
        ~{"--maximum-length " + maximumLength} \
        ~{"--max-n " + maxN} \
        ~{true="--discard-untrimmed" false="" discardUntrimmed} \
        ~{"--info-file " + infoFilePath } \
        ~{"--rest-file " + restFilePath } \
        ~{"--wildcard-file " + wildcardFilePath} \
        ~{true="--match-read-wildcards" false="" matchReadWildcards} \
        ~{true="--no-match-adapter-wildcards" false="" noMatchAdapterWildcards} \
        ~{true="--no-trim" false="" noTrim} \
        ~{true="--mask-adapter" false="" maskAdapter} \
        ~{true="--no-indels" false="" noIndels} \
        ~{true="--trim-n" false="" trimN}  \
        ~{true="--interleaved" false="" interleaved} \
        ~{true="--discard-trimmed" false="" discardTrimmed } \
        ~{true="--colorspace" false="" colorspace} \
        ~{true="--double-encode" false="" doubleEncode} \
        ~{true="--strip-f3" false="" stripF3} \
        ~{true="--maq" false="" maq} \
        ~{true="--bwa" false="" bwa} \
        ~{true="--zero-cap" false="" zeroCap} \
        ~{true="--no-zero-cap" false="" noZeroCap} \
        ~{inputFastq.R1} \
        ~{inputFastq.R2} \
        ~{"> " + reportPath}
    }

    output{
        FastqPair cutOutput = object {
          R1: read1output,
          R2: read2output
        }
        #File report = if defined(reportPath) then select_first([reportPath]) else stdout()
        #File? tooShortOutput=tooShortOutputPath
        #File? tooShortPairedOutput=tooShortPairedOutputPath
    }

    runtime {
        cpu: cores
        memory: memory
    }
}
workflow Cutadapt_workflow {
    call Cutadapt
}


