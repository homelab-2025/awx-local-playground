# AWX Setup with AWX Operator

This guide will walk you through setting up AWX, the web-based user interface for Ansible, using the AWX Operator on a Kubernetes cluster.

## Prerequisites

- A working Kubernetes cluster 

(e.g., Minikube, Docker Desktop with Kubeadm ... but not a Kind cluster which require additionnal configuration)
- `kubectl` installed and configured for your cluster
- `git` installed

## Script Overview

This script automates:
- Cloning the AWX Operator repository
- Setting up a namespace for AWX
- Deploying AWX using manifests
- Retrieving admin credentials and NodePort access

## Setup Instructions

### 1. Setting up the Script

1. Clone the repo:

```bash
https://github.com/homelab-2025/awx-local-playground.git
```

2. Set the variables in the script according to your needs

3. Make `awx-setup.sh` executable:

```bash
chmod +x awx-setup.sh
```

### 2. Deploy AWX

To install AWX into your Kubernetes cluster:

```bash
./awx-setup.sh setup-awx
```

This will:
- Clone the AWX Operator repo
- Checkout a specific version (default: 2.7.2)
- Create a Kubernetes namespace called `awx`
- Deploy AWX via Kustomize

### 3. Check Kubernetes Resources

With the following command, you should be able to see first the creation of awx-operator kubernetes ressources, then the creation of awx kubernetes ressources created by the awx-operator.

```bash
./awx-setup.sh watch-k8s
```

### 4. Check AWX Logs

Once awx kubernetes ressources are running, you need follow logs of the AWX operator in order to know where the installation process is at:

```bash
./awx-setup.sh logs-awx
```

### 5. Get AWX Admin Credentials and Access URL

Once the installation process is complete, you can retrieve the AWX admin password and the NodePort access URL with the following command:

```bash
./awx-setup.sh awx-access
```

Then you can connect on awx !
