REGION := us-east-1
REGISTRY_ID := 447253099639
PWD := $(shell pwd)
VERSION := $(shell basename ${PWD})
IMAGE_NAME := amqproxy
COMMIT_HASH := $(shell git rev-parse HEAD | cut -c 1-7)
BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
DIFF_SIZE = $(shell cat Dockerfile.diff | wc -l | tr -d '[[:space:]]')

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build:
	docker build -t ${IMAGE_NAME}:${VERSION}--${BRANCH} .

tag:  ## Tag container
	docker tag ${IMAGE_NAME}:${VERSION}--${BRANCH} ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:latest
	docker tag ${IMAGE_NAME}:${VERSION}--${BRANCH} ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${VERSION}--${BRANCH}
	docker tag ${IMAGE_NAME}:${VERSION}--${BRANCH} ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${VERSION}--${BRANCH}--${COMMIT_HASH}

docker-tag:  ## Echos the Docker tag that'd be used for the current build
	@echo ${VERSION}--${BRANCH}--${COMMIT_HASH}

push: tag  ## Push container to wave-prod ECR
	docker push ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:latest
	docker push ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${VERSION}--${BRANCH}
	docker push ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${VERSION}--${BRANCH}--${COMMIT_HASH}

pull:  ## Pull container
	docker pull ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${VERSION}-${BRANCH}

createrepo:  ## Create repo on wave-prod ECR
	aws ecr create-repository --repository-name ${IMAGE_NAME} --profile wave-prod --region=${REGION}

listimages:  ## List pushed images in repo
	aws ecr list-images --profile wave-prod --repository-name ${IMAGE_NAME} --region=${REGION}

import:  ## Output the FROM statement used to start from this container
	@echo "FROM ${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com/${IMAGE_NAME}:${VERSION}--${BRANCH}--${COMMIT_HASH}"

login:  ## Log in to wave-prod registry
	`aws ecr get-login --profile wave-prod --region=us-east-1 --no-include-email`

logout:  ## Log out from the wave-prod registry
	docker logout https://${REGISTRY_ID}.dkr.ecr.us-east-1.amazonaws.com

.PHONY: help build tag push pull createrepo listimages import login logout docker-tag
.DEFAULT_GOAL := help
