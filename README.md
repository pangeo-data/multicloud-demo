# Multi-Cloud workflows with Pangeo and Dask Gateway

Demonstration using Pangeo deployments to work with datasets provided in
mulitple cloud regions.

Version

* `terraform`: Terraform v0.12.24



Manual stuff

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
```


gcloud iam service-accounts keys create ~/.config/gcloud/earthcube-sa.json --iam-account=earthcube-sa@pangeo-181919.iam.gserviceaccount.com
gcloud auth activate-service-account earthcube-sa@pangeo-181919.iam.gserviceaccount.com --key-file=$HOME/.config/gcloud/earthcube-sa.json
export GOOGLE_CLOUD_KEYFILE_JSON=~/.config/gcloud/earthcube-sa.json
