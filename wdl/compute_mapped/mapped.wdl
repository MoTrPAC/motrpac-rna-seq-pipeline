version 1.0

task samtools_mapped {
    input {
        File input_bam
        String SID
        Int memory
        Int disk_space
        Int ncpu

        String docker
    }

    command <<<
        set -euo pipefail
        echo "--- $(date "+[%b %d %H:%M:%S]") Beginning task ---"

        echo "--- $(date "+[%b %d %H:%M:%S]") Running samtools view ---"
        samtools view -b -F 0x900 ~{input_bam} -o ~{SID}_aligned_primary.bam

        echo "--- $(date "+[%b %d %H:%M:%S]") Running samtools index ---"
        samtools index ~{SID}_aligned_primary.bam

        echo "--- $(date "+[%b %d %H:%M:%S]") Running samtools idxstats ---"
        samtools idxstats ~{SID}_aligned_primary.bam > ~{SID}_aligned_chr_info.txt

        echo "--- $(date "+[%b %d %H:%M:%S]") Removing ~{SID}_aligned_primary.bam ~{SID}_aligned_primary.bam.bai ---"
        rm ~{SID}_aligned_primary.bam ~{SID}_aligned_primary.bam.bai

        echo "--- $(date "+[%b %d %H:%M:%S]") Extracting reports, info ---"
        Total=$(awk '{sum+=$3}END{print sum}' ~{SID}_aligned_chr_info.txt)
        grep "chrX" ~{SID}_aligned_chr_info.txt|awk -v tot="$Total"  -v name=~{SID} '{print "Sample""\t""pct_chrX""\n"name"\t"($3/tot)*100}' >chrX.txt
        grep "chrY" ~{SID}_aligned_chr_info.txt|awk -v tot="$Total" '{print "pct_chrY""\n"($3/tot)*100}' >chrY.txt
        grep "chrM" ~{SID}_aligned_chr_info.txt|awk -v tot="$Total" '{print "pct_chrM""\n"($3/tot)*100}' >chrM.txt
        grep "chr" ~{SID}_aligned_chr_info.txt|grep -v "chrX\|chrY\|chrM" |awk -v tot="$Total" '{sum+=$3}END{print "pct_chrAuto""\n"(sum/tot)*100}' >chrAuto.txt
        grep -v "chr\|^*" ~{SID}_aligned_chr_info.txt|awk -v tot="$Total" '{sum+=$3}END{print "pct_contig""\n"(sum/tot)*100}' >contig.txt

        echo "--- $(date "+[%b %d %H:%M:%S]") Consolidating intermediate files ---"
        paste chrX.txt chrY.txt chrM.txt chrAuto.txt contig.txt >"~{SID}_mapped_report.txt"

        echo "--- $(date "+[%b %d %H:%M:%S]") Task complete ---"
    >>>

    output {
        File aligned_chrinfo = "${SID}_aligned_chr_info.txt"
        File report = "${SID}_mapped_report.txt"
    }

    runtime {
        docker: "${docker}"
        memory: "${memory}GB"
        disks: "local-disk ${disk_space} HDD"
        cpu: "${ncpu}"

    }

    meta {
        author: "Archana Raja"
    }
}
