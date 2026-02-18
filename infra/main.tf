module "vpc" {
  source         = "./vpc"
  name           = var.project_name
  vpc_cidr       = "10.10.0.0/16"
  public_subnets = ["10.10.1.0/24", "10.10.2.0/24"]
  region         = var.region
}

module "eks" {
  source         = "./eks"
  name           = var.project_name
  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets
}