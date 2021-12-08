module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "example"
  cidr = "10.30.0.0/16"

  azs             = ["ap-northeast-1a", "ap-northeast-1c"]
  private_subnets = ["10.30.1.0/24", "10.30.2.0/24"]
  public_subnets  = ["10.30.101.0/24", "10.30.102.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Terraform = "true"
  }
}
