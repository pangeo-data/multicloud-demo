# Put your cluster where your data is
project_id   = "pangeo-181919"
region       = "us-central1"
cluster_name = "earthcube"
zones        = ["us-central1-a"]
network      = "vpc-01"
subnet = {
  name = "us-central1-01"
  ip   = "10.0.0.0/17"
}

ip_range_pods     = "us-central1-01-gke-01-pods"
ip_range_services = "us-central1-01-gke-01-services"
# http_load_balancing        = false
# horizontal_pod_autoscaling = true
# network_policy             = true
