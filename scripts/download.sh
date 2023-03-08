#!/bin/bash

echo "########################################"
echo "Downloading SD-WebUI & components..."
echo "########################################"

set -euxo pipefail

cd /home/runner
git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Download latest dependency repos.
# Another crazy move but still works.
mkdir -p /home/runner/stable-diffusion-webui/repositories
cd /home/runner/stable-diffusion-webui/repositories

git clone https://github.com/Stability-AI/stablediffusion.git \
    stable-diffusion-stability-ai
git clone https://github.com/CompVis/taming-transformers.git \
    taming-transformers
git clone https://github.com/crowsonkb/k-diffusion.git \
    k-diffusion
git clone https://github.com/sczhou/CodeFormer.git \
    CodeFormer
git clone https://github.com/salesforce/BLIP.git \
    BLIP

mkdir -p /home/runner/stable-diffusion-webui/extensions
cd /home/runner/stable-diffusion-webui/extensions

git clone https://github.com/Mikubill/sd-webui-controlnet.git \
    controlnet
git clone https://github.com/hnmr293/posex.git \
    posex
git clone https://github.com/jexom/sd-webui-depth-lib.git \
    depth-lib
git clone https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git \
    images-browser
git clone https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git \
    tag-autocomplete
git clone https://github.com/toshiaki1729/stable-diffusion-webui-text2prompt.git \
    text2prompt
git clone https://github.com/dtlnor/stable-diffusion-webui-localization-zh_CN.git \
    localization-zh_CN

cd /home/runner/stable-diffusion-webui
aria2c --allow-overwrite=false --auto-file-renaming=false --continue=true \
    --max-connection-per-server=5 --input-file=/home/scripts/download.txt
