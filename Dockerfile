################################################################################
# Dockerfile that builds runtime environment 
#   for AUTOMATIC1111/stable-diffusion-webui.
################################################################################

FROM opensuse/tumbleweed:latest

LABEL maintainer="code@yanwk.fun"

WORKDIR /root

RUN --mount=type=cache,target=/var/cache/zypp \
    set -eu \
    && zypper install --no-confirm \
        python311 python311-pip \
        shadow git aria2 \
        gperftools-devel libgthread-2_0-0 Mesa-libGL1 

# Use TCMALLOC from gperftools.
ENV LD_PRELOAD=libtcmalloc.so

# Install PyTorch & xFormers (stable version)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --break-system-packages \
        torch torchvision --index-url https://download.pytorch.org/whl/cu118 \
    && pip install --break-system-packages \
        xformers

# All remaining deps are described in txt
COPY ["requirements.txt","/root/"]
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --break-system-packages \
    -r /root/requirements.txt

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
