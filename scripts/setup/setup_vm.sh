#!/usr/bin/env bash
#Create a VM to run the pipeline and submit jobs
gcloud beta compute --project=my-project instances create ubuntu1904-nopreempt-rnaseq-n1-standard-8 \
  --zone=us-west1-b \
  --machine-type=n1-standard-8 \
  --subnet=default \
  --network-tier=PREMIUM \
  --maintenance-policy=MIGRATE \
  --service-account= \
  --scopes=https://www.googleapis.com/auth/cloud-platform \
  --tags=http-server,https-server \
  --image=ubuntu-1904-disco-v20191113a \
  --image-project=ubuntu-os-cloud \
  --boot-disk-size=200GB \
  --boot-disk-type=pd-standard \
  --boot-disk-device-name=ubuntu1904-nopreempt-rnaseq \
  --labels=pipelines=rna-seq \
  --reservation-affinity=any

gcloud beta ssh --zone=us-west1-b ubuntu1904-nopreempt-rnaseq-n1-standard-8 --project=my-project
#INSTALL DOCKER
sudo snap install docker

#INSTALL JAVA
sudo apt install default-jre

#INSTALL caper 0.6.0
pip3 install caper

# run docker without sudo, You should be able to run docker without sudo , [source for fixing can be found in this link](https://techoverflow.net/2017/03/01/solving-docker-permissions)
# Add docker to group
sudo groupadd docker
sudo usermod -a -G docker "$USER"
#shutdown and restart the instance after doing the above
docker run --rm hello-world
#Above command should work successfully without any permission denied errors.

#INSTALL CROMWELL
wget https://github.com/broadinstitute/cromwell/releases/download/42/cromwell-42.jar

#INSTALL WOMTOOLS
wget https://github.com/broadinstitute/cromwell/releases/download/42/womtool-42.jar

#CLONE PIPELINE REPO
git clone -b pipeline_test https://github.com/AshleyLab/motrpac-rna-seq-pipeline.git

#Install Python
sudo apt-get install -y python3-pip

#Install simplejson
pip3 install simplejson

#Install Pandas
pip3 install pandas

#Install gcsfs
pip3 install gcsfs
