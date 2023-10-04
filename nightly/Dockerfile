################################################################################
# Dockerfile that builds 'yanwk/sd-webui-base:nightly'.
# A runtime environment for AUTOMATIC1111/stable-diffusion-webui.
# With PyTorch2 (nightly), xFormers (dev).
# Also adds dependencies for SD-WebUI DreamBooth Extension.
################################################################################

FROM opensuse/tumbleweed:latest

LABEL maintainer="code@yanwk.fun"

WORKDIR /root

RUN --mount=type=cache,target=/var/cache/zypp \
    set -eu \
    && zypper install --no-confirm \
        python311 python311-pip \
        python311-wheel python311-setuptools python311-numpy \
        shadow git aria2 \
        gperftools-devel libgthread-2_0-0 Mesa-libGL1 \
        fish find mlocate

# Use TCMALLOC from gperftools.
ENV LD_PRELOAD=libtcmalloc.so

# Install PyTorch nightly
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --break-system-packages \
        --pre torch torchvision \
        --index-url https://download.pytorch.org/whl/nightly/cu121 

# Install pre-release xFormers
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --break-system-packages \
        --pre xformers

# All remaining deps are described in txt
COPY ["requirements.txt","/root/"]
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --break-system-packages \
        -r /root/requirements.txt

# Fix for TensorRT
WORKDIR /usr/lib/python3.11/site-packages/tensorrt
RUN ln -s libnvinfer_plugin.so.8 libnvinfer_plugin.so.7 \
    && ln -s libnvinfer.so.8 libnvinfer.so.7
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.11/site-packages/tensorrt"

# Fix for CuDNN
WORKDIR /usr/lib64/python3.11/site-packages/torch/lib
RUN ln -s libnvrtc-b51b459d.so.12 libnvrtc.so 
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib64/python3.11/site-packages/torch/lib"

# Create a low-privilege user.
RUN printf 'CREATE_MAIL_SPOOL=no' > /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts

COPY --chown=runner:runner scripts/. /home/scripts/

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
ENV CLI_ARGS=""
EXPOSE 7860
STOPSIGNAL SIGINT
CMD bash /home/scripts/entrypoint.sh
