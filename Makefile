export TARGET_DOCKER_REGISTRY=public.ecr.aws/masterpoint
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

## Build and tag our atmos image
build:
	@DOCKER_IMAGE_NAME=$(DOCKER_IMAGE) DOCKER=$(DOCKER) DOCKER_BUILD_FLAGS="--no-cache" make docker/build
	@export VERSION=$(shell git rev-parse --short HEAD); \
		$(DOCKER) tag $(DOCKER_IMAGE_NAME) $(ECR_URI):latest; \
		$(DOCKER) tag $(DOCKER_IMAGE_NAME) $(ECR_URI):$$VERSION; \
		echo "Done building + tagging atmos! Image Tag: $(ECR_URI):$$VERSION";

## Pull our toolbox image from ECR
pull:
	aws ecr get-login-password --region $(REGION) | $(DOCKER) login --username AWS --password-stdin $(ECR_URI); \
	$(DOCKER) pull $(ECR_URI):$(DOCKER_TAG); \
	$(DOCKER) tag $(ECR_URI):$(DOCKER_TAG) $(DOCKER_IMAGE_NAME)

## Publish the toolbox image to our ECR repo
publish:
	@export VERSION=$(shell git rev-parse --short HEAD); \
		make docker/image/push TARGET_VERSION=$$VERSION; \
		make docker/image/push TARGET_VERSION=latest;
