variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_az" {
  type        = string
  description = "AWS Availability Zone"
}

variable "ami_id" {
  type        = string
  description = "AMI ID für Ubuntu 22.04"
}

variable "public_key" {
  description = "SSH Public Key"
  type        = string
}
