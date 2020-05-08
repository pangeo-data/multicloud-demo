locals {
  cluster_type = "earthcube"
}

provider "google-beta" {
  version = "~> 3.19.0"
  region  = var.region
}

module "gke" {
  source                            = "terraform-google-modules/kubernetes-engine/google//modules/beta-public-cluster"
  project_id                        = var.project_id
  name                              = var.cluster_name
  region                            = var.region
  zones                             = var.zones
  network                           = var.network
  subnetwork                        = var.subnetwork
  ip_range_pods                     = var.ip_range_pods
  ip_range_services                 = var.ip_range_services
  create_service_account            = false
  remove_default_node_pool          = true
  disable_legacy_metadata_endpoints = false
#   cluster_autoscaling               = var.cluster_autoscaling

  node_pools = [
    {
      name            = "scheduler-pool"
      machine_type      = "n1-standard-2"
      min_count       = 0
      max_count       = 2
      service_account = var.compute_engine_service_account
      auto_upgrade    = true
      initial_node_count = 1
      preemptible        = false
    },
    {
      name              = "worker-pool"
      machine_type      = "n1-standard-2"
      min_count         = 0
      max_count         = 40
      service_account   = var.compute_engine_service_account
      preemptible        = true
    },
  ]

#   node_pools_metadata = {
#     pool-01 = {
#       shutdown-script = file("${path.module}/data/shutdown-script.sh")
#     }
#   }

  node_pools_labels = {
    all = {
      all-pools-example = true
    }
  }

  node_pools_taints = {
    all = [
      {
        key    = "all-pools-example"
        value  = true
        effect = "PREFER_NO_SCHEDULE"
      },
    ]
    scheduler-pool = [
      {
        key    = "k8s.dask.org/dedicated"
        value  = scheduler
        effect = "NoSchedule"
      },
    ],
    worker-pool = [
      {
        key    = "k8s.dask.org/dedicated"
        value  = worker
        effect = "NoSchedule"
      },
    ]
  }
}
