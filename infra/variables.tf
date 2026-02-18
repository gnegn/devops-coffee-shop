variable "region" {
  description = "Your AWS region"
  type        = string
  default     = "eu-north-1"
}
variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "coffee-shop"
}
variable "admin_arn" {
  description = "IAM ARN of the user to be added as cluster admin"
  type        = string
}