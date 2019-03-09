# UBUNTU:18.04 chosen since currently stable and will be on LTS 
FROM ubuntu:18.04

# Steps to hopefully force apt-get update to work
RUN apt-get clean && \
  mv /var/lib/apt/lists /tmp && \
  mkdir -p /var/lib/apt/lists/partial && \
  apt-get clean && \
  apt-get update

# Install essential packages
RUN apt-get install  -y build-essential zlib1g-dev libncurses5-dev libncursesw5-dev wget unzip python-pip python-dev

# Install python3 and pip3
RUN apt-get install -y python3-dev python3-pip


# Install essential packages for building picard tools
RUN export DEBIAN_FRONTEND=noninteractive && \
  apt-get update && \
  apt-get --no-install-recommends install -y \
  git r-base ant && \
  apt-get clean autoclean && \
  apt-get autoremove -y

# Install gawk to make awk scripts able to use gensub command
RUN apt-get -y install gawk

# Install procps (to get free and top)
RUN apt-get install -y procps

# Install openjdk-8
RUN apt-get -y install openjdk-8-jdk openjdk-8-jre

# Directory to install
RUN mkdir /src

# Cloning and checking out Picard Tools-2.18.16
RUN cd /src && \
    #wget https://github.com/broadinstitute/picard/archive/2.18.16.tar.gz
    git clone https://github.com/broadinstitute/picard.git && \
    cd picard && \
    git checkout 51d3df7e22a2beb6d046eaf92e74b1521f4d2031 .


# Installing Picard Tools
RUN cd /src && \
    cd picard && \
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64 && \
    export PATH=$PATH:$HOME/bin:$JAVA_HOME/bin && \
    ./gradlew shadowJar && \
    mv build/libs/picard.jar picard.jar && \
    mv src/main/resources/picard/docker_helper.sh docker_helper.sh && \
    ./gradlew clean && \
    rm -rf src && \
    rm -rf gradle && \
    rm -rf .git && \
    rm gradlew && \
    rm build.gradle

# Install samtools-1.3.1
RUN cd /src && \
    wget https://github.com/samtools/samtools/releases/download/1.3.1/samtools-1.3.1.tar.bz2 && \
    tar -vxjf samtools-1.3.1.tar.bz2 && \
    rm samtools-1.3.1.tar.bz2 && \
    cd samtools-1.3.1 && \
    make && \
    ln -s /src/samtools-1.3.1/samtools /usr/local/bin

# Download and checkout RSEM-1.3.1
RUN cd /src && \
  git clone https://github.com/deweylab/RSEM && \
  cd RSEM && \
  git checkout 08c0340d7c867695ebb044f4a3b18e9deb84346d .

# Install RSEM
RUN cd /src/RSEM && \
    make
# Make RSEM commands available
RUN cd /src/RSEM && \
  ln -s /src/RSEM/rsem-* /usr/local/bin

# Install FastQC-0.11.8 
RUN cd /src && \
    wget https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc_v0.11.8.zip && \
    unzip fastqc_v0.11.8.zip && \
    rm fastqc_v0.11.8.zip && \
    chmod 755 FastQC/fastqc && \
    ln -s /src/FastQC/fastqc /usr/local/bin

# Install multiQC-1.6
RUN pip install multiQC==1.6

# Install bowtie2
RUN cd /src && \
	wget -O bowtie2.zip https://sourceforge.net/projects/bowtie-bio/files/bowtie2/2.3.4.3/bowtie2-2.3.4.3-linux-x86_64.zip/download && \
	unzip bowtie2.zip && \
  rm bowtie2.zip && \
	ln -s /src/bowtie2-2.3.4.3-linux-x86_64/bowtie2* /usr/local/bin

# Install subread-1.6.3 (Only links featureCounts)
RUN cd /src && \
    wget -O subread.tar.gz https://sourceforge.net/projects/subread/files/subread-1.6.3/subread-1.6.3-Linux-x86_64.tar.gz/download && \
    tar -zxvf subread.tar.gz && \
    rm subread.tar.gz && \
    cd subread-1.6.3*/bin && \
    ln -s /src/subread-*/bin/fe* /usr/local/bin

# Install STAR-2.7.0d , changed the star version from 2.6.1b 
RUN cd /src && \
    wget -O star.tar.gz https://github.com/alexdobin/STAR/archive/2.7.0d.tar.gz && \
    tar -zxvf star.tar.gz && \
    rm star.tar.gz && \
    cd STAR-*/source && \
    make && \
    ln -s /src/STAR-2.7.0d/bin/Linux_x86_64/* /usr/local/bin
    
# Install ucsc-gtftogenepred
RUN cd /src && \
  wget https://github.com/adamlabadorf/ucsc_tools/raw/master/executables/gtfToGenePred && \
  chmod 755 gtfToGenePred && \
  ln -s /src/gtfToGenePred /usr/local/bin

# Install motrpac UMI_attach script
RUN cd /src && \
    wget https://raw.githubusercontent.com/yongchao/motrpac_rnaseq/0071959641549d093c1ce669c903372ecd7c9d0d/bin/UMI_attach.awk && \
    chmod 755 UMI_attach.awk && \
    ln -s /src/UMI_attach.awk /usr/local/bin

# Download nudup.py from January 2018
RUN cd /src && \
    wget https://raw.githubusercontent.com/nugentechnologies/nudup/555756bbbdc5c83c4d4b00cda9f51758393583ca/nudup.py && \
    chmod 755 /src/nudup.py && \
    ln -s /src/nudup.py /usr/local/bin

# Install cutadapt-1.18
RUN pip3 install cutadapt==1.18
