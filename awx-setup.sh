#!/bin/bash

set -e

# Set variables
REPO_URL="git@github.com:ansible/awx-operator.git"
TAG="2.7.2"  # Change this to the desired tag
NAMESPACE="awx"
AWX_NAME="awx-local"

param=$1

case $param in
	setup-awx)
		echo "[*] Clean up if awx repository already cloned"
		[ -d "awx-operator" ] && rm -rf awx-operator

		echo "[*] Cloning AWX Operator repository..."
		git clone $REPO_URL
		cd awx-operator || exit
		git checkout tags/$TAG

		echo "[*] Setting up namespace..."
		kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -
		kubectl config set-context --current --namespace=$NAMESPACE

		echo "[*] Creating AWX manifests..."
cat <<EOF > kustomization.yml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - github.com/ansible/awx-operator/config/default?ref=$TAG
  - $AWX_NAME.yml
images:
  - name: quay.io/ansible/awx-operator
    newTag: $TAG
namespace: $NAMESPACE
EOF

		cat <<EOF > $AWX_NAME.yml
---
apiVersion: awx.ansible.com/v1beta1
kind: AWX
metadata:
  name: $AWX_NAME
spec:
  service_type: nodeport
EOF

		echo "[*] Applying manifests..."
		kubectl apply -k .
		;;
	deploy-hosts)
		kubectl apply -f deploy-hosts.yaml -n $NAMESPACE
		;;
	watch-k8s)
		watch kubectl get all
		;;
	logs-awx)
		kubectl logs -f deployments/awx-operator-controller-manager -c awx-manager
		;;
	awx-access)
		echo "[*] Retrieving admin password..."
		ADMIN_PASSWORD=$(kubectl get secret ${AWX_NAME}-admin-password -o jsonpath="{.data.password}" | base64 --decode)
		echo "AWX Login: admin"
		echo "AWX Password: $ADMIN_PASSWORD"

		echo "[*] Getting NodePort for AWX..."
		NODE_PORT=$(kubectl get svc -l "app.kubernetes.io/managed-by=awx-operator" -o jsonpath="{.items[?(@.metadata.name=='${AWX_NAME}-service')].spec.ports[0].nodePort}")
		echo "AWX is accessible at: http://localhost:$NODE_PORT/"
		echo "if you want to use add_hosts.py (with uv) execute the following commands:
	export TOWER_HOST=http://localhost:$NODE_PORT/
	awx login -k --conf.host http://localhost:$NODE_PORT/ --conf.username admin --conf.password $ADMIN_PASSWORD -f human
you can then export the token and start the script by typing:
	uv run add_hosts.py"
		;;
	*)
		echo "Usage: $0 {setup-awx|deploy-hosts|watch-k8s|logs-awx|awx-access}"
		exit 1
		;;
esac