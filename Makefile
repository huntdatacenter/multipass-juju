# Run `make` or `make help` command to get help

# Use one shell for all commands in a target recipe
.ONESHELL:
.EXPORT_ALL_VARIABLES:
.PHONY: help list launch mount bootstrap up down ssh destroy bridge

# Set default goal
.DEFAULT_GOAL := help
# Use bash shell in Make instead of sh
SHELL := /bin/bash

# Multipass variables
UBUNTU_VERSION = noble
MOUNT_TARGET = /home/ubuntu/$(DIR_NAME)
DIR_NAME = "$(shell basename $(shell pwd))"
VM_NAME = juju-dev--$(DIR_NAME)

name:  ## Print name of the VM
	echo "$(VM_NAME)"

list:  ## List existing VMs
	multipass list

launch:
	multipass launch $(UBUNTU_VERSION) -v --timeout 3600 --name $(VM_NAME) --memory 4G --cpus 4 --disk 20G --cloud-init juju.yaml \
	&& multipass exec $(VM_NAME) -- cloud-init status

mount:
	echo "# Assure allowed in System settings > Privacy > Full disk access for multipassd"
	multipass mount --type 'classic' --uid-map $(shell id -u):1000 --gid-map $(shell id -g):1000 $(PWD) $(VM_NAME):$(MOUNT_TARGET)

umount:
	multipass umount $(VM_NAME):$(MOUNT_TARGET)

bootstrap:
	$(eval ARCH := $(shell multipass exec $(VM_NAME) -- dpkg --print-architecture))
	multipass exec $(VM_NAME) -- juju bootstrap localhost lxd --bootstrap-constraints arch=$(ARCH) \
	&& multipass exec $(VM_NAME) -- juju add-model default

up: launch mount bootstrap ssh  ## Start a VM

down:  ## Stop the VM
	multipass down $(VM_NAME)

ssh:  ## Connect into the VM
	multipass exec -d $(MOUNT_TARGET) $(VM_NAME) -- bash

port-forward:  ## Forward port from Juju unit: make unit=unit/0 localport=8080 remoteport=8080 port-forward
	$(eval VMIP := $(shell multipass exec $(VM_NAME) -- hostname -I | cut -d' ' -f1))
	echo "Opening browser: http://$(VMIP):$(localport)"
	bash -c "(sleep 1; open 'http://$(VMIP):$(localport)') &"
	echo "Connecting... (Press CTRL+C when you want to stop forwarding)"
	multipass exec $(VM_NAME) -- juju ssh $(unit) -N -L 0.0.0.0:$(localport):0.0.0.0:$(remoteport)

destroy:  ## Destroy the VM
	multipass delete -v --purge $(VM_NAME)

# bridge:
# 	sudo route -nv add -net 192.168.64.0/24 -interface bridge100
# 	# Delete if exists: sudo route -nv delete -net 192.168.64.0/24

# Display target comments in 'make help'
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {sub("\\\\n",sprintf("\n%22c"," "), $$2);printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
