output "private_key" {
  value     = tls_private_key.rsa.private_key_pem
  sensitive = true
}

output "lb_dns" {
  value     = module.my-service.lb_dns
}