variable "vpc_cidr" {
  description = "CIDR block for the VPC"
default = "10.0.0.0/16"
}
 
variable "public_subnets" {
  type        = list(string)
  description = "Public Subnet CIDRs"
}
 
variable "private_subnets" {
  type        = list(string)
  description = "Private Subnet CIDRs"
}
 
variable "region" {
  default = "us-east-1"
}

variable "cluster_name" {
  description = "Name of the EKS cluster for subnet tagging"
}
