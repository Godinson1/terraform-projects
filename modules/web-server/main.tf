data "aws_ami" "linux-image" {
  most_recent = true
  owners = [var.ami_image_owner]

  filter {
    name   = "name"
    values = [var.image_name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "app-keypair" {
    key_name = var.key_name
    public_key = file(var.public_key_location)
}

resource "aws_default_security_group" "app-sg" {
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH into server"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = [var.my_ip]
  }

  ingress {
    description      = "Open app port"
    from_port        = var.app_port
    to_port          = var.app_port
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name: "${var.app_name}-${var.env_prefix}-sg"
  }
}

resource "aws_instance" "app-server" {
  ami = data.aws_ami.linux-image.id
  instance_type = var.instance_type
  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_default_security_group.app-sg.id]
  availability_zone = var.availability_zone
  associate_public_ip_address = true
  key_name = aws_key_pair.app-keypair.key_name

  tags = {
    Name: "${var.app_name}-${var.env_prefix}-server"
  }
}