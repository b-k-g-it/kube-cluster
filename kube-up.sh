#!/bin/bash

set -euo pipefail

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
}

# Change to the script's directory
cd "$(dirname "$0")"

# Set the Kubernetes API port (default to 6443 for secure port)
KUBERNETES_API_PORT="${KUBERNETES_API_PORT:-6443}"

# Set the domain and subdomains
MAIN_DOMAIN="serv.eysho.it"
API_DOMAIN="api.${MAIN_DOMAIN}"
PROXY_DOMAIN="proxy.${MAIN_DOMAIN}"

# Set the path for the kubectl config file
KUBE_CONFIG="./kubeconfig/admin.conf"

# Create token for kube-proxy if it doesn't exist
if [ ! -f "token.csv" ]; then
    echo "kube-proxy-token,kube-proxy,kube-proxy" > token.csv
    log "Created token.csv for kube-proxy"
fi

# Create directory for service account token if it doesn't exist
if [ ! -d "/var/run/secrets/kubernetes.io/serviceaccount" ]; then
    sudo mkdir -p /var/run/secrets/kubernetes.io/serviceaccount
    log "Created directory for service account token"
fi

# Check for required commands
for cmd in kubectl docker docker-compose; do
    if ! command -v "$cmd" &> /dev/null; then
        log "Error: $cmd command not found. Please install $cmd."
        exit 1
    fi
done

# Check if Docker engine is running
if ! docker info &> /dev/null; then
    log "Error: Docker engine is not running. Please start the Docker engine."
    exit 1
fi

# Rebuild and start the Kubernetes components
log "Rebuilding and starting Kubernetes components..."
docker-compose down
docker-compose build
docker-compose up -d

# Wait for the API server to become ready
log "Waiting for the API server to become ready..."
until curl -k --output /dev/null --silent --fail https://${API_DOMAIN}:${KUBERNETES_API_PORT}/healthz; do
    sleep 1
done
log "API server is ready."

# Create or update admin.conf
log "Creating/Updating admin.conf..."
kubectl config set-cluster kubernetes --server=https://${API_DOMAIN}:${KUBERNETES_API_PORT} --insecure-skip-tls-verify=true --kubeconfig="${KUBE_CONFIG}"
kubectl config set-credentials admin --token=admin --kubeconfig="${KUBE_CONFIG}"
kubectl config set-context kubernetes --cluster=kubernetes --user=admin --kubeconfig="${KUBE_CONFIG}"
kubectl config use-context kubernetes --kubeconfig="${KUBE_CONFIG}"

# Initialize the cluster
log "Initializing the cluster..."
kubectl --kubeconfig="${KUBE_CONFIG}" create namespace kube-system --dry-run=client -o yaml | kubectl --kubeconfig="${KUBE_CONFIG}" apply -f -

# Apply CoreDNS
log "Applying CoreDNS..."
kubectl --kubeconfig="${KUBE_CONFIG}" apply -f kubeconfig/coredns.yaml

# Apply Kubernetes Dashboard
log "Applying Kubernetes Dashboard..."
kubectl --kubeconfig="${KUBE_CONFIG}" apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create a dashboard admin user
log "Creating dashboard admin user..."
kubectl --kubeconfig="${KUBE_CONFIG}" apply -f - <<EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF

# Get the token for the dashboard admin user
DASHBOARD_TOKEN=$(kubectl --kubeconfig="${KUBE_CONFIG}" -n kubernetes-dashboard create token admin-user)

log "Kubernetes cluster setup complete."
log "You can interact with it using kubectl with the following config:"
log "kubectl --kubeconfig=${KUBE_CONFIG} get nodes"
log "Starting Kubernetes proxy..."
kubectl --kubeconfig="${KUBE_CONFIG}" proxy --address='0.0.0.0' --port=8001 --accept-hosts='^*$' &
log "Kubernetes proxy is running. You can access the dashboard at:"
log "http://${PROXY_DOMAIN}:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/"
log "Use the following token to log in to the dashboard:"
echo "${DASHBOARD_TOKEN}"
