resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "tf_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "random_password" "db_master_pass" {
  length            = 40
  special           = true
  min_special       = 5
  override_special  = "!#$%^&*()-_=+[]{}<>:?"
  keepers           = {
    pass_version  = 1
  }
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
    db-password = random_password.db_master_pass.result
}

module "cloudwatch" {
    source = "./modules/failover"
    ec2_count = var.ec2_count
    instance_ids = module.my-service.instance_ids
    lb = module.my-service.lb
    tg = module.my-service.tg
}