################################################################################
# Dockerfile that builds 'yanwk/sd-webui-base:nightly'.
# A runtime environment for AUTOMATIC1111/stable-diffusion-webui.
# With nightly version of PyTorch2, xFormers.
# Also adds dependencies for SD-WebUI DreamBooth Extension.
################################################################################

FROM nvidia/cuda:11.8.0-cudnn8-devel-ubuntu22.04 AS stage-1

WORKDIR /root

RUN --mount=type=cache,target=/var/cache/apt \
    set -eu \
    && mkdir -p /root/wheels \
    && apt update && apt upgrade -y && apt install -y \
        git python3.10 python3.10-dev python3-pip python-is-python3

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install ninja wheel setuptools numpy \
    && pip install --pre torch torchvision --force-reinstall \
        --index-url https://download.pytorch.org/whl/nightly/cu118 

# Compile xformers
# If only 1 GPU_TARGET, it takes ~5min to build, on a 8-Core (Ryzen 1700) CPU.
# https://github.com/facebookresearch/xformers/blob/main/README.md#install-troubleshooting
# https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
ENV TORCH_CUDA_ARCH_LIST="6.1;7.5;8.0;8.6;8.9"
RUN --mount=type=cache,target=/root/.cache/pip \
    cd /root \
    && git clone --depth=1 --recurse-submodules --shallow-submodules \
        https://github.com/facebookresearch/xformers.git \
    && cd xformers \
    && pip install -r requirements.txt \
    && python setup.py develop \
    && python setup.py bdist_wheel -d /root/wheels


FROM opensuse/tumbleweed:latest AS stage-2

LABEL maintainer="code@yanwk.fun"

WORKDIR /root

RUN --mount=type=cache,target=/var/cache/zypp \
    set -eu \
    && zypper install --no-confirm \
        python310 python310-pip \
        shadow git aria2 \
        gperftools-devel libgthread-2_0-0 Mesa-libGL1 \
        fish find mlocate

# Use TCMALLOC from gperftools.
ENV LD_PRELOAD=libtcmalloc.so

# Install nightly PyTorch (2.1+).
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install wheel setuptools numpy \
    && pip install --pre torch torchvision --force-reinstall \
        --index-url https://download.pytorch.org/whl/nightly/cu118 

# All remaining deps are described in txt
COPY ["requirements.txt","/root/"]
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r /root/requirements.txt

# Fix for TensorRT
WORKDIR /usr/lib/python3.10/site-packages/tensorrt
RUN ln -s libnvinfer_plugin.so.8 libnvinfer_plugin.so.7 \
    && ln -s libnvinfer.so.8 libnvinfer.so.7
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.10/site-packages/tensorrt"

# Fix for CuDNN
WORKDIR /usr/lib64/python3.10/site-packages/torch/lib
RUN ln -s libnvrtc-672ee683.so.11.2 libnvrtc.so 
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib64/python3.10/site-packages/torch/lib"

# Create a low-privilege user.
RUN printf 'CREATE_MAIL_SPOOL=no' > /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts

COPY --chown=runner:runner scripts/. /home/scripts/

# Install xFormers we just built.
# Run it lastly so we can benefit time-saving from parallel build.
COPY --from=stage-1 /root/wheels /tmp/wheels
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install /tmp/wheels/*.whl

# Clean up
RUN rm -rf /tmp/*

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
ENV CLI_ARGS=""
EXPOSE 7860
STOPSIGNAL SIGINT
CMD bash /home/scripts/entrypoint.sh
