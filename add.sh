cd /opt/stacks/docker-compose-kubernetes/kubeconfig

# Create controller-manager.conf
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --server=https://localhost:6443 --kubeconfig=controller-manager.conf
kubectl config set-credentials system:kube-controller-manager --client-certificate=/etc/kubernetes/pki/apiserver.crt --client-key=/etc/kubernetes/pki/apiserver.key --embed-certs=true --kubeconfig=controller-manager.conf
kubectl config set-context system:kube-controller-manager@kubernetes --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=controller-manager.conf
kubectl config use-context system:kube-controller-manager@kubernetes --kubeconfig=controller-manager.conf

# Create scheduler.conf
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --server=https://localhost:6443 --kubeconfig=scheduler.conf
kubectl config set-credentials system:kube-scheduler --client-certificate=/etc/kubernetes/pki/apiserver.crt --client-key=/etc/kubernetes/pki/apiserver.key --embed-certs=true --kubeconfig=scheduler.conf
kubectl config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler --kubeconfig=scheduler.conf
kubectl config use-context system:kube-scheduler@kubernetes --kubeconfig=scheduler.conf

# Create kubeconfig.conf for kube-proxy
kubectl config set-cluster kubernetes --certificate-authority=/etc/kubernetes/pki/ca.crt --embed-certs=true --server=https://localhost:6443 --kubeconfig=kubeconfig.conf
kubectl config set-credentials system:kube-proxy --client-certificate=/etc/kubernetes/pki/apiserver.crt --client-key=/etc/kubernetes/pki/apiserver.key --embed-certs=true --kubeconfig=kubeconfig.conf
kubectl config set-context system:kube-proxy@kubernetes --cluster=kubernetes --user=system:kube-proxy --kubeconfig=kubeconfig.conf
kubectl config use-context system:kube-proxy@kubernetes --kubeconfig=kubeconfig.conf

cd /opt/stacks/docker-compose-kubernetes
