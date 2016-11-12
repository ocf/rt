DOCKER_TAG ?= rt-dev-$(USER)
VERSION := $(shell date +"%Y-%m-%d-T%H-%M-%S")

.PHONY: cook-image
cook-image:
	docker build --pull -t $(DOCKER_TAG) .

.PHONY: push-image
push-image: cook-image
	docker push $(DOCKER_TAG)

.PHONY: start-dev
start-dev: cook-image
	docker run --rm -ti $(DOCKER_TAG)

.PHONY: test
test:
	tox
