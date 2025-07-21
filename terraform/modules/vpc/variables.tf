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

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones to use for subnets"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]  # Only supported AZs
}

