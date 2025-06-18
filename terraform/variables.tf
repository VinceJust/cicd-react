variable "aws_region" {
  type        = string
  description = "AWS Region"
}

variable "aws_az" {
  type        = string
  description = "AWS Availability Zone"
}

variable "public_key_path" {
  type        = string
  description = "Pfad zum SSH Public Key (.pub)"
}

variable "ami_id" {
  type        = string
  description = "AMI ID für Ubuntu 22.04"
}
