version 1.0
# make sure fastqc is runnable through docker , right now unsuccessful , add an array of files instead of just file
task Fastqc {
    input {
        File seqFile
        String outdirPath
        String? preCommand
        String? format
        Int threads
        Boolean? extract
        File? contaminants
        File? adapters
        File? limits
        Int? kmers
        String? dir
    }

    # Chops of the .gz extension if present.
    String name = basename(sub(seqFile, "\.gz$","")) # The Basename needs to be taken here. Otherwise paths might differ between similar jobs.
    # This regex chops of the extension and replaces it with _fastqc for the reportdir.
    # Just as fastqc does it.
    String reportDir = outdirPath + "/" + sub(name, "\.[^\.]*$", "_fastqc")

    command {
        set -e -o pipefail
        ~{preCommand}
        mkdir -p ~{outdirPath}
        /Users/archanaraja/work/tools/FastQC/fastqc \
        ~{"--outdir " + outdirPath} \
        ~{true="--extract" false="" extract} \
        ~{"--format " + format} \
        ~{"--threads " + threads} \
        ~{"--contaminants " + contaminants} \
        ~{"--adapters " + adapters} \
        ~{"--limits " + limits} \
        ~{"--kmers " + kmers} \
        ~{"--dir " + dir} \
        ~{seqFile}
    }

    # uncomment output files below to add more outputs for uncompressed
    output {
        File htmlReport = reportDir + ".html"
       # File rawReport = reportDir + "/fastqc_data.txt"
       # File summary = reportDir + "/summary.txt"
       # Array[File] images = glob(reportDir + "/Images/*.png")
    }

    runtime {
        cpu: threads
    }
}

#do we need this?
task GetConfiguration {
    input {
        String? preCommand
        String fastqcDirFile = "fastqcDir.txt"
    }

    command {
        set -e -o pipefail
        ~{preCommand}
        echo $(dirname $(readlink -f $(which fastqc))) > ~{fastqcDirFile}
    }

    output {
        String fastqcDir = read_string(fastqcDirFile)
        File adapterList = fastqcDir + "/Configuration/adapter_list.txt"
        File contaminantList = fastqcDir + "/Configuration/contaminant_list.txt"
        File limits = fastqcDir + "/Configuration/limits.txt"
    }

    runtime {
        memory: 1
    }
}
workflow FastQC_workflow {
    call Fastqc
}
