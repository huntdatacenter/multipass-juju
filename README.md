# Multipass VM with Juju dev environment

inspiration: https://github.com/Abuelodelanada/charm-dev-utils/tree/main/cloud-init

## Requirements

Install Multipass on MAC OS:

```sh
brew install multipass
```

## Usage

Run make command to show help:

```sh
make
```

Expected output:

```sh
name                 Print name of the VM
list                 List existing VMs
up                   Start a VM
up-k8s               Start a VM with single-node Charmed Kubernetes
down                 Stop the VM
ssh                  Connect into the VM
port-forward         Forward port from Juju unit: make unit=unit/0 localport=8080 remoteport=8080 port-forward
destroy              Destroy the VM
help                 Show this help
```

Start virtual machine with Juju by running:

```sh
make up
```

Reconnecting later:

```sh
make ssh
```

Destroy the machine when finished:

```sh
make destroy
```

VM resources default to 4G memory, 4 CPUs and 20G disk, override them when needed:

```sh
make up MEMORY=8G CPUS=6 DISK=50G
```

### Charmed Kubernetes

To test Kubernetes charms, start the VM with a single-node [Canonical Kubernetes](https://charmhub.io/k8s) cluster managed by Juju:

```sh
make up-k8s
```

This launches the VM with 8G memory and 50G disk, bootstraps the `lxd` controller, then:

- adds the VM itself as a manual machine into the `ck8s` model (Kubernetes cannot run inside LXD containers) and deploys the `k8s` charm on it,
- waits until the node is ready with default storage class `csi-rawfile-default`,
- writes kubeconfig to `~/.kube/config` (use `kubectl` inside the VM),
- registers the cluster as Juju cloud `ck8s` and creates model `k8s-dev` on it.

Deploy your Kubernetes charms into the `k8s-dev` model, which is selected by default:

```sh
juju deploy ./my-charm_ubuntu@24.04-arm64.charm --resource my-image=...
juju status --watch 3s
```

Deployment can take a while, follow it with `juju status -m ck8s` inside the VM.
The script is safe to re-run on an existing VM with `make k8s`, it skips finished steps.

Variables (override like `make up-k8s K8S_CHANNEL=latest/edge`):

- `K8S_CHANNEL` - Channel of the `k8s` charm (Default: `1.36/candidate` - 1.36+ was needed for `ubuntu@26.04`)
- `K8S_CLOUD` - Name of the Kubernetes cloud registered on the controller (Default: `ck8s`)
- `K8S_MODEL` - Model for deploying Kubernetes charms (Default: `k8s-dev`)

Notes:

- Juju 4 does not add your ssh key to new machine models (e.g. `default`), run `juju add-ssh-key "$(cat ~/.local/share/juju/ssh/juju_id_*.pub)"` there before using `juju ssh`. Kubernetes models like `k8s-dev` do not use ssh keys.

### Mount

Mounting is configured to attach the current directory into VM inside home (e.g. `~/project` if your directory is called `project`).

To be able to mount your project inside the VM on MacOS make sure to allow
System settings > Privacy > `Full disk access` for `multipassd`.

### Integrate

Feel free to integrate into your Juju charm project.

```sh
wget https://raw.githubusercontent.com/huntdatacenter/multipass-juju/main/juju.yaml
wget https://raw.githubusercontent.com/huntdatacenter/multipass-juju/main/Makefile
```
