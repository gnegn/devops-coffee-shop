module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.8.4"

  cluster_name    = "${var.name}-cluster"
  cluster_version = "1.32"

  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.public_subnets
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true
  enable_irsa = true
  
  cluster_addons = {
    aws-ebs-csi-driver = {
      most_recent = true
    }
  }

  access_entries = {
    admin_user = {
      principal_arn     = var.admin_arn
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }

  eks_managed_node_groups = {
    spot_nodes = {
      instance_types = var.instance_type
      capacity_type  = "SPOT"
      min_size       = var.min_size
      max_size       = var.max_size
      desired_size   = var.desired_size
      
      iam_role_additional_policies = {
        ebs_csi_policy = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      labels = {
        role = "worker"
      }
    }
  }

  node_security_group_additional_rules = {
    ingress_allow_http = {
      description = "Allow HTTP traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
    ingress_allow_app_port = {
      description = "Allow application port traffic"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
      type        = "ingress"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
}

