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
        python310 python310-pip \
        shadow git aria2 \
        gperftools-devel libgthread-2_0-0 Mesa-libGL1 

# Use TCMALLOC from gperftools.
ENV LD_PRELOAD=libtcmalloc.so
ENV PIP_PREFER_BINARY=1

# Install latest PyTorch, fine for now.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install torch torchvision \
    && pip install deepspeed triton accelerate \
    && pip install --pre -U xformers \
    && pip install gfpgan realesrgan open-clip-torch opencv-python-headless

# Deps via Git.
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install git+https://github.com/openai/CLIP.git \
    && pip install -r https://github.com/sczhou/CodeFormer/raw/master/requirements.txt

# Deps for A1111.
COPY ["requirements.txt","/root/"]
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r /root/requirements.txt

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
CMD bash /home/scripts/entrypoint.sh
