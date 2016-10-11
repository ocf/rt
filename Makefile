DOCKER_TAG ?= rt-dev-$(USER)
VERSION := $(shell date +"%Y-%m-%d-T%H-%M-%S")

.PHONY: cook-image
cook-image:
	docker build -t $(DOCKER_TAG) .

.PHONY: push-image
push-image: DOCKER_TAG := docker-push.ocf.berkeley.edu/rt:$(VERSION)
push-image: cook-image
	docker push $(DOCKER_TAG)

.PHONY: deploy
deploy: push-image
	ocf-marathon deploy-app rt $(VERSION)

.PHONY: start-dev
start-dev: cook-image
	docker run --rm -ti $(DOCKER_TAG)

.PHONY: test
test:
	tox
