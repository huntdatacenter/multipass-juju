## Multipass with Juju dev environment

inspiration: https://github.com/Abuelodelanada/charm-dev-utils/tree/main/cloud-init

Install Multipass on MAC OS:

```
brew install multipass
```

Run make command to show help:

```
$ make

up                   Start VM
down                 Stop VM
ssh                  SSH to VM
destroy              Destroy VM
help                 Show this help
```

Example - start Juju machine run:
```
make up && make ssh
```

### Mount

Mounting is configured to work same as in Vagrant, project directory is mounted into `/vagrant` path.

To be able to mount your project inside the VM on MacOS make sure to allow
System settings > Privacy > `Full disk access` for `multipassd`.


