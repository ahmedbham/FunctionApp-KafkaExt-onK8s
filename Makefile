.PHONY: help create delete check logs jumpbox

help :
	@echo "Usage:"
	@echo "   make create     - delete and create a new cluster"
	@echo "   make delete     - delete the k3d cluster"
	@echo "   make check      - check the node app endpoints"
	@echo "   make logs       - check the node app logs"
	@echo "   make jumpbox    - deploy a 'jumpbox' pod"

create : delete
	# create k3d cluster
	k3d cluster create --registry-use k3d-registry.localhost:5000 --config deploy/k3d.yaml
	kubectl wait node --for condition=ready --all --timeout=60s

	# install dapr
	dapr init -k --enable-mtls=false --wait

	# deploy redis
	kubectl apply -f deploy/redis.yaml

	# wait for redis master to start
	kubectl wait pod -l app=redis --for condition=ready --timeout=60s

	# deploy apps
	kubectl apply -f deploy/node.yaml
	kubectl apply -f deploy/python.yaml

delete :
	# delete the cluster (if exists)
	@# this will fail harmlessly if the cluster does not exist
	@dapr uninstall
	@k3d cluster delete

check :
	# curl the node app endpoint
	http localhost:30080/order

jumpbox :
	@# start a jumpbox pod
	@-kubectl delete pod jumpbox --ignore-not-found=true

	@kubectl run jumpbox --image=ghcr.io/retaildevcrews/jumpbox:latest --restart=Always

	#
	# use kj to execute bash "in" the jumpbox
	#
	# use kje <command> to execute a command "in" the jumpbox
	#
	# kje http http://nodeapp-dapr:3000/order

logs :
	kubectl logs --selector=app=node -c node
