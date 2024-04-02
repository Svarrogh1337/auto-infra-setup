# auto-infra-setup

## About The Project

This project is an example of how to provision and manage cloud-based infrastructure using Infrastructure-as-Code (IaC) 

### Failover design overview
Failover is triggered by CloudWath alarm (target-unhealthy-count), when threshold of 1 is reached UnHealthyHostCount.
An action is triggered to send message to SNS topic (tg-feed).
Lambda function(failover) is listening for events and triggers failover.py to reboot the corresponding unhealthy instances.

# Getting started

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 5.43.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.43.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudwatch"></a> [cloudwatch](#module\_cloudwatch) | ./modules/failover | n/a |
| <a name="module_my-service"></a> [my-service](#module\_my-service) | ./modules/my-service | n/a |
| <a name="module_networking"></a> [networking](#module\_networking) | ./modules/networking | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_key_pair.tf_key](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [tls_private_key.rsa](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_profile"></a> [aws\_profile](#input\_aws\_profile) | AWS Profile | `string` | `"default"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Account region | `string` | `"eu-central-1"` | no |
| <a name="input_ec2_count"></a> [ec2\_count](#input\_ec2\_count) | ec2 instances to be used. | `number` | `2` | no |
| <a name="input_key_pair_name"></a> [key\_pair\_name](#input\_key\_pair\_name) | key\_pair\_name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_private_key"></a> [private\_key](#output\_private\_key) | n/a |

## Installation

```

git clone git@github.com:Svarrogh1337/auto-infra-setup.git
cd auto-infra-setup
terraform init --upgrade
terraform validate
terraform plan
terraform apply -auto-approve
```

## Usage

Your service is up and running. Your lb endpoint is:
```
terraform output -raw lb_dns
```
To get the SSH key used for your instances:
```
terraform output -raw private_key > ~/.ssh/aws
```