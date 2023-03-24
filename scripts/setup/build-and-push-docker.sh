#!/usr/bin/env bash

LATEST_TAG="latest"
GIT_COMMIT_HASH=$(git rev-parse --short HEAD)

TAG=$LATEST_TAG
REGISTRY="us-docker.pkg.dev/motrpac-portal/rnaseq"

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"
RNA_SEQ_DIR="$(cd "$SCRIPT_DIR" && cd ../../ && pwd)"

cd "$RNA_SEQ_DIR" || exit

trap "exit" INT
for DOCKERFILE in dockerfiles/*; do
    FILENAME=$(basename "$DOCKERFILE" .Dockerfile)
    # skip the big dockerfile
    if [ "$FILENAME" == "Dockerfile" ]; then
        continue
    fi
    echo "Building and pushing Docker image: $FILENAME"
    LOCAL_TAG_NAME="motrpac-rna-seq-pipeline/$FILENAME:$TAG"
    # Build the Docker image with the local tag name
    docker build -t "$LOCAL_TAG_NAME" -f "$DOCKERFILE" .
    REMOTE_TAG_NAME="$REGISTRY/$LOCAL_TAG_NAME"
    # Tag the Docker image with the remote tag name
    docker tag "$LOCAL_TAG_NAME" "$REMOTE_TAG_NAME"
    # Push the Docker image to the remote registry
    docker push "$REMOTE_TAG_NAME"
done

