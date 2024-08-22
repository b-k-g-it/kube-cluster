#!/bin/bash

KUBE_CONFIG="./kubeconfig/admin.conf"

while [[ $# -gt 0 ]]; do
  case $1 in
    --kubeconfig)
      KUBE_CONFIG="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      shift # past argument
      ;;
  esac
done

dns_host=$(echo $DOCKER_HOST | awk -F'[/:]' '{print $4}')
: ${dns_host:=$(ifconfig docker0 | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*')}

if ! kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system get endpoints kube-dns > /dev/null 2>&1; then
  kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system create -f - << EOF
apiVersion: v1
kind: Endpoints
metadata:
  name: kube-dns
  namespace: kube-system
subsets:
- addresses:
  - ip: $dns_host
  ports:
  - port: 53
    protocol: UDP
    name: dns
EOF
else
  echo "Endpoint 'kube-dns' already exists. Skipping creation."
fi

if ! kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system get service kube-dns > /dev/null 2>&1; then
  kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system create -f - << EOF
kind: Service
apiVersion: v1
metadata:
  name: kube-dns
  namespace: kube-system
spec:
  ports:
  - name: dns
    port: 53
    protocol: UDP
EOF
else
  echo "Service 'kube-dns' already exists. Skipping creation."
fi
