

terraform {
 required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
   }
 }
}

provider "aws"{
    region   = "us-east-1"
    access_key = "var.myaccesskey"
    secret_key = "var.mysecretkey"
}

resource "aws_instance" "jenkins20_ec2" {
  ##amazon AMI 
  ami           = "ami-09538990a0c4fe9be"

  ##ubuntu ami 
  #ami           = "ami-0fc5d935ebf8bc3bc"

  instance_type = "t2.micro"
  security_groups = [aws_security_group.JenkinsSg.name]


  tags = {
    Name = "Jenkins"
  }

  root_block_device {
    volume_size = 30  # Size of the volume in gigabytes
  }

 user_data = <<EOF
    #!/bin/bash
    yum update -y
    wget -O /etc/yum.repos.d/jenkins.repo \
    https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
    yum upgrade
    amazon-linux-extras install java-openjdk11 -y
    dnf install java-11-amazon-corretto -y
    yum install jenkins -y
    yum install git -y
    systemctl enable jenkins
    systemctl start jenkins
    systemctl status jenkins
    EOF
}

resource "aws_security_group" "JenkinsSg" {
  vpc_id      = "vpc-06e1468abb5ee5684"
  name        = "allow-ssh and HTTP"
  description = "allow-ssh and HTTP"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

   ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "allow-ssh"
  }
}

resource "aws_s3_bucket" "jenkins-artifacts20-s3" {
bucket = "jenkins-artifacts20-s3-${random_id.example.hex}" 
}

resource "random_id" "example" {
  byte_length = 8
}
