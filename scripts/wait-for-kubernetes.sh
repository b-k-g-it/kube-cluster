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

echo "Waiting for Kubernetes cluster to become available..."

until $(kubectl --kubeconfig="${KUBE_CONFIG}" cluster-info &> /dev/null); do
    sleep 1
done

echo "Kubernetes cluster is up."
