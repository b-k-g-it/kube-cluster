#!/bin/bash

set -euo pipefail

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Change to the script's directory
cd "$(dirname "$0")"

# Set the path for the kubectl config file
KUBE_CONFIG="./kubeconfig/admin.conf"

# Function to run kubectl with a timeout
kubectl_timeout() {
    timeout 10s kubectl --kubeconfig="${KUBE_CONFIG}" "$@"
}

log "Stopping and removing Docker Compose containers..."
docker-compose down -v --remove-orphans

log "Removing any leftover Kubernetes resources..."
if [ -f "${KUBE_CONFIG}" ]; then
    # Remove finalizers from all namespaces
    for ns in $(kubectl_timeout get namespaces -o jsonpath='{.items[*].metadata.name}'); do
        kubectl_timeout patch namespace $ns -p '{"metadata":{"finalizers":null}}' --type=merge || true
    done

    # Delete all resources forcefully
    kubectl_timeout delete all --all --all-namespaces --force --grace-period=0 || true
    kubectl_timeout delete pv --all --force --grace-period=0 || true
    kubectl_timeout delete pvc --all --all-namespaces --force --grace-period=0 || true
    kubectl_timeout delete configmaps --all --all-namespaces --force --grace-period=0 || true
    kubectl_timeout delete secrets --all --all-namespaces --force --grace-period=0 || true
    kubectl_timeout delete namespaces --all --force --grace-period=0 || true

    # Remove cluster-wide resources
    kubectl_timeout delete clusterroles --all --force --grace-period=0 || true
    kubectl_timeout delete clusterrolebindings --all --force --grace-period=0 || true
fi

log "Removing Docker networks..."
docker network prune -f

log "Removing kubeconfig file..."
rm -f "${KUBE_CONFIG}"

log "Stopping any running kubectl proxy processes..."
pkill -f "kubectl.*proxy" || true

log "Kubernetes cluster has been torn down."

# Final cleanup of any stuck Docker containers
log "Performing final cleanup of Docker containers..."
docker ps -q | xargs -r docker stop
docker ps -aq | xargs -r docker rm -f

log "Cleanup complete."
