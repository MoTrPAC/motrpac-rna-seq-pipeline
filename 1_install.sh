# INSTRUCTIONS

# git clone https://github.com/AshleyLab/motrpac-rna-seq-pipeline.git
# git clone -b pipeline_test https://github.com/AshleyLab/motrpac-rna-seq-pipeline.git 
# cd motrpac-rna-seq-pipeline/
# chmod +x 1_install.sh
# ./1_install.sh


mkdir -p ~/mysql_db_rnaseq

#INSTALL JAVA
sudo apt update
sudo apt install default-jre

#INSTALL PYTHON
sudo apt install python3
sudo apt install python3-pip
pip3 install simplejson
pip3 install pandas
pip3 install 'caper==0.6.0'

#INSTALL DOCKER
sudo snap install docker
# run docker without sudo, You should be able to run docker without sudo , [source for fixing can be found in this link](https://techoverflow.net/2017/03/01/solving-docker-permissions)
# Add docker to group
sudo groupadd docker
sudo usermod -a -G docker $USER


#INSTALL CROMWELL; N.B. if this changes, the configs need to change too.
wget https://github.com/broadinstitute/cromwell/releases/download/47/cromwell-47.jar
# wget https://github.com/broadinstitute/cromwell/releases/download/46/cromwell-46.jar

#INSTALL WOMTOOLS
wget https://github.com/broadinstitute/cromwell/releases/download/47/womtool-47.jar