# Base image
FROM ghcr.io/scaleoutsystems/tee-gc/fedn:latest

# Env versioning
ARG HADOLINT_VERSION=v2.8.0
ARG DOCKER_VERSION=19.03.9
ARG COMPOSE_VERSION=1.29.2
ARG TORCH_VERSION=1.12.0

# Non-root user with sudo access
ARG USERNAME=default
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Other env
ENV TORCH_DIR=/opt/torch
ENV DATA_DIR=/app/data

# Install apt deps
SHELL ["/bin/bash", "-c"]
RUN apt-get update \
  && apt-get -y install --no-install-recommends \
  apt-utils \
  dialog 2>&1 \
  #
  # More apt deps
  && apt-get install -y --no-install-recommends \
  sudo \
  ca-certificates \
  wget \
  curl \
  git \
  vim \
  openssh-client \
  build-essential \
  autoconf \
  libtool \
  pkg-config \
  googletest \
  libgtest-dev \
  autoconf \
  gawk \
  libcurl4-openssl-dev \
  libprotobuf-c-dev \
  protobuf-c-compiler \
  linux-headers-amd64 \
  unzip \
  bison \
  libmongoc-dev \
  #
  # Hadolint
  && wget --progress=dot:giga -O /bin/hadolint \
  https://github.com/hadolint/hadolint/releases/download/${HADOLINT_VERSION}/hadolint-Linux-x86_64 \
  && chmod +x /bin/hadolint \
  #
  # Install docker binaries
  && curl -L https://download.docker.com/linux/static/stable/x86_64/docker-${DOCKER_VERSION}.tgz | tar xvz docker/docker \
  && cp docker/docker /usr/local/bin \
  && rm -R docker \
  && curl -L https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m) -o /usr/local/bin/docker-compose \
  && chmod +x /usr/local/bin/docker-compose \
  # 
  # Install libtorch
  && mkdir $TORCH_DIR \
  && pushd $TORCH_DIR \
  && wget --progress=dot:giga https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-${TORCH_VERSION}%2Bcpu.zip \
  && unzip libtorch-cxx11-abi-shared-with-deps-${TORCH_VERSION}+cpu.zip \
  && rm -r libtorch-cxx11-abi-shared-with-deps-${TORCH_VERSION}+cpu.zip \
  && popd \
  #
  # Create a non-root user to use if preferred
  && groupadd --gid $USER_GID $USERNAME \
  && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
  && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
  && chmod 0440 /etc/sudoers.d/$USERNAME \
  #
  # Configure FEDn directories
  && mkdir -p /app/certs \
  && mkdir -p /app/client/package \
  && mkdir -p /app/config \
  && chown -R $USERNAME /app \
  #
  # Configure data dir
  && mkdir -p $DATA_DIR \
  && chown $USERNAME $DATA_DIR \
  #
  # Configure for gramine
  && chown -R $USERNAME /opt/gramine \
  #
  # Cleanup
  && apt-get autoremove -y \
  && apt-get clean -y \
  && rm -rf /var/lib/apt/lists/*

# Copy FEDn config
COPY config/*.yaml /app/config/

# Setup default environment
COPY environment.yaml /tmp/environment.yaml
RUN conda env update -f /tmp/environment.yaml \
  && rm /tmp/environment.yaml \
  && conda run -n default python -m ipykernel install --name default \
  && chown $USERNAME /opt/conda/envs/default

# Init conda for non-root user
USER $USERNAME
RUN conda init bash \
  && conda config --set auto_activate_base false \
  && echo "conda activate default" >> ~/.bashrc

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# Add entrypoint to conda environment for commands
ENTRYPOINT ["conda", "run", "--no-capture-output", "-n", "default"]