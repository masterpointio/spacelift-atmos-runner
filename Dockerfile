ARG VERSION=latest
ARG OS=debian
ARG CLI_NAME=atmos

FROM cloudposse/geodesic:$VERSION-$OS

# Install terraform
ARG TF_1_VERSION=1.2.3
RUN apt-get update && \
    apt-get install -y -u --allow-downgrades terraform-1="${TF_1_VERSION}-*"

# Set Terraform 1.x as the default `terraform` in this container.
# Other versions of TF can be installed + used via Spacelift before_init scripts.
RUN update-alternatives --set terraform /usr/share/terraform/1/bin/terraform

# Install Atmos
RUN apt-get install -y --allow-downgrades atmos

# Shell banner
ENV BANNER="Atmos"

# Set SHELL for `atmos terraform shell`
ENV SHELL=/bin/bash

ENV DOCKER_IMAGE="spacelift-atmos-runner"
ENV DOCKER_TAG="latest"

COPY rootfs/ /

WORKDIR /
