variable "aws_region" {
  description = "Account region"
  default = "eu-central-1"
}

variable "aws_profile" {
  description = "AWS Profile"
  default = "default"
}

variable "ec2_count" {
  description = "ec2 instances to be used."
  type        =  number
  default     = 2
}

variable "key_pair_name" {
  description = "key_pair_name"
  type        = string
}

data "aws_region" "current" {}