version 1.0

task Star {
    input {
        String? preCommand

        Array[File] inputR1
        Array[File]? inputR2
        File star_index
        String outFileNamePrefix
        String outFilterType
        String outSAMtype = "BAM SortedByCoordinate"
        String readFilesCommand = "zcat"
        Array[String]? outSAMattributes
        String? outSAMunmapped = "Within KeepPairs"
        Int disk_space
        Int num_preempt
        Int runThreadN
        Int memory
        String quantMode
    }

    # Needs to be extended for all possible output extensions
    Map[String, String] samOutputNames = {"BAM SortedByCoordinate": "sortedByCoord.out.bam"}

    command {
        set -e -o pipefail

        # extract index
        echo $(date +"[%b %d %H:%M:%S] Extracting STAR index")
        mkdir star_index
        tar -xvvf ${star_index} -C star_index --strip-components=1

        mkdir -p ~{sub(outFileNamePrefix, basename(outFileNamePrefix) + "$", "")}
        ~{preCommand}
        STAR \
        --genomeDir star_index
        --readFilesIn ~{sep=' ' inputR1} ~{sep=" " inputR2} \
        --outFileNamePrefix ~{outFileNamePrefix} \
        --outSAMtype ~{outSAMtype} \
        --quantMode ~{quantMode} \
        --readFilesCommand ~{readFilesCommand} \
        ~{"--runThreadN " + runThreadN} \
        ~{"--outFilterType " + outFilterType} \
        ~{true="--outSAMattributes " false="" defined(outSAMattributes)} ~{sep=" " outSAMattributes}
    }

    output {
        File bamFile = outFileNamePrefix + "Aligned." +  samOutputNames[outSAMtype]
        Array[File] output_results= glob('*')
    }
    runtime {
        docker: "gcr.io/broad-cga-francois-gtex/gtex_rnaseq:V8"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${runThreadN}"
        preemptible: "${num_preempt}"
    }
}
