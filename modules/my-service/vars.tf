variable "vpc_id" {
  description = "VPC ID"
}
variable "subnet_ids" {
  description = "Subnet IDs"
}

variable "key_name" {
  description = "SSH Key name."
}

variable "ec2_count" {
  description = "ec2 instances to be used."
  type        =  number
}

variable "db-username" {
  type = string
  default = "mysql_user"
}
variable "db-password" {
  type = string
}