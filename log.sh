#!/bin/bash

# Set variables
DOCKER_COMPOSE_DIR="kubernetes"
DOCKER_COMPOSE_FILE="$DOCKER_COMPOSE_DIR/docker-compose.yml"
ERROR_LOG="error.log"

# Check if the Docker Compose directory exists
if [ -d "$DOCKER_COMPOSE_DIR" ]; then
    echo "Found Docker Compose directory: $DOCKER_COMPOSE_DIR"
else
    echo "Docker Compose directory not found: $DOCKER_COMPOSE_DIR" >> $ERROR_LOG
    exit 1
fi

# Check if the Docker Compose file exists
if [ -f "$DOCKER_COMPOSE_FILE" ]; then
    echo "Found Docker Compose file: $DOCKER_COMPOSE_FILE"
else
    echo "Docker Compose file not found: $DOCKER_COMPOSE_FILE" >> $ERROR_LOG
    exit 1
fi

# Check the container logs
echo "Checking the container logs..."

# Check logs for kubernetes-etcd-1
docker logs kubernetes-etcd-1 2>&1 | grep "E0820" >> $ERROR_LOG
if [ $? -ne 0 ]; then
    echo "kubernetes-etcd-1 container is running normally."
else
    echo "kubernetes-etcd-1 container has errors. Check $ERROR_LOG for more details."
fi

# Check logs for kubernetes-kube-apiserver-1
docker logs kubernetes-kube-apiserver-1 2>&1 | grep "E0820" >> $ERROR_LOG
if [ $? -ne 0 ]; then
    echo "kubernetes-kube-apiserver-1 container is running normally."
else
    echo "kubernetes-kube-apiserver-1 container has errors. Check $ERROR_LOG for more details."
fi

# Check logs for kubernetes-kube-proxy-1
docker logs kubernetes-kube-proxy-1 2>&1 | grep "E0820" >> $ERROR_LOG
if [ $? -ne 0 ]; then
    echo "kubernetes-kube-proxy-1 container is running normally."
else
    echo "kubernetes-kube-proxy-1 container has errors. Check $ERROR_LOG for more details."
fi

# Check logs for kubernetes-coredns-1
docker logs kubernetes-coredns-1 2>&1 | grep "E0820" >> $ERROR_LOG
if [ $? -ne 0 ]; then
    echo "kubernetes-coredns-1 container is running normally."
else
    echo "kubernetes-coredns-1 container has errors. Check $ERROR_LOG for more details."
fi

echo "Script completed. Check $ERROR_LOG for any errors."
