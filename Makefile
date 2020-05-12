.PHONY: google, aws-config, gcp-config
GCP_RELEASE=gcp-dask-gateway
AWS_RELEASE=aws-dask-gateway
NAMESPACE=dask-gateway
VERSION=0.7.1


google:
	cd gcp/gke && \
		terraform apply --var-file=gcp-cluster.tfvars --auto-approve

config-aws:
	aws eks --region=us-west-2 update-kubeconfig --name=earthcube-cluster --kubeconfig=aws-config

config-gcp:
	gcloud container clusters get-credentials earthcube --zone=us-central1

dask-gcp-ns:
	kubectl create namespace dask-gateway --cluster=gke_pangeo-181919_us-central1_earthcube

dask-aws-ns:
	kubectl create namespace dask-gateway --kubeconfig=aws-config

# TODO: activate kubectl before running
# TODO: run kubectl create namespace dask-gateway
dask-gcp:
	helm --kube-context=gke_pangeo-181919_us-central1_earthcube upgrade --install \
		--namespace $(NAMESPACE) \
		--version $(VERSION) \
		--values secrets/config.yaml \
		--values config.yaml \
		$(GCP_RELEASE) \
		dask-gateway/dask-gateway

# TODO: activate kubectl before running
# TODO: run kubectl create namespace dask-gateway
dask-aws:
	helm --kubeconfig=aws-config upgrade --install \
		--namespace $(NAMESPACE) \
		--version $(VERSION) \
		--values secrets/config.yaml \
		--values config.yaml \
		$(AWS_RELEASE) \
		dask-gateway/dask-gateway

print-ips:
	kubectl --namespace=dask-gateway get service traefik-aws-dask-gateway --kubeconfig=aws-config
	kubectl --namespace=dask-gateway get service traefik-gcp-dask-gateway --cluster=gke_pangeo-181919_us-central1_earthcube


lab:
	docker run -it --rm --mount type=bind,src=$(PWD),target=/home/jovyan/ -p 8888:8888 tomaugspurger/pangeo-multicloud:2020.05.12.0 -- jupyter lab --ip=0.0.0.0
