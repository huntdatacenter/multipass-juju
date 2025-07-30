# Multipass VM with Juju dev environment

inspiration: https://github.com/Abuelodelanada/charm-dev-utils/tree/main/cloud-init

## Requirements

Install Multipass on MAC OS:

```bash
brew install multipass
```

## Usage

Run make command to show help:

```bash
make
```

Expected output:
```
up                   Start VM
down                 Stop VM
ssh                  SSH to VM
destroy              Destroy VM
help                 Show this help
```

Start virtual machine with Juju by running:

```bash
make up
```

Reconnecting later:

```bash
make ssh
```

Destroy the machine when finished:

```bash
make destroy
```

### Mount

Mounting is configured to attach the current directory into VM inside home (e.g. `~/project` if your directory is called `project`).

To be able to mount your project inside the VM on MacOS make sure to allow
System settings > Privacy > `Full disk access` for `multipassd`.

### Integrate

Feel free to integrate into your Juju charm project.

```bash
wget https://raw.githubusercontent.com/huntdatacenter/multipass-juju/main/juju.yaml
wget https://raw.githubusercontent.com/huntdatacenter/multipass-juju/main/Makefile
```
