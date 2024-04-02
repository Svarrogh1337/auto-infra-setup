resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.rsa.public_key_openssh
}
module "networking" {
    source = "./modules/networking"
}

module "my-service" {
    source = "./modules/my-service"
    vpc_id = module.networking.vpc_id
    subnet_ids = module.networking.subnet_ids
    key_name = aws_key_pair.tf_key.key_name
    ec2_count = var.ec2_count
}

module "cloudwatch" {
    source = "./modules/failover"
    ec2_count = var.ec2_count
    instance_ids = module.my-service.instance_ids
    lb = module.my-service.lb
    tg = module.my-service.tg
}