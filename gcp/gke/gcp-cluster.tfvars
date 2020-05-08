# Put your cluster where your data is
project_id = "pangeo-181919"
region = "us-central-1"
cluster_name = "earthcube"
zones                      = ["us-central1-a", "us-central1-b", "us-central1-f"]
network                    = "vpc-01"
subnetwork                 = "us-central1-01"
ip_range_pods              = "us-central1-01-gke-01-pods"
ip_range_services          = "us-central1-01-gke-01-services"
# http_load_balancing        = false
# horizontal_pod_autoscaling = true
# network_policy             = true
