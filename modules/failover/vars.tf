variable "ec2_count" {
  description = "ec2 instances to be used."
  type        =  number
}

variable "instance_ids" {
  description = "ec2 instance ids."
}

variable "lb" {
  description = "Loadbalancer target group"
}

variable "tg" {
  description = "Loadbalancer target group arn."
}
data "aws_region" "current" {}