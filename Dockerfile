# syntax=docker/dockerfile:1
FROM alpine:20231219 as deps

ARG ATMOS_VERSION=1.60.0
ARG TARGETARCH

RUN apk add --no-cache wget && \
    wget -q -O atmos "https://github.com/cloudposse/atmos/releases/download/v${ATMOS_VERSION}/atmos_${ATMOS_VERSION}_linux_${TARGETARCH}"

FROM alpine:20231219 as runner

COPY --from=deps --link atmos /usr/local/bin/atmos

RUN apk upgrade && \
    apk add --no-cache curl=8.6.0-r0 bash=5.2.26-r0 git=2.44.0-r0 openssh=9.6_p1-r0 jq=1.7.1-r0 tailscale=1.58.2-r0 sops=3.8.1-r1 && \
    chmod +x /usr/local/bin/atmos

COPY rootfs/ /

WORKDIR /
