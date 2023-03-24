#!/usr/bin/env bash
###############################################################################
# This script builds the Dockerfiles in the dockerfiles/ directory.

# assumes that the dockerfiles/ directory is a sibling of the scripts/ directory, and the script is being run
# from the scripts/ directory
set -eux

cd ../ || (echo "Could not find dockerfiles directory" && exit 1)

# build the other images
for dockerfile in dockerfiles/*.Dockerfile; do
  wo_dir="${dockerfile##*/}"
  edited_fn="${wo_dir%.*}"
  docker push "gcr.io/motrpac-portal/motrpac-rna-seq-pipeline/$edited_fn:latest"
done