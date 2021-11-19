#!/usr/bin/env bash

# Use WDLTools to lint and check the WDL
curl -LJO https://github.com/dnanexus/wdlTools/releases/download/0.17.4/wdlTools-0.17.4.jar

# Create a new virtual environment
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip setuptools wheel

# Install MiniWDL
pip install miniwdl pylint black
