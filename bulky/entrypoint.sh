#!/bin/bash

set -eu

cd /home/runner

# Install SD-WebUI or update it.
if [ ! -f "/home/runner/stable-diffusion-webui/webui.py" ] ; then
    chmod +x /home/scripts/download.sh
    bash /home/scripts/download.sh
else
    # If update failed, just go on.
    set +e
    chmod +x /home/scripts/update.sh
    bash /home/scripts/update.sh
    set -e
fi ;

echo "########################################"
echo "Starting Stable Diffusion WebUI..."
echo "########################################"

cd /home/runner/stable-diffusion-webui
accelerate launch --num_cpu_threads_per_process=6 webui.py --listen --port 7860 ${CLI_ARGS}
