variable "aws_region" {
  description = "AWS region for the dev environment"
  type        = string
  default     = "ap-south-1"
}

variable "ami_id" {
  description = "AMI ID for the dev EC2 instance"
  type        = string
}
