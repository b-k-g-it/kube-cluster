#!/bin/bash

# Set variables
KUBE_API_SERVER="https://localhost:6443"
KUBE_CONFIG_PATH="./kubeconfig/admin.conf"
STATIC_TOKEN="admin"

# Create kubeconfig
kubectl config set-cluster kubernetes --server=${KUBE_API_SERVER} --insecure-skip-tls-verify=true --kubeconfig=${KUBE_CONFIG_PATH}
kubectl config set-credentials admin --token=${STATIC_TOKEN} --kubeconfig=${KUBE_CONFIG_PATH}
kubectl config set-context kubernetes --cluster=kubernetes --user=admin --kubeconfig=${KUBE_CONFIG_PATH}
kubectl config use-context kubernetes --kubeconfig=${KUBE_CONFIG_PATH}

echo "Kubeconfig file created at ${KUBE_CONFIG_PATH}"

