#!/usr/bin/awk -f
#This script attach the I1 file to the R1 or (R2) file
#zcat R1|UMI_attach.awk -v Ifq=file |gzip -c >R1_attach.file
BEGIN{
    FS=OFS=" "
}
NR%4==1{
    rname=$1
    "zcat "Ifq|getline Iline
    Irname=gensub(/ .*$/,"",1,Iline)
    if(Irname!=rname){
	print NR":"rname" is not consistent with ",Irname," in index fastq file\n">"/dev/stderr"
	exit 1
    }
    #read UMI from Ifq
    "zcat "Ifq|getline Iline
    printf rname":"Iline" "#append the UMI to the read name
    printf substr($0,length(rname)+2)"\n"#The residual of rname.
    #working on the next three lines of fastq file
    getline
    print
    getline
    print "+"
    getline
    print
    #Skip the Ifq files for one two more lines, not changing NR variables etc
    "zcat "Ifq|getline Iline
    "zcat "Ifq|getline Iline
}
