  variable "name" {
    type = string
  }
  variable "region" {
    type = string
  }
  variable "vpc_id" {
    type = string
  }
  variable "public_subnets" {
    type = list(string)
  }
  variable "min_size" {
    description = "Minimum size of managed node group"
    default     = 1
    type        = number
  }
  variable "max_size" {
    description = "Maximum size of managed node group"
    default     = 3
    type        = number
  }
  variable "desired_size" {
    description = "Desired size of managed node group"
    default     = 2
    type        = number
  }
  variable "instance_type" {
    description = "Type of cluster nodes"
    default     = ["t3.medium"]
    type        = list(string)
  }
  variable "admin_arn" {
    description = "IAM ARN for EKS access entry"
    type        = string
  }