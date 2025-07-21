provider "aws" {
  region = var.region
}
 
resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr
}
 
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  cidr_block              = var.public_subnets[count.index]
  vpc_id                  = aws_vpc.this.id
  map_public_ip_on_launch = true
  availability_zone = var.availability_zones[count.index]

  tags = {
    "Name"                                      = "public-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/elb"                    = "1"
  }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  cidr_block        = var.private_subnets[count.index]
  vpc_id            = aws_vpc.this.id
  availability_zone = var.availability_zones[count.index]

  tags = {
    "Name"                                      = "private-subnet-${count.index}"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
    "kubernetes.io/role/internal-elb"           = "1"
  }
}

 
# data "aws_availability_zones" "available" {}