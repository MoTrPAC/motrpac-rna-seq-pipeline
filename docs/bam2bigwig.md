# BAM to bigWig conversion

The [bigWig file format](https://genome.ucsc.edu/goldenPath/help/bigWig.html) is a convenient way to view dense, continuous data in a genome browser. Follow these steps to convert BAMs to bigWigs for viewing in a genome browser.

### Dependencies 
- [samtools](http://www.htslib.org/)  
- [deeptools](https://deeptools.readthedocs.io/en/develop/content/installation.html)  

### Usage 
1. Download/locate the BAMs you would like to convert.  
2. For each BAM file, run [bam2bigwig.sh](../scripts/bam2bigwig.sh) as follows: 
```bash
bam=/path/to/${viallabel}.Aligned.sortedByCoord.out.bam
outdir=/path/to/bigwig
bash bam2bigwig.sh ${bam} ${outdir}
```

This will output the bigwig files in `${outdir}`. Each job requires <1G of memory. 
