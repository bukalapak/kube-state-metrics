all: build

FLAGS =
COMMONENVVAR = GOOS=linux GOARCH=amd64
BUILDENVVAR = CGO_ENABLED=0
TESTENVVAR =
REGISTRY = registry.bukalapak.io/sre
NOCACHE = --no-cache
TAG = $(shell git describe --abbrev=0)
VERSION = $(shell git show -q --format=%h)
IMAGE = $(REGISTRY)/kube-state-metrics
BuildDate = $(shell date -u +'%Y-%m-%dT%H:%M:%SZ')
Commit = $(shell git rev-parse --short HEAD)
PKG=k8s.io/kube-state-metrics

TEMP_DIR := $(shell mktemp -d)

deps:
	go get github.com/tools/godep

build: clean deps
	$(COMMONENVVAR) $(BUILDENVVAR) go build -ldflags "-s -w -X ${PKG}/version.Release=${TAG} -X ${PKG}/version.Commit=${Commit} -X ${PKG}/version.BuildDate=${BuildDate}" -o kube-state-metrics

test-unit: clean deps build
	$(COMMONENVVAR) $(TESTENVVAR) godep go test --race . $(FLAGS)

container: build
 	docker build $(NOCACHE) -t $(IMAGE):$(VERSION) $(TEMP_DIR)

push: container
 	docker push $(IMAGE):$(VERSION)

clean:
	rm -f kube-state-metrics

.PHONY: all deps build test-unit container push clean
