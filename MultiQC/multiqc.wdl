version 1.0

task MultiQC {
    input {
        File analysisDirectory
        Boolean force
        Boolean dirs
        String? fileName
        String outDir
    }

    command {
        set -e -o pipefail
        mkdir -p ~{outDir}
        multiqc \
        ~{true="--force" false="" force} \
        ~{true="--dirs" false="" dirs} \
        ~{"--filename " + fileName} \
        ~{"--outdir " + outDir} \
        ~{analysisDirectory}
    }

    String reportFilename = if (defined(fileName)) then sub(select_first([fileName]), "\.html$", "") else "multiqc"
    output {
        File multiqcReport = outDir + "/" + reportFilename + ".html"
        File multiqcDataDir = outDir + "/" + reportFilename + "_data"
    }
}

workflow MultiQC_workflow {
    call MultiQC
}
