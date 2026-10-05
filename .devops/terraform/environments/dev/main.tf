provider "aws" {
  region = var.aws_region
}

module "aws_infrastructure" {
  source = "../../modules/aws-infrastructure"

  project_name = "enterprise-multi-cloud-platform"
  environment  = "dev"

  vpc_cidr           = "10.10.0.0/16"
  public_subnet_cidr = "10.10.1.0/24"
  availability_zone  = "${var.aws_region}a"

  instance_type = "t3.micro"
  ami_id        = var.ami_id

  ssh_public_key = file("~/.ssh/id_ed25519.pub")
}
