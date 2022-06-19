export TARGET_DOCKER_REGISTRY=public.ecr.aws/w1j9e4y3
export IMAGE_NAME ?= spacelift-atmos-runner
export DOCKER_IMAGE ?= $(IMAGE_NAME)
export ECR_URI ?= $(TARGET_DOCKER_REGISTRY)/$(IMAGE_NAME)
export DOCKER ?= $(shell which docker)
export DOCKER_TAG ?= latest
export DOCKER_IMAGE_NAME ?= $(DOCKER_IMAGE):$(DOCKER_TAG)
export DOCKER_FILE := ./Dockerfile
export REGION ?= us-east-1
export APP_NAME ?= spacelift-atmos-runner
export GEODESIC_INSTALL_PATH ?= /usr/local/bin
export INSTALL_PATH := $(GEODESIC_INSTALL_PATH)
export SCRIPT = $(INSTALL_PATH)/$(APP_NAME)

## This includes the Cloud Posse build-harness (which includes many targets)
-include $(shell curl -sSL -o .build-harness "https://git.io/build-harness"; echo .build-harness)

## Build, install, and run the atmos image
all: build install run

## Build and tag our atmos image
build:
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE) DOCKER=$(DOCKER) DOCKER_BUILD_FLAGS="--no-cache" make docker/build
	@export VERSION=$(shell git rev-parse --short HEAD); \
		$(DOCKER) tag $(DOCKER_IMAGE_NAME) $(ECR_URI):latest; \
		$(DOCKER) tag $(DOCKER_IMAGE_NAME) $(ECR_URI):$$VERSION; \
		echo "Done building + tagging atmos! Image Tag: $(ECR_URI):$$VERSION";


## Install wrapper script from geodesic container
install:
	$(DOCKER) run --rm $(DOCKER_IMAGE) init | bash -s $(DOCKER_IMAGE) || (echo "Try: sudo make install"; exit 1)

## Pull our toolbox image from ECR
pull:
	aws ecr get-login-password --region $(REGION) | $(DOCKER) login --username AWS --password-stdin $(ECR_URI); \
	$(DOCKER) pull $(ECR_URI):$(DOCKER_TAG); \
	$(DOCKER) tag $(ECR_URI):$(DOCKER_TAG) $(DOCKER_IMAGE_NAME)

## Run our toolbox image while also mounting your $HOME folder to `/localhost` in the container
run:
	$(SCRIPT)

## Publish the toolbox image to our ECR repo
publish: build
	@export VERSION=$(shell git rev-parse --short HEAD); \
		make docker/image/push TARGET_VERSION=latest;
