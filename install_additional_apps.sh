#!/bin/bash


kubectl create namespace gluetun

kubectl create secret generic wireguard -n gluetun \
--from-literal=PIA_USER="" \
--from-literal=PIA_PASS=""


argocd app create gluetun \
  --repo https://github.com/adampfrimmer/homelab_K3s.git \
  --path gluetun-wireguard-qbittorrent/repo\
  --dest-server https://kubernetes.default.svc \
  --dest-namespace gluetun \
  --sync-policy automated 


GLUETUN_IP=$(kubectl get svc gluetun-wireguard-qbittorrent-service -n gluetun -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
log_line=$(kubectl logs -n gluetun $(kubectl get pods -n gluetun -l app=gluetun-wireguard-qbittorrent -o=jsonpath='{.items[0].metadata.name}') -c qbittorrent | grep -o 'A temporary password is provided for this session: [[:alnum:]]*')
password=$(echo "$log_line" | grep -oP 'A temporary password is provided for this session: \K\S+')

echo -e "gluetun-wireguard-qbittorrent is deployed at $GLUETUN_IP:8080 with temporary password: $password \nLogin and change this password under program preferences"




kubectl create namespace unifi

kubectl create secret generic mongo-creds -n unifi \
  --from-literal=username=adminuser \
  --from-literal=password=ksiowkdlf



argocd app create mongodb \
  --repo https://github.com/adampfrimmer/homelab_K3s.git \
  --path unifi-network-application/mongodb \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace unifi \
  --sync-policy automated 


argocd app create unifi \
  --repo https://github.com/adampfrimmer/homelab_K3s.git \
  --path unifi-network-application/unifi \
  --dest-server https://kubernetes.default.svc \
  --dest-namespace unifi \
  --sync-policy automated 

