# Homelab

### Install Docker

```sh
$ curl -fsSL https://get.docker.com -o get-docker.sh
$ sudo sh ./get-docker.sh --dry-run
```

### Install Opentofu

```sh
# Download the installer script and give it execution permissions
$ curl --proto '=https' --tlsv1.2 \
    -fsSL https://get.opentofu.org/install-opentofu.sh \
    -o install-opentofu.sh && \
    chmod +x install-opentofu.sh
# Alternatively: wget --secure-protocol=TLSv1_2 --https-only https://get.opentofu.org/install-opentofu.sh -O install-opentofu.sh

# Run the installer:
$ ./install-opentofu.sh --install-method deb

# Remove the installer:
$ rm -f install-opentofu.sh
```

[See installation documentation](https://opentofu.org/docs/v1.12/intro/install)
