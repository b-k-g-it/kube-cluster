#!/bin/bash

KUBE_CONFIG="/opt/stacks/docker-compose-kubernetes/kubeconfig/admin.conf"
EXTERNAL_IP="0.0.0.0"

while [[ $# -gt 0 ]]; do
  case $1 in
    --kubeconfig)
      KUBE_CONFIG="$2"
      shift # past argument
      shift # past value
      ;;
    --external-ip)
      EXTERNAL_IP="$2"
      shift # past argument
      shift # past value
      ;;
    *)
      shift # past argument
      ;;
  esac
done

# Set the kube-ui Docker image (default to latest)
KUBE_UI_IMAGE="${KUBE_UI_IMAGE:-kubernetesui/dashboard:v2.7.0}"

# Create the kube-ui deployment
kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system create -f - << EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  replicas: 1
  selector:
    matchLabels:
      k8s-app: kubernetes-dashboard
  template:
    metadata:
      labels:
        k8s-app: kubernetes-dashboard
    spec:
      containers:
      - name: kubernetes-dashboard
        image: $KUBE_UI_IMAGE
        ports:
        - containerPort: 8443
          protocol: TCP
        args:
          - --auto-generate-certificates
          - --namespace=kube-system
        volumeMounts:
        - name: kubernetes-dashboard-certs
          mountPath: /certs
        - name: tmp-volume
          mountPath: /tmp
      volumes:
      - name: kubernetes-dashboard-certs
        secret:
          secretName: kubernetes-dashboard-certs
      - name: tmp-volume
        emptyDir: {}
      serviceAccountName: kubernetes-dashboard
      tolerations:
      - key: node-role.kubernetes.io/master
        effect: NoSchedule
EOF

# Create the kube-ui service
kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system create -f - << EOF
apiVersion: v1
kind: Service
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
spec:
  ports:
  - port: 443
    targetPort: 8443
  selector:
    k8s-app: kubernetes-dashboard
EOF

# Create the Ingress for the Kubernetes Dashboard
kubectl --kubeconfig="${KUBE_CONFIG}" --namespace=kube-system create -f - << EOF
apiVersion: networking.k8s.io/v1
kind: Ingress  
metadata:
  name: kubernetes-dashboard
  namespace: kube-system
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/backend-protocol: HTTPS
spec:
  rules:
  - host: serv.eysho.it
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubernetes-dashboard
            port: 
              number: 443
  tls:
  - hosts:
    - serv.eysho.it
    secretName: kubernetes-dashboard-certs
EOF
