#!/bin/bash

set -eu

echo "########################################"
echo "Updating WebUI..."
echo "########################################"

cd "/home/runner/stable-diffusion-webui" && git pull

echo "########################################"
echo "Updating extensions..."
echo "########################################"

cd "/home/runner/stable-diffusion-webui/extensions" &&
for D in *; do
    if [ -d "${D}" ]; then
        echo "${D}" && git pull
    fi
done

echo "Update complete."
exit 0
