#!/bin/bash

set -eu

echo "########################################"
echo "Updating WebUI..."
echo "########################################"

cd "/home/runner/stable-diffusion-webui" && git pull

echo "########################################"
echo "Updating extensions..."
echo "########################################"

# '&' will run command in background, effectively parallel.
cd "/home/runner/stable-diffusion-webui/extensions" &&
for D in *; do
    if [ -d "${D}" ]; then
        git -C "${D}" pull && echo "Done: ${D}" &
    fi
done
wait $(jobs -p)

echo "Update complete."
exit 0
