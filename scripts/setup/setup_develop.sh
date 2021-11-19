#!/usr/bin/env bash

# Use WDLTools to lint and check the WDL
curl -H 'Accept: application/zip' https://github.com/dnanexus/wdlTools/releases/download/0.17.4/wdlTools-0.17.4.jar -o wdlTools.jar

# Create a new virtual environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel

# Install MiniWDL
pip install miniwdl
