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

if ! kubectl --kubeconfig="${KUBE_CONFIG}" get namespace kube-system > /dev/null 2>&1; then
  kubectl --kubeconfig="${KUBE_CONFIG}" create -f - << EOF
kind: Namespace
apiVersion: v1
metadata:
  name: kube-system
  labels:
    name: kube-system
EOF
else
  echo "Namespace 'kube-system' already exists. Skipping creation."
fi
