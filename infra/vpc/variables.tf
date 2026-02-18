variable "name" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "public_subnets" {
  type = list(string)
}
variable "region" {
  type = string
}
