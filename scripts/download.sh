#!/bin/bash

gcs='git clone --depth=1 --no-tags --recurse-submodules --shallow-submodules'

echo "########################################"
echo "Downloading SD-WebUI & components..."
echo "########################################"

set -euxo pipefail

cd /home/runner
$gcs https://github.com/AUTOMATIC1111/stable-diffusion-webui.git

# Download latest dependency repos.
# Another crazy move but still works.
mkdir -p /home/runner/stable-diffusion-webui/repositories
cd /home/runner/stable-diffusion-webui/repositories

$gcs https://github.com/Stability-AI/stablediffusion.git \
    stable-diffusion-stability-ai
$gcs https://github.com/Stability-AI/generative-models.git \
    generative-models
$gcs https://github.com/CompVis/taming-transformers.git \
    taming-transformers
$gcs https://github.com/crowsonkb/k-diffusion.git \
    k-diffusion
$gcs https://github.com/sczhou/CodeFormer.git \
    CodeFormer
$gcs https://github.com/salesforce/BLIP.git \
    BLIP

mkdir -p /home/runner/stable-diffusion-webui/extensions
cd /home/runner/stable-diffusion-webui/extensions

$gcs https://github.com/Mikubill/sd-webui-controlnet.git \
    controlnet
$gcs https://github.com/nonnonstop/sd-webui-3d-open-pose-editor.git \
    3d-open-pose-editor
$gcs https://github.com/AlUlkesh/stable-diffusion-webui-images-browser.git \
    images-browser
$gcs https://github.com/DominikDoom/a1111-sd-webui-tagcomplete.git \
    tag-autocomplete
$gcs https://github.com/toshiaki1729/stable-diffusion-webui-text2prompt.git \
    text2prompt
$gcs https://github.com/dtlnor/stable-diffusion-webui-localization-zh_CN.git \
    localization-zh_CN

cd /home/runner/stable-diffusion-webui
aria2c --allow-overwrite=false --auto-file-renaming=false --continue=true \
    --max-connection-per-server=5 --input-file=/home/scripts/download.txt

touch /home/runner/.sdw-download-complete
