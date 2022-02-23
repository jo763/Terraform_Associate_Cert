terraform {
  cloud {
    organization = "jo763"

    workspaces {
      name = "provisioners"
    }
  }
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.2.0"
    }
  }
}
provider "aws"{
  # Configuration options
  #profile = "default"
  region = "eu-west-1"
}

data "aws_vpc" "main" {
  id = "vpc-07e47e9d90d2076da"
}

resource "aws_security_group" "eng99_joseph_tf_sg" {
  name        = "eng99_joseph_tf_sg"
  description = "eng99_joseph_tf_sg"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    description      = "HTTP"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = []
  }
  ingress {
    description      = "SSH"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["86.15.253.26/32"]
    ipv6_cidr_blocks = []
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

data "template_file" "user_data"{
  template = file("./userdata.yaml")
}

resource "aws_instance" "eng99_joseph_tf"{
  ami = "ami-07d8796a2b0f8d29c"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  vpc_security_group_ids = [aws_security_group.eng99_joseph_tf_sg.id]
  user_data = data.template_file.user_data.rendered
  tags = {
    Name = "eng99_joseph_tf"
  }
}
resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDw9OiLVQK3TgO3xjmAcbOrKYzg96PB1HFOl4kqRc+U3mt/UAYaQ+hjxJnOk5biwSFYRxOjJYRThWSr2rEUkxBXvUcNYtKZK1BUf4jo90b5Vc07+99eTGuPyhLRF/Y/pRl74WcHUSwdlMBjwk2Ozvnfpa7KZbxncPnlOfywUZ9HjOhAwjwAiJ1tVzlRQOK+6a2Cwx/A6KziX3IOPMK/0bWA4Mj6teiJyO2lEU0w65ZVPgUoEu7tyRMTwtjIp3rHWuhA6XsP5+wlnBMKvPrPUtPrURRkS/L0rTRzDxxKowu9cf2nZmUC3exbanthv53qwRxRojxSfRO3UBCMy68QqAAUwDh9gIhQ5PA6bFuRvUlYi0SOBRHYuTSdDSVrIWlMIc7OIGozpFwIqzLo6hKQn7bHoMSGby26h9zljGG+WxQpSnKK14rBXbQuFjV79dmWIa9cNDcH8M4ehLtkYfGOX+HqbCpGq++Z8AAozRJ/lLNwmTOXq0e+OAiO6J86Vus/pgU= Joe@DESKTOP-TNUIC3D"
}

output "public_ip"{
  value = aws_instance.eng99_joseph_tf.public_ip
}
