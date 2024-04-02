terraform {
 required_providers {
   aws = {
     source  = "hashicorp/aws"
     version = "~> 5.43.0"
   }
 }
 backend "s3" {
   bucket = "tf-bknd"
   key    = "terraform/state"
   region = "eu-central-1"
 }
}
provider "aws" {
  profile = var.aws_profile
  region  = var.aws_region
}
terraform {

}