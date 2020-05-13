# Multi-Cloud workflows with Pangeo and Dask Gateway

Demonstration using Pangeo deployments to work with datasets provided in
multiple cloud regions.

## Usage

1. Get the secret key for this repo
2. Get the Dask Gateway password
3. Install git-crypt (`brew install git-crypt` on a Mac, https://github.com/AGWA/git-crypt/blob/master/INSTALL.md).
4. Ensure you have Docker installed locally
5. Download and decrypt

```
git clone https://github.com/pangeo-data/multicloud-demo
cd multicloud-demo
git-crypt unlock /path/to/secret-key
```

6. Start Jupyterlab

```
make lab
```

Open your browser to `http://localhost:8888/` and you'll be at the notebook.



```python
password = getpass.getpass()  # Provide the password from step 2
```

## Branches

* master: Notebook, infrastructure
* binder: Docker image

## Development

Using `git-crypt` to store secrets. Ask Tom for the key.

```
.
├── aws  # Setup Kubernetes on AWS us-west-2
│   ├── aws
│   │   ├── main.tf
│   └── aws-creds
│       ├── iam.tf
├── config-gcp.yaml  # GCP-specic dask-gateway config
├── config.yaml      # Generic dask-gateway config
├── gcp  # Setup Kubernetes on GCP us-central1
│   └── gke
│       ├── main.tf
├── multicloud.ipynb  # Main analysis notebook.
├── secrets  # Encrypted secrets
│   ├── config.yaml
│   └── earthcube-sa.json
```


Versions

* `terraform`: Terraform v0.12.24
* `aws-cli`: aws-cli/1.18.22 Python/3.7.6 Darwin/18.6.0 botocore/1.15.22
* `gcloud`: 2020.03.06


## Manual GCP things

These should probably be moved to terraform.

* Created earchcube-sa in Console

```
gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/compute.viewer

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/container.clusterAdmin

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/container.developer

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountAdmin

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/iam.serviceAccountUser

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/resourcemanager.projectIamAdmin

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/container.clusterRoles

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/serviceusage.serviceUsageConsumer

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:earthcube-sa@pangeo-181919.iam.gserviceaccount.com \
  roles/serviceusage.serviceUsageViewer

gcloud iam service-accounts keys create ~/.config/gcloud/earthcube-sa.json --iam-account=earthcube-sa@pangeo-181919.iam.gserviceaccount.com
gcloud auth activate-service-account earthcube-sa@pangeo-181919.iam.gserviceaccount.com --key-file=$HOME/.config/gcloud/earthcube-sa.json
export GOOGLE_CLOUD_KEYFILE_JSON=~/.config/gcloud/earthcube-sa.json
```

## Notes on requester pays, GCP

Following https://blog.realkinetic.com/using-google-cloud-service-accounts-on-gke-e0ca4b81b9a2.
The basic idea:

* Make a service account (`dask-worker-sa`)
* Grant that service account permission to read from GCS
* Add the credentials file to kubernetes as a secret
* Mount the the secret credentials file in the workers.


```
export PROJECT_ID=$(gcloud config get-value core/project)
export SERVICE_ACCOUNT_NAME="dask-worker-sa"
export GCS_BUCKET_NAME="pangeo-era5"

gcloud iam service-accounts create ${SERVICE_ACCOUNT_NAME} --display-name="Dask Worker Service Account"

gcloud projects add-iam-policy-binding pangeo-181919 \
  --member serviceAccount:dask-worker-sa@pangeo-181919.iam.gserviceaccount.com \
  --role roles/serviceusage.serviceUsageConsumer


kubectl -n dask-gateway create secret generic dask-worker-sa-key --from-file service-account.json
```
