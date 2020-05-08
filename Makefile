.PHONY: google
GCP_RELEASE=gcp-dask-gateway
NAMESPACE=dask-gateway
VERSION=0.7.1


google:
	cd gcp/gke && \
		terraform apply --var-file=gcp-cluster.tfvars --auto-approve

dask:
	helm upgrade --install \
		--namespace $(NAMESPACE) \
		--version $(VERSION) \
		--values path/to/your/config.yaml \
		$(RELEASE) \
		daskgateway/dask-gateway
