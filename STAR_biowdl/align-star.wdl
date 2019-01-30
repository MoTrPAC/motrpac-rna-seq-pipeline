version 1.0

import "star.wdl" as star_task
import "samtools.wdl" as samtools
import "common.wdl" as common

workflow AlignStar {
    input {
        Array[File] inputR1
        Array[File]? inputR2
        String outputDir
        String sample
        String library
        Array[String] readgroups
        String? platform = "illumina"
        File star_index
        String starIndexDir
        String outFilterType
        String outSAMtype = "BAM SortedByCoordinate"
        String readFilesCommand = "zcat"
        Int runThreadN = 10
        Array[String]? outSAMattrRGline
        Array[String] outSAMattributes
        String? outSAMunmapped = "Within KeepPairs"
        Int num_preempt = 25
        Int disk_space = 120
        Int memory = 60
        String quantMode
    }
#Creates custom outSAMattrRGline
#    scatter (rg in readgroups) {
#        String rgLine =
#            '"ID:${rg}" "LB:${library}" "PL:${platform}" "SM:${sample}"'
#    }

    call star_task.Star as star {
        input:
            inputR1 = inputR1,
            inputR2 = inputR2,
            outFileNamePrefix = outputDir + "/" + sample + "-" + library + ".",
            outSAMattributes = outSAMattributes,
            star_index = starIndexDir,
            outFilterType = outFilterType, 
            outSAMtype = outSAMtype,
            readFilesCommand = readFilesCommand,
            runThreadN = runThreadN,
            outSAMunmapped = outSAMunmapped,
            num_preempt = num_preempt,
            disk_space = disk_space,
            memory = memory,
            quantMode = quantMode   

    }

    call samtools.Index as samtoolsIndex {
        input:
            bamFile = star.bamFile,
            # This will only work if star.outSAMtype == "BAM SortedByCoordinate"
            bamIndexPath = outputDir + "/" + sample + "-" + library +
                ".Aligned.sortedByCoord.out.bai"
    }

    output {
        IndexedBamFile bamFile = samtoolsIndex.outputBam
    }

}
