module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.19.0"
  name    = "${var.name}-vpc"
  cidr    = var.vpc_cidr

  azs            = ["${var.region}a", "${var.region}b"]
  public_subnets = var.public_subnets

  enable_nat_gateway      = false
  map_public_ip_on_launch = true
  enable_dns_hostnames    = true
  enable_dns_support      = true
  # Disabling nat_gateway and using public subnets with map_public_ip_on_launch allows us to have a simpler and more cost-effective setup for our use case.

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.name}-cluster" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
  # Tagging the VPC allows Kubernetes to recognize this VPC as part of the cluster, which is necessary for proper integration and management of resources within the cluster.
}