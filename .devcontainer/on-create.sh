#!/bin/bash

echo "on-create start" >> ~/status

# # create local registry
k3d registry create registry.localhost --port 5000
docker network connect dapr k3d-registry.localhost

# create kafka-function
cd azure-functions-kafka-extension/kafka-function
docker build . -t k3d-registry.localhost:5000/kafka-function
docker push k3d-registry.localhost:5000/kafka-function
cd ../../

# set up kafka for k8s cluster
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# deploy KEDA on k8s cluster
helm repo add kedacore https://kedacore.github.io/charts
helm repo update


# helm install ingress-controller bitnami/nginx-ingress-controller \
#     --namespace ingress-nginx \
#     --set controller.replicaCount=1 \
#     --set controller.metrics.enabled=true \
#     --set controller.podAnnotations."prometheus\.io/scrape"="true" \
#     --set controller.podAnnotations."prometheus\.io/port"="10254"  \
#     --set controller.service.type=NodePort

# create the cluster
make create

echo "on-create complete" >> ~/status
