#!/bin/bash

kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
sudo install -m 555 argocd-linux-amd64 /usr/local/bin/argocd
rm argocd-linux-amd64

ENCODED_PASSWORD=$(kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}")
PASSWORD=$(echo $ENCODED_PASSWORD | base64 --decode)

kubectl port-forward svc/argocd-server -n argocd 8080:443 > /dev/null 2>&1 &

argocd login localhost:8080 --username admin --password $PASSWORD --insecure

sudo kubectl config set-context --current --namespace=argocd

kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

kubectl create namespace nginx-ingress
argocd app create nginx-ingress \
  --repo https://github.com/adampfrimmer/homelab_K3s.git \
  --path nginx-ingress/repo\
  --dest-server https://kubernetes.default.svc \
  --dest-namespace nginx-ingress \
  --sync-policy automated 

kubectl create namespace metallb
argocd app create metallb \
  --repo https://github.com/adampfrimmer/homelab_K3s.git \
  --path metallb/repo\
  --dest-server https://kubernetes.default.svc \
  --dest-namespace metallb \
  --sync-policy automated 

ARGOCD_IP=$(kubectl get svc argocd-server -n argocd -o jsonpath='{.status.loadBalancer.ingress[0].ip}')

echo "ARGOCD is deployed at $ARGOCD_IP with admin password: $PASSWORD"































