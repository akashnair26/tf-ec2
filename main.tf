data "aws_ami" "ami" {
  most_recent      = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*"]
  }
  filter {
    name = "owner-alias"
    values = ["amazon"]
  }

}

resource "aws_instance" "servers" {
  count = 2
  ami = data.aws_ami.ami.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.privateSubnet1.id

  user_data = <<-EOF
                #!/bin/bash
                sudo yum update -y
                sudo yum install -y nginx
                sudo systemctl enable nginx
                sudo systemctl start nginx
                EOF
}

resource "aws_security_group" "serverSG" {
  vpc_id = aws_vpc.vpc_dev.id
  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    security_groups = [aws_security_group.albSG.id]
  }
}

resource "aws_lb_target_group" "webTargetGroup" {
  name = "server-tg"
  port = 80
  protocol = "http"
  target_type = "instance"
  vpc_id = aws_vpc.vpc_dev.id
}

resource "aws_lb_target_group_attachment" "webTargetGroupAttachment" {
  count = 2
  target_group_arn = aws_lb_target_group.webTargetGroup.arn
  target_id = aws_instance.servers[count.index].id
}

resource "aws_security_group" "albSG" {
  name = "albSG"
  vpc_id = aws_vpc.vpc_dev.id
  ingress {
    from_port = 443
    to_port = 443
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "alb" {
  name = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.albSG.id]
  subnets = [aws_subnet.publicSubnet1.id, aws_subnet.publicSubnet2.id]
}

resource "aws_alb_listener" "albHTTPS" {
  load_balancer_arn = aws_lb.alb.arn
  port = 443
  protocol = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn = "arn:aws:acm:Region:444455556666:certificate/certificate_ID"
    default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.webTargetGroup.arn
  }
}