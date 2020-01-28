# 1. Create VM instance & Output bucket
# * Ubuntu; 19.04 (not mimnimal)
# * n1-standard-16 (16 vCPUs, 60 GB memory)
# * 200gb disk
# * Allow HTTP, HTTPS traffic
# * Cloud API access scopes (Allow full access to all Cloud APIs)

gcloud beta compute --project=motrpac-portal instances create ubuntu1904-nopreempt-rnaseq-n1-standard-8 --zone=us-west1-b --machine-type=n1-standard-8 --subnet=default --network-tier=PREMIUM --maintenance-policy=MIGRATE --service-account= --scopes=https://www.googleapis.com/auth/cloud-platform --tags=http-server,https-server --image=ubuntu-1904-disco-v20191113a --image-project=ubuntu-os-cloud --boot-disk-size=200GB --boot-disk-type=pd-standard --boot-disk-device-name=ubuntu1904-nopreempt-rnaseq --labels=pipelines=rna-seq --reservation-affinity=any
#creat output bucket

#make config output based on this bucket