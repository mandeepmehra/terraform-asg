resource "aws_instance" "myec2" {
  ami           = var.ami_id
  key_name      = "mandeep"
  instance_type = "t2.micro"
  tags = {
    Name = "ASExample-mandeep"
  }
  vpc_security_group_ids = [aws_security_group.sg.id]
  user_data              = <<-EOF
                #!/bin/bash
                echo "Hello World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
}

output "instance_ip" {
  value = aws_instance.myec2.public_ip
}

resource "aws_security_group" "sg" {
  name = "asexample"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "launchConfig" {
  image_id        = var.ami_id
  instance_type   = "t2.micro"
  key_name        = "tf training"
  user_data       = <<-EOF
                #!/bin/bash
                echo "Hello World" > index.html
                nohup busybox httpd -f -p 8080 &
                EOF
  security_groups = [aws_security_group.sg.id]
}

resource "aws_autoscaling_group" "asg" {
  launch_configuration = aws_launch_configuration.launchConfig.id
  min_size             = 2
  max_size             = 3
  health_check_type    = "ELB"
  load_balancers       = [aws_elb.elb.id]
  availability_zones   = data.aws_availability_zones.allazs.names
}

resource "aws_security_group" "elbsg" {
  name = "elbsg-mandeep"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "allazs" {

}

resource "aws_elb" "elb" {
  name               = "ASGExample-Mandeep"
  security_groups    = [aws_security_group.elbsg.id]
  availability_zones = data.aws_availability_zones.allazs.names
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "8080"
    instance_protocol = "http"
  }
  health_check {
    timeout             = 3
    interval            = 30
    target              = "HTTP:8080/"
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}