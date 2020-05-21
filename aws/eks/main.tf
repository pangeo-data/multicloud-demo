terraform {
  required_version = ">= 0.12.6"
}

provider "aws" {
  version = "2.59.0"
  region  = var.region
  profile = var.profile
}

provider "template" {
  version = "~> 2.1"
}

provider "helm" {
  version = "~> 1.2"
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

data "aws_caller_identity" "current" {}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
  version                = "~> 1.11.1"
}

data "aws_availability_zones" "available" {
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 2.6"

  name = var.vpc_name
  cidr = "172.16.0.0/16"
  azs  = data.aws_availability_zones.available.names

  public_subnets       = ["172.16.1.0/24", "172.16.2.0/24", "172.16.3.0/24"]
  private_subnets      = ["172.16.4.0/24", "172.16.5.0/24", "172.16.6.0/24"]
  enable_dns_hostnames = true
  enable_dns_support   = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    Owner                                       = split("/", data.aws_caller_identity.current.arn)[1]
    AutoTag_Creator                             = data.aws_caller_identity.current.arn
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = var.cluster_name
  cluster_version = "1.15"

  subnets     = module.vpc.private_subnets
  vpc_id      = module.vpc.vpc_id
  enable_irsa = true

  cluster_endpoint_private_access = true

  tags = {
    Owner           = split("/", data.aws_caller_identity.current.arn)[1]
    AutoTag_Creator = data.aws_caller_identity.current.arn
  }

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 50
  }

  worker_groups_launch_template = [
    {
      name                    = "gateway-spot"
      override_instance_types = ["m5.xlarge", "m5a.xlarge"]
      spot_instance_pools     = 2
      asg_max_size            = 1
      asg_min_size            = 1
      asg_desired_capacity    = 1

      # Use this to set labels / taints
      kubelet_extra_args = "--node-labels=role=core"
    },
    {
      name                    = "scheduler-spot"
      override_instance_types = ["m5.xlarge", "m5a.xlarge"]
      spot_instance_pools     = 2
      asg_max_size            = 2
      asg_min_size            = 1
      asg_desired_capacity    = 1

      # Use this to set labels / taints
      kubelet_extra_args = "--node-labels=role=scheduler --register-with-taints k8s.dask.org/dedicated=scheduler:NoSchedule"

      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/k8s.dask.org/dedicated"
          "propagate_at_launch" = "false"
          "value"               = "scheduler:NoSchedule"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    },
    {
      name                    = "worker-spot"
      override_instance_types = ["r5.2xlarge", "r4.2xlarge"]
      spot_instance_pools     = 2
      asg_max_size            = 40
      asg_min_size            = 0
      asg_desired_capacity    = 0

      # Use this to set labels / taints
      kubelet_extra_args = "--node-labels=role=worker --register-with-taints k8s.dask.org/dedicated=worker:NoSchedule"

      tags = [
        {
          "key"                 = "k8s.io/cluster-autoscaler/node-template/taint/k8s.dask.org/dedicated"
          "propagate_at_launch" = "false"
          "value"               = "worker:NoSchedule"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/enabled"
          "propagate_at_launch" = "false"
          "value"               = "true"
        },
        {
          "key"                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
          "propagate_at_launch" = "false"
          "value"               = "true"
        }
      ]
    }
  ]

  map_roles    = var.map_roles
  map_users    = var.map_users
  map_accounts = var.map_accounts
}
