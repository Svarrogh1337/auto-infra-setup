resource "aws_security_group" "allow_rds_traffic" {
  name        = "allow_http_traffic"
  description = "Allow inbound http traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_rds_traffic" {
  security_group_id = aws_security_group.allow_rds_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_security_group" "allow_https_traffic" {
  name        = "allow_https_traffic"
  description = "Allow inbound http traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_https_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_traffic" {
  security_group_id = aws_security_group.allow_https_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_security_group" "allow_http_traffic" {
  name        = "allow_http_traffic"
  description = "Allow inbound http traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_http_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_http_traffic" {
  security_group_id = aws_security_group.allow_http_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_security_group" "allow_ssh_traffic" {
  name        = "allow_ssh_traffic"
  description = "Allow inbound ssh traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_ssh_traffic"
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_traffic" {
  security_group_id = aws_security_group.allow_ssh_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_security_group" "allow_all_egress_traffic" {
  name        = "allow_all_egress_traffic"
  description = "Allow all outbound traffic"
  vpc_id      = var.vpc_id

  tags = {
    Name = "allow_all_egress_traffic"
  }
}

resource "aws_vpc_security_group_egress_rule" "allow_all_egress_traffic" {
  security_group_id = aws_security_group.allow_all_egress_traffic.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}

resource "random_shuffle" "az" {
  input        = var.subnet_ids
  result_count = 1
}

resource "aws_instance" "app-node" {
 count                     = var.ec2_count
 ami                       = "ami-065deacbcaac64cf2"
 instance_type             = "t2.micro"
 subnet_id                 = random_shuffle.az.result[0]
 security_groups           = [aws_security_group.allow_http_traffic.id, aws_security_group.allow_ssh_traffic.id, aws_security_group.allow_all_egress_traffic.id]
 associate_public_ip_address = "true"
 key_name      = var.key_name
 user_data                 = <<-EOF
                #!/bin/bash
                sudo apt-get update
                sudo apt-get install apache2 -y
                sudo systemctl start apache2
                sudo systemctl enable apache2
                EOF
 tags = {
   Name = "app-node${count.index}",
 }
 lifecycle {
  ignore_changes = all
  }
}

resource "aws_lb" "app-lb1" {
  name               = "app-lb1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_http_traffic.id, aws_security_group.allow_https_traffic.id, aws_security_group.allow_all_egress_traffic.id]
  subnets            = var.subnet_ids
}


resource "aws_lb_target_group" "app-lb1-tg1" {
  name        = "app-lb1-tg1"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    path = "/"
  }
}

resource "aws_lb_listener" "app-lb1-listener" {
  load_balancer_arn = aws_lb.app-lb1.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app-lb1-tg1.arn
  }
}

resource "aws_lb_target_group_attachment" "app-node" {
  count            = var.ec2_count
  target_group_arn = aws_lb_target_group.app-lb1-tg1.arn
  target_id        = aws_instance.app-node[count.index].id
  port             = 80
}

resource "aws_db_subnet_group" "rds" {
  name       = "rds"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "RDS subnet group"
  }
}

resource "aws_db_instance" "app-rds1" {
  engine                 = "mysql"
  db_name                = "app1"
  identifier             = "app1"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  username               = var.db-username
  password               = var.db-password
  vpc_security_group_ids = [aws_security_group.allow_rds_traffic.id]
  skip_final_snapshot    = true
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  tags = {
    Name = "app-rds1"
  }
}
