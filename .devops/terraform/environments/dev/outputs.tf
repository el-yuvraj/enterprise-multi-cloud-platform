output "vpc_id" {
  value = module.aws_infrastructure.vpc_id
}

output "public_subnet_id" {
  value = module.aws_infrastructure.public_subnet_id
}

output "security_group_id" {
  value = module.aws_infrastructure.security_group_id
}

output "instance_id" {
  value = module.aws_infrastructure.instance_id
}

output "public_ip" {
  value = module.aws_infrastructure.public_ip
}
