export GOBIN=$(CURDIR)/bin
export BINDIR=$(GOBIN)
export PATH:=$(GOBIN):$(PATH)

include .bingo/Variables.mk

export GOROOT=$(shell go env GOROOT)
export GOFLAGS=-mod=vendor
export GO111MODULE=on
export CGO_ENABLED=0
export GOOS=linux
export GOARCH=amd64

SHELL := /bin/bash
OCI_RUNTIME ?= $(shell which podman  || which docker)
MIN_GO_VERSION := 1.18.0
CMD_DIR=./cmd/
KIND_CLUSTER_NAME_EAST ?= east
KIND_CLUSTER_NAME_WEST ?= west

# This is default installation location of skupper.
SKUPPER := ${HOME}/.local/bin/skupper
SUBCTL := ${HOME}/.local/bin/subctl

.DEFAULT_GOAL := help

FORCE: ;

##@ General

# The help target prints out all targets with their descriptions organized
# beneath their categories. The categories are represented by '##@' and the
# target descriptions by '##'. The awk commands is responsible for reading the
# entire set of makefiles included in this invocation, looking for lines of the
# file as xyz: ## something, and then pretty-format the target and help. Then,
# if there's a line with ##@ something, that gets pretty-printed as a category.
# More info on the usage of ANSI control characters for terminal formatting:
# https://en.wikipedia.org/wiki/ANSI_escape_code#SGR_parameters
# More info on the awk command:
# http://linuxcommand.org/lc3_adv_awk.php

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

.PHONY: validate_go
validate_go:
	@current_ver=$$(go version | { read _ _ v _; echo $${v#go}; }); \
	required_ver=${MIN_GO_VERSION}; min_ver=$$(echo -e "$$current_ver\n$$required_ver" | sort -V | head -n 1); \
	if [[ $$min_ver == $$current_ver ]]; then echo -e "\n!!! golang version > $$required_ver required !!!\n"; exit 7;fi

include .mk/utils.mk
include .mk/kind.mk
include .mk/skupper.mk
include .mk/mbg.mk
include .mk/submariner.mk
include .mk/workload.mk
include .mk/observability.mk

##@ Super Commands

.PHONY: clusters-and-workload
clusters-and-workload: prereqs delete-kind-clusters create-kind-clusters deploy-cni deploy-workload ## Deploy clusters, cni, loadbalancers and demo-workload
	@echo -e "\n==> Done (Deploy Kind, CNI, Loadbalancer, workload)\n" 

.PHONY: all-in-one-skupper
<<<<<<< HEAD
all-in-one-skupper: SELECTOR=
all-in-one-skupper: prereqs delete-kind-clusters create-kind-clusters deploy-cni deploy-loadbalancers deploy-workload deploy-skupper deploy-observability ##       Deploy everything with skupper (clusters, cni, loadbalancers, demo-workload, skupper, observability)
	@echo -e "\n==> Done (Deploy everything with skupper)\n" 

.PHONY: all-in-one-skupper-gui
all-in-one-skupper-gui: SELECTOR=app.kubernetes.io/name=skupper-service-controller
all-in-one-skupper-gui: prereqs delete-kind-clusters create-kind-clusters deploy-cni deploy-loadbalancers deploy-workload deploy-skupper deploy-observability ## Deploy everything with skupper with revised GUI
	@echo -e "\n==> Done (Deploy everything with skupper)\n" 

.PHONY: all-in-one-mbg
all-in-one-mbg: SELECTOR=
all-in-one-mbg: prereqs delete-kind-clusters create-kind-clusters deploy-cni deploy-loadbalancers deploy-workload deploy-mbg deploy-observability ##       Deploy everything with mbg (clusters, cni, loadbalancers, demo-workload, mbg, observability)
	@echo -e "\n==> Done (Deploy everything with mbg)\n" 

.PHONY: all-in-one-mbg-gui
all-in-one-mbg-gui: SELECTOR=app=mbg
all-in-one-mbg-gui: prereqs delete-kind-clusters create-kind-clusters deploy-cni deploy-loadbalancers deploy-workload deploy-mbg deploy-observability ##     Deploy everything with mbg with revised GUI
	@echo -e "\n==> Done (Deploy everything with mbg)\n" 

=======
all-in-one-skupper: kind-cni-and-workload deploy-skupper deploy-observability ## Deploy everything with skupper (clusters, cni, loadbalancers, demo-workload, skupper, observability)
	@echo -e "\n==> Done (Deploy everything with skupper)\n" 

.PHONY: all-in-one-submariner
all-in-one-submariner: kind-cni-and-workload deploy-submariner deploy-observability ## Deploy everything with submariner (clusters, cni, loadbalancers, demo-workload, skupper, observability)
	@echo -e "\n==> Done (Deploy everything with submariner)\n" 

.PHONY: all-in-one-mbg
all-in-one-mbg: kind-cni-and-workload deploy-mbg deploy-observability ## Deploy everything with mbg (clusters, cni, loadbalancers, demo-workload, mbg, observability)
	@echo -e "\n==> Done (Deploy everything with mbg)\n" 

##@ clean
.PHONY: clean
clean: delete-kind-clusters ## Delete clusters and clean the setup
	@echo -e "\n==> Done\n"
>>>>>>> 4b9581e (deploy and undeploy support for submariner)
