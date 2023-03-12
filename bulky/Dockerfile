################################################################################
# Dockerfile that builds 'yanwk/sd-webui-base:bulky'.
# A runtime environment for AUTOMATIC1111/stable-diffusion-webui.
# With latest PyTorch2, xFormers.
################################################################################

FROM opensuse/leap:15.4

LABEL maintainer="code@yanwk.fun"

WORKDIR /root

# https://gitlab.com/nvidia/container-images/cuda/-/tree/master/dist
RUN --mount=type=cache,target=/var/cache/zypp \
    set -eu \
    && printf "\
[cuda-opensuse15-x86_64]\n\
name=cuda-opensuse15-x86_64\n\
baseurl=https://developer.download.nvidia.com/compute/cuda/repos/opensuse15/x86_64\n\
enabled=1\n\
gpgcheck=1\n\
gpgkey=https://developer.download.nvidia.com/compute/cuda/repos/opensuse15/x86_64/D42D0685.pub\n" \
        > /etc/zypp/repos.d/cuda-opensuse15.repo \
    && zypper --gpg-auto-import-keys \
        install --no-confirm --no-recommends --auto-agree-with-licenses \
            python310 python310-pip \
            git aria2 fish \
            gperftools-devel libgthread-2_0-0 Mesa-libGL1 \
            cuda-cudart-11-8 cuda-compat-11-8 \
            cuda-libraries-11-8 cuda-nvtx-11-8 libnpp-11-8 libcublas-11-8 \
            cuda-libraries-devel-11-8 libnpp-devel-11-8 libcublas-devel-11-8 \
            cuda-cudart-devel-11-8 cuda-minimal-build-11-8 \
            cuda-nvcc-11-8 cuda-nvrtc-devel-11-8 

# Use TCMALLOC from gperftools.
ENV LD_PRELOAD=libtcmalloc.so

# PATH for NVCC
ENV PATH="${PATH}:/usr/local/cuda-11.8/bin"
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/local/cuda-11.8/lib64"

RUN --mount=type=cache,target=/root/.cache/pip \
    pip install ninja wheel setuptools numpy \
    && pip install --pre torch torchvision --force-reinstall \
        --index-url https://download.pytorch.org/whl/nightly/cu118 

# Compile-install xformers
# https://github.com/facebookresearch/xformers/blob/main/README.md#install-troubleshooting
# https://arnon.dk/matching-sm-architectures-arch-and-gencode-for-various-nvidia-cards/
ENV TORCH_CUDA_ARCH_LIST="6.0;6.1;6.2;7.0;7.2;7.5;8.0;8.6"
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -U git+https://github.com/facebookresearch/xformers.git@main#egg=xformers

# All remaining deps are described in txt
COPY ["requirements.txt","/root/"]
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install -r /root/requirements.txt

# Fix for TensorRT
WORKDIR /usr/lib/python3.10/site-packages/tensorrt
RUN ln -s libnvinfer_plugin.so.8 libnvinfer_plugin.so.7 \
    && ln -s libnvinfer.so.8 libnvinfer.so.7
ENV LD_LIBRARY_PATH="${LD_LIBRARY_PATH}:/usr/lib/python3.10/site-packages/tensorrt"

# Create a low-privilege user.
RUN sed -i 's/^CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/' /etc/default/useradd \
    && mkdir -p /home/runner /home/scripts \
    && groupadd runner \
    && useradd runner -g runner -d /home/runner \
    && chown runner:runner /home/runner /home/scripts

COPY --chown=runner:runner ["download.sh","download.txt","entrypoint.sh","update.sh", "/home/scripts/"]

USER runner:runner
VOLUME /home/runner
WORKDIR /home/runner
ENV CLI_ARGS=""
EXPOSE 7860
STOPSIGNAL SIGINT
CMD bash /home/scripts/entrypoint.sh
