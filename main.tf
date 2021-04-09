resource "aws_instance" "myec2" {
  ami           = var.ami_id
  key_name      = "tf training"
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