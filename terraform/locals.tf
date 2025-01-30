locals {
  name   = "eks-dev-eu-west-1"
  region = "eu-west-1"
  
  eks_version = "1.32"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}