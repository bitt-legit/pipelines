module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "${var.company_prefix}-featurebase"
  cidr = "10.0.0.0/16"

  azs             = ["us-east-2a", "us-east-2a", "us-east-2a"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Name = "${var.company_prefix}-featurebase"
  }
}
