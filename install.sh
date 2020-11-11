#!/bin/bash

set -euo pipefail

# Deploy Chaos Mesh Operators & CRDs
curl -sSL https://mirrors.chaos-mesh.org/latest/install.sh | bash

# Deploy RabbitMQ Operators & CRDs
kubectl apply -f https://github.com/rabbitmq/cluster-operator/releases/download/0.49.0/cluster-operator.yml

pushd kube-prometheus
docker run --rm -v $(pwd):$(pwd) --workdir $(pwd) quay.io/coreos/jsonnet-ci jb update
docker run --rm -v $(pwd):$(pwd) --workdir $(pwd) quay.io/coreos/jsonnet-ci ./build.sh monitoringstack.jsonnet
popd

kubectl apply -f kube-prometheus/manifests/setup
kubectl apply -f kube-prometheus/manifests
kubectl apply -f prometheus-roles.yaml
kubectl apply -f rabbitmq-podmonitor.yaml

echo "Install complete."
echo ""
echo "To access Prometheus, access https://localhost:9090 after running:"
echo ""
echo "kubectl --namespace monitoring port-forward svc/prometheus-k8s 9090"
echo ""
echo "To access Grafana, access https://localhost:3000 after running:"
echo ""
echo "kubectl --namespace monitoring port-forward svc/grafana 3000"
echo ""
echo "To access Chaos Mesh Dashboard, access https://localhost:2333 after running:"
echo ""
echo "kubectl --namespace chaos-testing port-forward svc/chaos-dashboard 2333"
echo ""
