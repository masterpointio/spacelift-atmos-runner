# syntax=docker/dockerfile:1
FROM alpine:3.19 as deps

# Install terraform
ARG ATMOS_VERSION=1.60.0
ARG TARGETARCH

RUN apk add --no-cache wget && \
    wget -q -O atmos "https://github.com/cloudposse/atmos/releases/download/v${ATMOS_VERSION}/atmos_${ATMOS_VERSION}_linux_${TARGETARCH}"

FROM alpine:3.19 as runner

COPY --from=deps --link atmos /usr/local/bin/atmos

RUN apk add --no-cache curl=8.5.0-r0 bash=5.2.21-r0 git=2.43.0-r0 openssh=9.6_p1-r0 jq=1.7.1-r0 \
    && chmod +x /usr/local/bin/atmos

COPY rootfs/ /

WORKDIR /
