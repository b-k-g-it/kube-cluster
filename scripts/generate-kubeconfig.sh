# Create or update admin.conf
#log "Creating/Updating admin.conf..."
kubectl config set-cluster kubernetes --server=https://${API_DOMAIN}:${KUBERNETES_API_PORT} --insecure-skip-tls-verify=true --kubeconfig="${KUBE_CONFIG}"
kubectl config set-credentials admin --token=admin --kubeconfig="${KUBE_CONFIG}"
kubectl config set-context kubernetes --cluster=kubernetes --user=admin --kubeconfig="${KUBE_CONFIG}"
kubectl config use-context kubernetes --kubeconfig="${KUBE_CONFIG}"
