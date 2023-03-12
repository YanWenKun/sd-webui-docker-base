# Stable Diffusion WebUI

[![GitHub Workflow Status](https://github.com/YanWenKun/sd-webui-docker-base/actions/workflows/on-push.yml/badge.svg)](https://github.com/YanWenKun/sd-webui-docker-base/actions/workflows/on-push.yml)

**[READ THE FULL DOCUMENT ON GITHUB](https://github.com/YanWenKun/sd-webui-docker-base/blob/main/README.adoc)**

**[中文文档在 GITHUB 上](https://github.com/YanWenKun/sd-webui-docker-base/blob/main/README.zh.adoc)**

Yet another Docker image for [AUTOMATIC1111/stable-diffusion-webui](https://github.com/AUTOMATIC1111/stable-diffusion-webui), with "easy to update" in mind.

## Features

1. At first start, a script will download latest SD-WebUI, some extensions and essential models.
2. The whole SD-WebUI will be stored in a local folder (`./volume/stable-diffusion-webui`).
3. If you already have a SD-WebUI bundle, put it there so the start script will skip downloading.
4. At every restart of the container, a script will update SD-WebUI & its extensions.

## Usage

Need a NVIDIA GPU with >=6GB VRAM.

```sh
git clone https://github.com/YanWenKun/sd-webui-docker-base.git

cd sd-webui-docker-base

docker compose up --detach

# Update image (only when Python components is outdated)
git pull
docker compose pull
docker compose up --detach --remove-orphans
docker image prune
```

OR using `docker run` :

```sh
mkdir volume

docker run -it \
  --name sd-webui \
  --gpus all \
  -p 7860:7860 \
  -v "$(pwd)"/volume:/home/runner \
  --env CLI_ARGS="--xformers --medvram --allow-code --api --enable-insecure-extension-access" \
  yanwk/sd-webui-base

# Update image (only when Python components is outdated)
docker rm sd-webui
docker pull yanwk/sd-webui-base
# Then run 'docker run' above again
```

Once the app is loaded, visit http://localhost:7860/

## Links

GitHub Repo: 
[YanWenKun/sd-webui-docker-base](https://github.com/YanWenKun/sd-webui-docker-base)

Special Thanks: 
this repo is inspired by 
[AbdBarho/stable-diffusion-webui-docker](https://github.com/AbdBarho/stable-diffusion-webui-docker).
