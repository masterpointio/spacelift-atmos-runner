# syntax=docker/dockerfile:1
FROM alpine:3.19 as deps

# Install terraform
ARG TF_1_VERSION=1.5.7 # last release under Mozilla Public License
ARG ALPINE_VERSION=1.52.0
ARG TARGETARCH

RUN apk add --no-cache wget unzip; \
    wget -q "https://releases.hashicorp.com/terraform/${TF_1_VERSION}/terraform_${TF_1_VERSION}_linux_${TARGETARCH}.zip"; \
    wget -q -O atmos "https://github.com/cloudposse/atmos/releases/download/v1.52.0/atmos_1.52.0_linux_${TARGETARCH}"; \
    unzip "terraform_${TF_1_VERSION}_linux_${TARGETARCH}.zip"

FROM alpine:3.19 as runner

RUN apk add --no-cache bash=5.2.21-r0 git=2.43.0-r0 openssh=9.6_p1-r0 jq=1.7.1-r0

COPY --from=deps --link terraform /usr/local/bin/terraform
COPY --from=deps --link atmos /usr/local/bin/atmos

COPY rootfs/ /

WORKDIR /
