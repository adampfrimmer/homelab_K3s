#!/bin/bash
set -e

# Install k3s
echo "Installing K3s from https://get.k3s.io with traefik and servicelb disabled"
curl -sfL https://get.k3s.io | INSTALL_K3S_EXEC="server --disable traefik,servicelb --write-kubeconfig-mode=644" sh -

echo "Copying /etc/rancher/k3s/k3s.yaml to ~/.kube/config"
mkdir -p ~/.kube
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config


echo "Installing helm"
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 ./get_helm.sh
./get_helm.sh
rm ./get_helm.sh

# Set up kubectl completion and aliases
echo "Set up kubectl completion and aliases"
kubectl completion bash >> ~/.bashrc
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc

# Source the updated .bashrc to apply changes in the current shell
echo "Run the following command to apply the changes to .bashrc: source ~/.bashrc"


