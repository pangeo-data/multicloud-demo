.PHONY: google
GCP_RELEASE=gcp-dask-gateway
AWS_RELEASE=aws-dask-gateway
NAMESPACE=dask-gateway
VERSION=0.7.1


google:
	cd gcp/gke && \
		terraform apply --var-file=gcp-cluster.tfvars --auto-approve


# TODO: activate kubectl before running
# TODO: run kubectl create namespace dask-gateway
dask-gcp:
	helm upgrade --install \
		--namespace $(NAMESPACE) \
		--version $(VERSION) \
		--values secrets/config.yaml \
		$(GCP_RELEASE) \
		dask-gateway/dask-gateway

# TODO: activate kubectl before running
# TODO: run kubectl create namespace dask-gateway
dask-aws:
	helm upgrade --install \
		--namespace $(NAMESPACE) \
		--version $(VERSION) \
		--values secrets/config.yaml \
		$(AWS_RELEASE) \
		dask-gateway/dask-gateway
