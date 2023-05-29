DOCKER_REVISION ?= testing-$(USER)
DOCKER_TAG = docker-push.ocf.berkeley.edu/rt:$(DOCKER_REVISION)
RANDOM_PORT := $(shell expr $$(( 8000 + (`id -u` % 1000) + 1 )))

.PHONY: cook-image
cook-image:
	docker build --pull -t $(DOCKER_TAG) .

.PHONY: push-image
push-image: cook-image
	docker push $(DOCKER_TAG)

.PHONY: start-dev
start-dev: cook-image
	@echo "Will be accessible at http://$(shell hostname -f ):$(RANDOM_PORT)/"
	docker run --rm \
		-v "$(PWD)/secrets:/opt/share/secrets/rt:ro" \
		-p "$(RANDOM_PORT):80" \
		-e SERVER_NAME=$(shell hostname -f) \
		$(DOCKER_TAG)

.PHONY: test
test:
	@perl -c 99-ocf.pm
