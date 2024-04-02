output "vpc_id" {
  value = aws_vpc.main.id
  description = "VPC ID"
}
output "subnet_ids" {
  value = [aws_subnet.central-1b.id, aws_subnet.central-1a.id]
  description = "Subnet IDs"
}