DOCKER_TAG ?= rt-dev-$(USER)

.PHONY: cook-image
cook-image:
	docker build -t $(DOCKER_TAG) .

.PHONY: push-image
push-image: DOCKER_TAG := docker-push.ocf.berkeley.edu/rt:$(shell date +"%Y-%m-%d-T%H-%M-%S")
push-image: cook-image
	docker push $(DOCKER_TAG)

.PHONY: start-dev
start-dev: cook-image
	docker run --rm -ti $(DOCKER_TAG)
