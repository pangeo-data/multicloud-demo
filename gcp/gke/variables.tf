variable "region" {
  default = "us-central1"
}

variable "project_id" {
}

variable "cluster_name" {
  default = "test-cluster-change-name"
}

variable "zones" {
  default = ["us-central1-a", "us-central1-b", "us-central1-f"]
}

variable "network" {
  default = "vpc-01"
}

variable "subnetwork" {
  default = "us-central1-01"
}

variable "ip_range_pods" {
  default = "us-central1-01-gke-01-pods"
}
variable "ip_range_services" {
  default = "us-central1-01-gke-01-services"
}

variable "subnet" {
  default = {
    name = "us-central-01"
    ip   = "10.0.0.0/17"
  }
}

# variable "profile" {
#   default = "earthcube-bot"
# }
# variable "vpc_name" {
#   default = "vpc-test-cluster-change-name"
# }

# variable "map_accounts" {
#   description = "Additional AWS account numbers to add to the aws-auth configmap."
#   type        = list(string)
#   default     = []
# }

# variable "map_roles" {
#   description = "Additional IAM roles to add to the aws-auth configmap."
#   type = list(object({
#     rolearn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#   ]
# }

# variable "map_users" {
#   description = "Additional IAM users to add to the aws-auth configmap."
#   type = list(object({
#     userarn  = string
#     username = string
#     groups   = list(string)
#   }))

#   default = [
#   ]
# }
