output "instance_ids" {
  value = aws_instance.app-node[*].id
  description = "EC2 Instance IDs"
}


output "lb" {
  value     = aws_lb.app-lb1.arn_suffix
}

output "tg" {
  value     = aws_lb_target_group.app-lb1-tg1.arn_suffix
}