variable "region" {}
variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "vpc_cidr" {}
variable "public_subnets" {
  type = list(string)
}
variable "private_subnets" {
  type = list(string)
}
variable "cluster_name" {}
variable "cluster_version" {}

variable "node_group_name" {
  default = "heena-node-group"
}
variable "ec2_ssh_key" {
  default = "heena-key"  # Replace with your actual key name in AWS
}
